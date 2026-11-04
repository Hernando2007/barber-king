import { httpError } from "../utils/httpError.js";
import {
    buscarFoto,
    borrarFoto,
    contarDelBarbero,
    crearFotos,
    listarDelBarbero,
} from "../models/portafolioModel.js";
import { actualizarBarbero } from "../models/barberosModel.js";
import { perfilDelUsuario } from "./barberoServiciosService.js";
import {
    eliminarImagenCloudinary,
    subirImagenCloudinary,
} from "./cloudinaryService.js";

const CARPETA = "barber-king/portafolio";
const MAXIMO_POR_PETICION = 6;
const MAXIMO_TOTALES = 24;

const sinNada = (resultado) => {
    if (resultado.error) {
        throw httpError(500, resultado.error.message);
    }

    return resultado.data || [];
};

// El código se despliega antes de que se corra la migración 14. Mientras
// la tabla no exista, la galería pública se muestra vacía en vez de 500.
const esTablaFaltante = (error) =>
    error?.code === "PGRST205" ||
    /Could not find the table/i.test(error?.message || "");

const esCloudinarySinConfigurar = (error) =>
    /cloud_name|api_key|api_secret|Configuration requires/i.test(
        error?.message || ""
    );

// La primera foto del portafolio también sirve de portada en las
// tarjetas de barberos, si el barbero no había puesto una.
const usarComoPortada = async (barbero, fotos) => {
    if (barbero.foto_trabajo || !fotos.length) {
        return;
    }

    const { error } = await actualizarBarbero(barbero.id, {
        foto_trabajo: fotos[0].url,
    });

    if (error) {
        console.warn("⚠️ No se pudo actualizar la portada:", error.message);
    }
};

export const fotosPublicas = async (barberoId) => {
    const { data, error } = await listarDelBarbero(barberoId);

    if (esTablaFaltante(error)) {
        return [];
    }

    return sinNada({ data, error });
};

export const misFotos = async (usuario) => {
    const barbero = await perfilDelUsuario(usuario.id);
    return fotosPublicas(barbero.id);
};

export const subirFotos = async (usuario, archivos) => {
    if (!Array.isArray(archivos) || !archivos.length) {
        throw httpError(400, "Adjunta al menos una foto de tu trabajo.");
    }

    if (archivos.length > MAXIMO_POR_PETICION) {
        throw httpError(
            400,
            `Sube máximo ${MAXIMO_POR_PETICION} fotos por vez.`
        );
    }

    const barbero = await perfilDelUsuario(usuario.id);
    const conteo = await contarDelBarbero(barbero.id);

    if (esTablaFaltante(conteo.error)) {
        throw httpError(
            503,
            "El portafolio se activará en cuanto esté listo en el servidor."
        );
    }

    if (conteo.error) {
        throw httpError(500, conteo.error.message);
    }

    const actuales = Number(conteo.data?.count || 0);

    if (actuales + archivos.length > MAXIMO_TOTALES) {
        throw httpError(
            400,
            `Tu portafolio admite ${MAXIMO_TOTALES} fotos y ya tienes ${actuales}.`
        );
    }

    const subidas = [];

    for (const archivo of archivos) {
        try {
            subidas.push(await subirImagenCloudinary(archivo, CARPETA));
        } catch (error) {
            if (esCloudinarySinConfigurar(error)) {
                throw httpError(
                    503,
                    "El almacenamiento de fotos no está configurado en el servidor."
                );
            }

            throw httpError(
                500,
                "No fue posible subir la foto. Intenta con otra imagen."
            );
        }
    }

    const fotos = sinNada(
        await crearFotos(
            subidas.map((imagen) => ({
                barbero_id: barbero.id,
                url: imagen.url,
                public_id: imagen.publicId,
            }))
        )
    );

    await usarComoPortada(barbero, fotos);

    return fotos;
};

export const borrarMiFoto = async (usuario, fotoId) => {
    const id = Number(fotoId);

    if (!Number.isInteger(id) || id <= 0) {
        throw httpError(400, "Foto no válida.");
    }

    const { data: foto, error } = await buscarFoto(id);

    if (esTablaFaltante(error)) {
        throw httpError(
            503,
            "El portafolio se activará en cuanto esté listo en el servidor."
        );
    }

    if (error) {
        throw httpError(500, error.message);
    }

    if (!foto) {
        throw httpError(404, "Esa foto ya no existe.");
    }

    const barbero = await perfilDelUsuario(usuario.id);

    if (Number(foto.barbero_id) !== Number(barbero.id)) {
        throw httpError(403, "Esa foto no pertenece a tu portafolio.");
    }

    const borrada = await borrarFoto(id);

    if (borrada.error) {
        throw httpError(500, borrada.error.message);
    }

    // Si Cloudinary responde mal, la fila ya no existe: la foto queda
    // huérfana en el cloud pero el cliente ya no la ve.
    await eliminarImagenCloudinary(foto.public_id).catch((problema) => {
        console.warn("⚠️ La foto quedó en Cloudinary:", problema.message);
    });

    return foto;
};
