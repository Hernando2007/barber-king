import {
    obtenerResenas,
    obtenerResenaPorId,
    obtenerResenasPorBarbero,
    crearResena,
    actualizarResena,
    eliminarResena
} from "../models/resenasModel.js";

export const listarResenas = async () => {

    const { data, error } =
        await obtenerResenas();

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

export const obtenerUnaResena = async (
    id
) => {

    const { data, error } =
        await obtenerResenaPorId(id);

    if (error || !data) {

        throw new Error(
            "Reseña no encontrada."
        );

    }

    return data;

};

export const listarResenasPorBarbero = async (
    barberoId
) => {

    const { data, error } =
        await obtenerResenasPorBarbero(
            barberoId
        );

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

export const registrarResena = async (
    datos
) => {

    const {
        cliente_id,
        barbero_id,
        calificacion
    } = datos;

    if (
        !cliente_id ||
        !barbero_id ||
        !calificacion
    ) {

        throw new Error(
            "Cliente, barbero y calificación son obligatorios."
        );

    }

    if (
        calificacion < 1 ||
        calificacion > 5
    ) {

        throw new Error(
            "La calificación debe estar entre 1 y 5."
        );

    }

    const { data, error } =
        await crearResena(datos);

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

export const editarResena = async (
    id,
    datos
) => {

    await obtenerUnaResena(id);

    if (
        datos.calificacion &&
        (
            datos.calificacion < 1 ||
            datos.calificacion > 5
        )
    ) {

        throw new Error(
            "La calificación debe estar entre 1 y 5."
        );

    }

    const { data, error } =
        await actualizarResena(
            id,
            datos
        );

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

export const borrarResena = async (
    id
) => {

    await obtenerUnaResena(id);

    const { error } =
        await eliminarResena(id);

    if (error) {
        throw new Error(error.message);
    }

    return true;

};