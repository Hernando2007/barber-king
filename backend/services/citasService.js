import {
    crearNuevaCita,
    obtenerCitas
} from "../models/citasModel.js";
import { condicionesDelServicio } from "./barberoServiciosService.js";
import { horaAMinutos } from "../utils/horarios.js";
import { yaPasó } from "../utils/horaBarberia.js";

const FORMATO_FECHA = /^\d{4}-\d{2}-\d{2}$/;
const FORMATO_HORA = /^([01]?\d|2[0-3]):[0-5]\d$/;

const fechaReal = (fecha) => {
    const leida = new Date(`${fecha}T00:00:00Z`);
    if (Number.isNaN(leida.getTime())) return false;
    return leida.toISOString().slice(0, 10) === fecha;
};

const horaValida = (hora) =>
    FORMATO_HORA.test(String(hora).slice(0, 5));

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

    if (
        !FORMATO_FECHA.test(String(fecha)) ||
        !fechaReal(String(fecha)) ||
        !horaValida(hora)
    ) {
        throw new Error("La fecha u hora no son válidas.");
    }

    if (yaPasó(fecha, hora)) {
        throw new Error(
            "Esa hora ya pasó en la barbería. Elige una hora futura."
        );
    }

    // Verifica que este barbero preste este servicio y trae el precio
    // y la duración que él haya fijado, no las del catálogo general.
    const servicio = await condicionesDelServicio(
        barbero_id,
        servicio_id
    );

    const { data: citasExistentes, error: errorCitas } =
        await obtenerCitas(barbero_id, fecha);

    if (errorCitas) {
        throw new Error(errorCitas.message);
    }

    const inicioNueva = horaAMinutos(String(hora));
    const finNueva = inicioNueva + Number(servicio.duracion);

    for (const cita of citasExistentes || []) {
        if (["Cancelada", "cancelada"].includes(cita.estado)) {
            continue;
        }

        const inicioExistente = horaAMinutos(cita.hora);
        const duracion =
            Number(cita.duracion_minutos) || Number(servicio.duracion);
        const finExistente = inicioExistente + duracion;

        if (
            inicioNueva < finExistente &&
            finNueva > inicioExistente
        ) {
            throw new Error(
                "El barbero ya tiene una cita en ese horario."
            );
        }
    }

    const { data, error: errorCrear } = await crearNuevaCita({
        cliente_id,
        barbero_id,
        servicio_id,
        fecha,
        hora,
        duracion_minutos: servicio.duracion,
        precio: servicio.precio,
        estado: estado || "Pendiente",
        observaciones: observaciones || null
    });

    if (errorCrear) {
        throw new Error(errorCrear.message);
    }

    return data;
};
