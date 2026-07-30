import {
    obtenerServicios,
    obtenerServicioPorId,
    crearServicio,
    actualizarServicio,
    eliminarServicio
} from "../models/serviciosModel.js";


export const listarServicios = async () => {

    const { data, error } = await obtenerServicios();

    if (error) throw new Error(error.message);

    return data;

};


export const obtenerUno = async (id) => {

    const { data, error } = await obtenerServicioPorId(id);

    if (error) throw new Error(error.message);

    return data;

};

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

    if (!nombre || !precio || !duracion) {
        throw new Error(
            "Nombre, precio y duración son obligatorios."
        );
    }

    const { data, error } = await crearServicio({
        nombre,
        descripcion,
        precio,
        duracion,
        tiempo_descanso,
        imagen,
        estado
    });

    if (error) throw new Error(error.message);

    return data;

};


export const editarServicio = async (id, datos) => {

    const { data, error } =
        await actualizarServicio(id, datos);

    if (error) throw new Error(error.message);

    return data;

};


export const borrarServicio = async (id) => {

    const { error } = await eliminarServicio(id);

    if (error) throw new Error(error.message);

    return true;

};