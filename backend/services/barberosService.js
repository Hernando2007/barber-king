import {
    obtenerBarberos,
    obtenerBarberoPorId,
    crearBarbero,
    actualizarBarbero,
    eliminarBarbero
} from "../models/barberosModel.js";

// Listar todos los barberos
export const listarBarberos = async () => {

    const { data, error } =
        await obtenerBarberos();

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

// Obtener un barbero
export const obtenerUno = async (id) => {

    const { data, error } =
        await obtenerBarberoPorId(id);

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

// Registrar un barbero
export const registrarBarbero = async (datos) => {

    // Validamos los datos recibidos
    if (!datos.usuario_id) {
        throw new Error(
            "El usuario es obligatorio."
        );
    }

    const { data, error } =
        await crearBarbero(datos);

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

// Editar un barbero
export const editarBarbero = async (
    id,
    datos
) => {

    if (!id) {
        throw new Error(
            "El ID del barbero es obligatorio."
        );
    }

    const { data, error } =
        await actualizarBarbero(
            id,
            datos
        );

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

// Eliminar un barbero
export const borrarBarbero = async (id) => {

    if (!id) {
        throw new Error(
            "El ID del barbero es obligatorio."
        );
    }

    const { error } =
        await eliminarBarbero(id);

    if (error) {
        throw new Error(error.message);
    }

    return true;

};