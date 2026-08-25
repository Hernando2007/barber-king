import {
    obtenerServicios,
    obtenerServicioPorId,
    crearServicio,
    actualizarServicio,
    eliminarServicio
} from "../models/serviciosModel.js";

// Obtener todos los servicios
export const listarServicios = async () => {

    const { data, error } =
        await obtenerServicios();

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

// Obtener un servicio por ID
export const obtenerUno = async (id) => {

    const { data, error } =
        await obtenerServicioPorId(id);

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

// Crear un servicio
export const registrarServicio = async (datos) => {

    const {
        nombre,
        descripcion,
        precio,
        duracion,
        tiempo_descanso,
        imagen,
        estado
    } = datos;

    // Validamos los campos principales
    if (!nombre || precio === undefined || !duracion) {

        throw new Error(
            "Nombre, precio y duración son obligatorios."
        );
    }

    const { data, error } =
        await crearServicio({
            nombre,
            descripcion,
            precio,
            duracion,
            tiempo_descanso,
            imagen,
            estado
        });

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

// Actualizar un servicio
export const editarServicio = async (
    id,
    datos
) => {

    if (!id) {
        throw new Error(
            "El ID del servicio es obligatorio."
        );
    }

    const { data, error } =
        await actualizarServicio(
            id,
            datos
        );

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

// Eliminar un servicio
export const borrarServicio = async (id) => {

    if (!id) {
        throw new Error(
            "El ID del servicio es obligatorio."
        );
    }

    const { error } =
        await eliminarServicio(id);

    if (error) {
        throw new Error(error.message);
    }

    return true;

};