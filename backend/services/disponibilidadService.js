import { obtenerHorarioBarbero, obtenerServicio, obtenerCitas } from "../models/citasModel.js";
import { generarBloques } from "../utils/horarios.js";
import { httpError } from "../utils/httpError.js";

export const obtenerDisponibilidad = async (
    barberoId,
    servicioId,
    fecha
) => {

    if (
        !barberoId ||
        !servicioId ||
        !fecha
    ) {

        throw httpError(
            400,
            "Faltan parámetros requeridos."
        );

    }

    if (
        !Number.isInteger(Number(barberoId)) ||
        !Number.isInteger(Number(servicioId))
    ) {

        throw httpError(
            400,
            "El barbero y el servicio deben ser válidos."
        );

    }

    const [
        anio,
        mes,
        dia
    ] = fecha
        .split("-")
        .map(Number);

    const fechaLocal =
        new Date(
            anio,
            mes - 1,
            dia
        );

    if (
        Number.isNaN(
            fechaLocal.getTime()
        )
    ) {

        throw new Error(
            "La fecha es inválida."
        );

    }

    const diaSemanaJS = fechaLocal.getDay();

    const diaSemana =
        diaSemanaJS === 0
        ? 7
        : diaSemanaJS;

    const {
        data: horario,
        error: errorHorario
    } =
        await obtenerHorarioBarbero(
            barberoId,
            diaSemana
        );

    if (errorHorario) {

        throw new Error(
            errorHorario.message
        );

    }

    if (!horario) {

        return [];

    }

    const {
        data: servicio,
        error: errorServicio
    } =
        await obtenerServicio(
            servicioId
        );

    if (errorServicio) {

        throw new Error(
            errorServicio.message
        );

    }

    if (!servicio) {

        throw new Error(
            "Servicio no encontrado."
        );

    }

    const {
        data: citas,
        error: errorCitas
    } =
        await obtenerCitas(
            barberoId,
            fecha
        );

    if (errorCitas) {

        throw new Error(
            errorCitas.message
        );

    }

    let bloques =
        generarBloques(
            horario.hora_inicio,
            horario.hora_fin,
            servicio.duracion
        );

    if (
        citas &&
        citas.length > 0
    ) {

        bloques =
            bloques.filter(
                hora => {

                    return !citas.some(
                        cita =>
                            cita.hora
                                .slice(0, 5) ===
                            hora
                    );

                }
            );

    }

    return bloques;

};