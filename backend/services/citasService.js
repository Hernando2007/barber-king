import {
    crearNuevaCita,
    buscarCitaExistente,
    obtenerServicio,
    listarCitas,
    obtenerCitaPorId,
    actualizarCita,
    eliminarCita
} from "../models/citasModel.js";


export const registrarCita = async (datos) => {

    const {
        cliente_id,
        barbero_id,
        servicio_id,
        fecha,
        hora,
        estado,
        observaciones
    } = datos;

    if (
        !cliente_id ||
        !barbero_id ||
        !servicio_id ||
        !fecha ||
        !hora
    ) {
        throw new Error(
            "Todos los campos obligatorios deben ser enviados."
        );
    }

    const {
        data: existe,
        error
    } = await buscarCitaExistente(
        barbero_id,
        fecha,
        hora
    );

    if (existe) {
        throw new Error("Ese horario ya fue reservado.");
    }

    if (error && error.code !== "PGRST116") {
        throw new Error(error.message);
    }

    const {
        data: servicio,
        error: errorServicio
    } = await obtenerServicio(servicio_id);

    if (errorServicio || !servicio) {
        throw new Error("Servicio no encontrado.");
    }

    const {
        data,
        error: errorCrear
    } = await crearNuevaCita({

        cliente_id,
        barbero_id,
        servicio_id,

        fecha,
        hora,

        duracion_minutos: servicio.duracion,
        precio: servicio.precio,

        estado: estado || "Pendiente",

        observaciones

    });

    if (errorCrear) {
        throw new Error(errorCrear.message);
    }

    return data;

};


export const obtenerTodasLasCitas = async () => {

    const { data, error } = await listarCitas();

    if (error) {
        throw new Error(error.message);
    }

    return data;

};


export const obtenerUnaCita = async (id) => {

    const { data, error } = await obtenerCitaPorId(id);

    if (error) {
        throw new Error(error.message);
    }

    return data;

};


export const editarCita = async (id, datos) => {

    const { data, error } = await actualizarCita(id, datos);

    if (error) {
        throw new Error(error.message);
    }

    return data;

};


export const borrarCita = async (id) => {

    const { error } = await eliminarCita(id);

    if (error) {
        throw new Error(error.message);
    }

    return true;

};