import {
    obtenerBarberos,
    obtenerBarberoPorId,
    crearBarbero,
    actualizarBarbero,
    eliminarBarbero
} from "../models/barberosModel.js";

/* ===========================================
   LISTAR TODOS
=========================================== */

export const listarBarberos = async () => {

    const { data, error } = await obtenerBarberos();

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

/* ===========================================
   OBTENER POR ID
=========================================== */

export const obtenerUno = async (id) => {

    const { data, error } = await obtenerBarberoPorId(id);

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

/* ===========================================
   CREAR
=========================================== */

export const registrarBarbero = async (datos) => {

    const {
        usuario_id,
        especialidad,
        experiencia,
        descripcion,
        foto_trabajo,
        disponible
    } = datos;

    if (!usuario_id) {
        throw new Error("Debe seleccionar un usuario.");
    }

    const { data, error } = await crearBarbero({
        usuario_id,
        especialidad,
        experiencia,
        descripcion,
        foto_trabajo,
        disponible
    });

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

/* ===========================================
   ACTUALIZAR
=========================================== */

export const editarBarbero = async (id, datos) => {

    const { data, error } = await actualizarBarbero(id, datos);

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

/* ===========================================
   ELIMINAR
=========================================== */

export const borrarBarbero = async (id) => {

    const { error } = await eliminarBarbero(id);

    if (error) {
        throw new Error(error.message);
    }

    return true;

};