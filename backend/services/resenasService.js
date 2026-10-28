import {
    obtenerResenas,
    obtenerResenaPorId,
    obtenerResenasPorBarbero,
    crearResena,
    actualizarResena,
    eliminarResena,
} from "../models/resenasModel.js";
import { obtenerCitaPorId } from "../models/citasModel.js";
import { httpError } from "../utils/httpError.js";
import { contieneProfanidad } from "../utils/profanidad.js";

const calificacionValida = (valor) => {
    const numero = Number(valor);

    return (
        Number.isInteger(numero) &&
        numero >= 1 &&
        numero <= 5
    );
};

const comentarioNoPermitido =
    "El comentario tiene palabras no permitidas. Reformúlalo para publicarlo.";

export const listarResenas = async () => {
    const { data, error } = await obtenerResenas();

    if (error) throw new Error(error.message);

    return data || [];
};

export const obtenerUnaResena = async (id) => {
    const { data, error } = await obtenerResenaPorId(id);

    if (error || !data) {
        throw httpError(404, "Reseña no encontrada.");
    }

    return data;
};

export const listarResenasPorBarbero = async (id) => {
    const { data, error } = await obtenerResenasPorBarbero(id);

    if (error) throw new Error(error.message);

    return data || [];
};

export const registrarResena = async (datos, usuario) => {
    const { cita_id, barbero_id, calificacion, comentario } =
        datos || {};

    if (!cita_id || !barbero_id || !calificacion) {
        throw httpError(
            400,
            "Cita, barbero y calificación son obligatorios."
        );
    }

    if (contieneProfanidad(comentario)) {
        throw httpError(400, comentarioNoPermitido);
    }

    if (!calificacionValida(calificacion)) {
        throw httpError(
            400,
            "La calificación debe estar entre 1 y 5."
        );
    }

    const { data: cita, error: errorCita } =
        await obtenerCitaPorId(cita_id);

    if (errorCita || !cita) {
        throw httpError(404, "Cita no encontrada.");
    }

    if (Number(cita.cliente_id) !== Number(usuario.id)) {
        throw httpError(
            403,
            "La cita no pertenece al usuario autenticado."
        );
    }

    if (cita.estado !== "Completada") {
        throw httpError(
            400,
            "Solo puedes calificar citas completadas."
        );
    }

    if (Number(cita.barbero_id) !== Number(barbero_id)) {
        throw httpError(
            400,
            "El barbero no corresponde a la cita."
        );
    }

    const { data: existentes, error: errorExistentes } =
        await obtenerResenasPorBarbero(barbero_id);

    if (errorExistentes) {
        throw new Error(errorExistentes.message);
    }

    const yaCalifico = (existentes || []).some(
        (resena) =>
            Number(resena.cliente_id) === Number(usuario.id)
    );

    if (yaCalifico) {
        throw httpError(
            409,
            "Ya tienes una reseña publicada para este barbero."
        );
    }

    const { data, error } = await crearResena({
        cliente_id: usuario.id,
        barbero_id,
        calificacion: Number(calificacion),
        comentario: comentario || null,
    });

    if (error) throw new Error(error.message);

    return data;
};

export const editarResena = async (id, datos, usuario) => {
    const actual = await obtenerUnaResena(id);

    if (
        Number(actual.cliente_id) !== Number(usuario.id) &&
        usuario.rol !== "Administrador"
    ) {
        throw httpError(
            403,
            "No tienes permiso para editar esta reseña."
        );
    }

    const cambios = {};

    if (datos.calificacion !== undefined) {
        if (!calificacionValida(datos.calificacion)) {
            throw httpError(
                400,
                "La calificación debe estar entre 1 y 5."
            );
        }

        cambios.calificacion = Number(datos.calificacion);
    }

    if (datos.comentario !== undefined) {
        if (contieneProfanidad(datos.comentario)) {
            throw httpError(400, comentarioNoPermitido);
        }

        cambios.comentario = datos.comentario;
    }

    const { data, error } = await actualizarResena(id, cambios);

    if (error) throw new Error(error.message);

    return data;
};

export const borrarResena = async (id, usuario) => {
    const actual = await obtenerUnaResena(id);

    if (
        Number(actual.cliente_id) !== Number(usuario.id) &&
        usuario.rol !== "Administrador"
    ) {
        throw httpError(
            403,
            "No tienes permiso para eliminar esta reseña."
        );
    }

    const { error } = await eliminarResena(id);

    if (error) throw new Error(error.message);

    return true;
};
