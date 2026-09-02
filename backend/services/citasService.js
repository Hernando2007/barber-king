import {
    crearNuevaCita,
    obtenerServicio,
    obtenerCitas,
    listarCitas,
    obtenerCitaPorId,
    actualizarCita,
    eliminarCita
} from "../models/citasModel.js";

export const registrarCita = async (
    datos
) => {

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

    const fechaHoraNueva =
        new Date(
            `${fecha}T${hora}`
        );

    if (
        fechaHoraNueva <
        new Date()
    ) {

        throw new Error(
            "No se pueden registrar citas en fechas pasadas."
        );

    }

    const {
        data: servicio,
        error: errorServicio
    } =
        await obtenerServicio(
            servicio_id
        );

    if (
        errorServicio ||
        !servicio
    ) {

        throw new Error(
            "Servicio no encontrado."
        );

    }

    const {
        data: citasExistentes,
        error: errorCitas
    } =
        await obtenerCitas(
            barbero_id,
            fecha
        );

    if (errorCitas) {

        throw new Error(
            errorCitas.message
        );

    }

    const inicioNueva =
        convertirMinutos(
            hora
        );

    const finNueva =
        inicioNueva +
        servicio.duracion;

    for (
        const cita of citasExistentes
    ) {

        const inicioExistente =
            convertirMinutos(
                cita.hora
            );

        const finExistente =
            inicioExistente +
            cita.duracion_minutos;

        const hayCruce =
            inicioNueva <
                finExistente &&
            finNueva >
                inicioExistente;

        if (hayCruce) {

            throw new Error(
                "El barbero ya tiene una cita en ese horario."
            );

        }

    }

    const {
        data,
        error: errorCrear
    } =
        await crearNuevaCita({

            cliente_id,
            barbero_id,
            servicio_id,

            fecha,
            hora,

            duracion_minutos:
                servicio.duracion,

            precio:
                servicio.precio,

            estado:
                estado ||
                "Pendiente",

            observaciones:
                observaciones || null

        });

    if (errorCrear) {

        throw new Error(
            errorCrear.message
        );

    }

    return data;

};

export const obtenerTodasLasCitas = async () => {

    const {
        data,
        error
    } =
        await listarCitas();

    if (error) {

        throw new Error(
            error.message
        );

    }

    return data;

};

export const obtenerUnaCita = async (
    id
) => {

    const {
        data,
        error
    } =
        await obtenerCitaPorId(
            id
        );

    if (
        error ||
        !data
    ) {

        throw new Error(
            "Cita no encontrada."
        );

    }

    return data;

};

export const editarCita = async (
    id,
    datos
) => {

    const {
        data: citaExistente
    } =
        await obtenerCitaPorId(
            id
        );

    if (!citaExistente) {

        throw new Error(
            "Cita no encontrada."
        );

    }

    const {
        data,
        error
    } =
        await actualizarCita(
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

export const borrarCita = async (
    id
) => {

    const {
        data: citaExistente
    } =
        await obtenerCitaPorId(
            id
        );

    if (!citaExistente) {

        throw new Error(
            "Cita no encontrada."
        );

    }

    const {
        error
    } =
        await eliminarCita(
            id
        );

    if (error) {

        throw new Error(
            error.message
        );

    }

    return true;

};

const convertirMinutos = (
    hora
) => {

    const [
        horas,
        minutos
    ] =
        hora
            .split(":")
            .map(Number);

    return (
        horas * 60 +
        minutos
    );

};