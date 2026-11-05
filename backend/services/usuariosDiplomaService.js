import { httpError } from "../utils/httpError.js";
import {
    obtenerBarberoPorUsuario,
    actualizarBarbero,
} from "../models/barberosModel.js";
import { subirImagenCloudinary } from "./cloudinaryService.js";
import {
    marcarBarberoVerificado,
    verificarDiplomaBarbero,
} from "./verificacionBarberosService.js";

/** El barbero sube o reemplaza su diploma desde su perfil. */
export const guardarDiplomaBarbero = async (usuario, archivo) => {
    if (!usuario?.id) {
        throw httpError(401, "Usuario no autenticado.");
    }

    if (!archivo) {
        throw httpError(400, "Selecciona un archivo.");
    }

    const { data: barbero } = await obtenerBarberoPorUsuario(usuario.id);

    if (!barbero) {
        throw httpError(
            404,
            "Perfil de barbero no encontrado."
        );
    }

    const { url: urlDiploma } = await subirImagenCloudinary(
        archivo,
        "barber-king/documentos"
    );

    let motivoRechazo = null;

    try {
        await verificarDiplomaBarbero({
            urlPublica: urlDiploma,
            mimetype: archivo.mimetype,
            nombreOriginal: archivo.originalname,
            origen: "actualizacion",
            usuarioId: usuario.id,
            barberoId: barbero.id,
        });
    } catch (error) {
        // Un 422 es la IA diciendo "esto no es un diploma". El documento
        // se guarda igual: la bandeja del administrador necesita abrirlo.
        if (error?.statusCode !== 422) {
            throw error;
        }

        motivoRechazo = error.message;
    }

    const portafolio = Array.isArray(barbero.portafolio)
        ? barbero.portafolio.filter(
              (item) => item?.tipo !== "diploma"
          )
        : [];

    portafolio.push({
        tipo: "diploma",
        url: urlDiploma,
        nombre: archivo.originalname || archivo.filename,
    });

    const { error } = await actualizarBarbero(barbero.id, {
        portafolio,
    });

    if (error) {
        throw new Error(error.message);
    }

    if (motivoRechazo) {
        await actualizarBarbero(barbero.id, {
            verificacion_estado: "rechazado",
        }).catch(() => null);

        throw httpError(422, motivoRechazo);
    }

    await marcarBarberoVerificado(barbero.id);

    return {
        diploma_url: urlDiploma,
        portafolio,
    };
};
