import { obtenerHorarioBarbero, obtenerCitas } from "../models/citasModel.js";
import { obtenerBarberoPorId } from "../models/barberosModel.js";
import { condicionesDelServicio } from "./barberoServiciosService.js";
import {
    generarBloques,
    diaDeLaSemana,
    horaAMinutos,
    bloqueaHorario
} from "../utils/horarios.js";
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

    const { data: barbero, error: errorBarbero } =
        await obtenerBarberoPorId(barberoId);

    if (errorBarbero) {
        throw new Error(errorBarbero.message);
    }

    // Un barbero inactivo no ofrece horas: el cliente no ve bloques libres.
    if (!barbero || barbero.disponible === false) {
        return [];
    }

    const diaSemana = diaDeLaSemana(fecha);

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

    // Los bloques se arman con la duración que fija este barbero, no con
    // la del catálogo. Si el par no existe, falla con un mensaje claro.
    const servicio = await condicionesDelServicio(
        barberoId,
        servicioId
    );

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

                    const inicio =
                        horaAMinutos(hora);

                    const fin =
                        inicio + Number(servicio.duracion);

                    return !citas.some(
                        cita => bloqueaHorario(
                            cita,
                            inicio,
                            fin,
                            servicio.duracion
                        )
                    );

                }
            );

    }

    return bloques;

};