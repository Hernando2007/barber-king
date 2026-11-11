import { httpError } from "../utils/httpError.js";
import {
    obtenerHorarioBarbero,
    obtenerCitas,
} from "../models/citasModel.js";
import { obtenerBarberoPorId } from "../models/barberosModel.js";
import { condicionesDelServicio } from "./barberoServiciosService.js";
import {
    diaDeLaSemana,
    generarBloques,
    horaAMinutos,
    bloqueaHorario,
} from "../utils/horarios.js";

// Reglas de disponibilidad que comparten la reserva y el catálogo de horas:
// el barbero debe estar activo, atender ese día y tener el bloque libre.
// Si todo cuadra, la cita se confirma sin que el barbero tenga que aprobarla.
export const validarSlotDisponible = async ({
    barberoId,
    servicioId,
    fecha,
    hora,
}) => {
    const { data: barbero, error } = await obtenerBarberoPorId(barberoId);

    if (error) {
        throw new Error(error.message);
    }

    if (!barbero) {
        throw httpError(404, "Ese barbero no existe.");
    }

    if (barbero.disponible === false) {
        throw httpError(
            409,
            "El barbero está inactivo y no acepta reservas por ahora."
        );
    }

    const servicio = await condicionesDelServicio(barberoId, servicioId);

    const { data: horario, error: errorHorario } =
        await obtenerHorarioBarbero(barberoId, diaDeLaSemana(fecha));

    if (errorHorario) {
        throw new Error(errorHorario.message);
    }

    if (!horario) {
        throw httpError(409, "El barbero no atiende ese día.");
    }

    const horaNormalizada = String(hora).slice(0, 5);
    const bloques = generarBloques(
        horario.hora_inicio,
        horario.hora_fin,
        servicio.duracion
    );

    if (!bloques.includes(horaNormalizada)) {
        throw httpError(
            409,
            "Esa hora no está disponible. Elige uno de los horarios libres."
        );
    }

    const { data: citas, error: errorCitas } = await obtenerCitas(
        barberoId,
        fecha
    );

    if (errorCitas) {
        throw new Error(errorCitas.message);
    }

    const inicio = horaAMinutos(horaNormalizada);
    const fin = inicio + Number(servicio.duracion);

    const ocupado = (citas || []).some((cita) =>
        bloqueaHorario(cita, inicio, fin, servicio.duracion)
    );

    if (ocupado) {
        throw httpError(
            409,
            "El barbero ya tiene una cita en ese horario."
        );
    }

    return { barbero, servicio, hora: horaNormalizada };
};