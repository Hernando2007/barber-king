import { httpError } from "./httpError.js";
import { listarMotivos } from "./respuestasSolicitud.js";
import { obtenerBarberoPorId } from "../models/barberosModel.js";
import { obtenerCitaPorId, obtenerServicio } from "../models/citasModel.js";
import { crearAviso } from "../models/avisosModel.js";

const MAX_LONGITUD_NOTA = 140;

// PostgREST responde con uno u otro según dónde se mire la tabla que falta;
// los dos significan lo mismo para nosotros: el usuario aún no aplica la
// migración 16 y eso debe verse como un aviso nuestro, no como un 500.
const TABLAS_FALTANTES = ["42P01", "PGRST205"];
const TABLA_FALTANTE_MENSAJE =
    "Las solicitudes todavía no están activas en la base de datos.";

export const esTablaFaltante = (error) =>
    TABLAS_FALTANTES.includes(String(error?.code)) ||
    /could not find the table/i.test(String(error?.message || ""));

// Devuelve los datos o convierte el error de la base en un error de negocio
// con mensaje en español.
export const leer = (resultado) => {
    const error = resultado?.error;

    if (!error) {
        return resultado?.data ?? null;
    }

    if (esTablaFaltante(error)) {
        throw httpError(503, TABLA_FALTANTE_MENSAJE);
    }

    throw new Error(error.message);
};

export const contar = (resultado) => {
    leer(resultado);

    return Number(resultado?.count) || 0;
};

const nota = (valor, etiqueta) => {
    const limpio = String(valor ?? "").trim();

    if (!limpio) {
        return null;
    }

    if (limpio.length > MAX_LONGITUD_NOTA) {
        throw httpError(
            400,
            `${etiqueta} no puede pasar de ${MAX_LONGITUD_NOTA} caracteres.`
        );
    }

    return limpio;
};

export const notaCliente = (valor) => nota(valor, "La nota");

export const notaBarbero = (valor) => nota(valor, "La respuesta");

export const fechaPropuesta = (valor) => {
    if (valor === null || valor === undefined || valor === "") {
        return null;
    }

    const fecha = new Date(valor);

    if (Number.isNaN(fecha.getTime())) {
        throw httpError(400, "La fecha propuesta no es válida.");
    }

    return fecha.toISOString();
};

export const etiquetaMotivo = (motivo) =>
    listarMotivos().find((item) => item.clave === motivo)?.etiqueta || motivo;

// El barbero siempre existe; la cita y el servicio solo se aceptan si son
// del cliente y del barbero de esta solicitud, para que nadie pueda pegar el
// id de una cita ajena y dejar su hora en la bandeja de otro.
export const resolverDestino = async (
    usuario,
    { barberoId, citaId, servicioId, motivo }
) => {
    const { data: barbero, error } = await obtenerBarberoPorId(barberoId);

    if (error) {
        throw new Error(error.message);
    }

    if (!barbero) {
        throw httpError(404, "Ese barbero no existe.");
    }

    if (Number(barbero.usuario_id) === Number(usuario.id)) {
        throw httpError(400, "No puedes solicitarte nada a ti mismo.");
    }

    if (citaId) {
        const datosCita = leer(await obtenerCitaPorId(citaId));

        if (!datosCita) {
            throw httpError(404, "La cita indicada no existe.");
        }

        if (Number(datosCita.cliente_id) !== Number(usuario.id)) {
            throw httpError(403, "Esa cita no te pertenece.");
        }

        if (Number(datosCita.barbero_id) !== Number(barberoId)) {
            throw httpError(
                400,
                "Esa cita es de otro barbero, no de este."
            );
        }
    }

    if (motivo === "reprogramar" && !citaId) {
        throw httpError(400, "Para reprogramar necesitas indicar la cita.");
    }

    if (servicioId) {
        const datosServicio = leer(await obtenerServicio(servicioId));

        if (!datosServicio) {
            throw httpError(404, "El servicio indicado no existe.");
        }
    }

    return barbero;
};

// El aviso es best-effort: si la tabla todavía no existe, la solicitud igual
// se guarda y la app lo descubre al recargar la bandeja.
export const avisar = async (usuarioId, tipo, titulo, cuerpo, datos) => {
    if (!usuarioId) {
        return null;
    }

    const resultado = await crearAviso({
        usuarioId,
        tipo,
        titulo,
        cuerpo,
        datos,
    });

    if (resultado?.error) {
        console.warn(
            "⚠️ No se pudo registrar el aviso:",
            resultado.error.message
        );
    }

    return resultado?.data ?? null;
};
