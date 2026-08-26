import {
    obtenerBarberos,
    obtenerBarberoPorId,
    obtenerBarberoPorUsuario,
    crearBarbero,
    actualizarBarbero,
    eliminarBarbero
} from "../models/barberosModel.js";

export const listarBarberos = async () => {

    const {
        data,
        error
    } =
        await obtenerBarberos();

    if (error) {

        throw new Error(
            error.message
        );

    }

    return data;

};

export const obtenerUno = async (
    id
) => {

    if (!id) {

        throw new Error(
            "El ID es obligatorio."
        );

    }

    const {
        data,
        error
    } =
        await obtenerBarberoPorId(id);

    if (
        error ||
        !data
    ) {

        throw new Error(
            "Barbero no encontrado."
        );

    }

    return data;

};

export const registrarBarbero = async (
    datos
) => {

    if (!datos.usuario_id) {

        throw new Error(
            "El usuario es obligatorio."
        );

    }

    const {
        data: existe
    } =
        await obtenerBarberoPorUsuario(
            datos.usuario_id
        );

    if (existe) {

        throw new Error(
            "Este usuario ya está registrado como barbero."
        );

    }

    const {
        data,
        error
    } =
        await crearBarbero(
            datos
        );

    if (error) {

        throw new Error(
            error.message
        );

    }

    return data;

};

export const editarBarbero = async (
    id,
    datos
) => {

    if (!id) {

        throw new Error(
            "El ID del barbero es obligatorio."
        );

    }

    const {
        data: existe
    } =
        await obtenerBarberoPorId(id);

    if (!existe) {

        throw new Error(
            "Barbero no encontrado."
        );

    }

    const {
        data,
        error
    } =
        await actualizarBarbero(
            id,
            datos
        );

    if (error) {

        throw new Error(
            error.message
        );

    }

    return data;

};

export const borrarBarbero = async (
    id
) => {

    if (!id) {

        throw new Error(
            "El ID del barbero es obligatorio."
        );

    }

    const {
        data: existe
    } =
        await obtenerBarberoPorId(id);

    if (!existe) {

        throw new Error(
            "Barbero no encontrado."
        );

    }

    const {
        error
    } =
        await eliminarBarbero(id);

    if (error) {

        throw new Error(
            error.message
        );

    }

    return true;

};