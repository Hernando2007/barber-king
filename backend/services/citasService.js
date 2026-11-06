import {
    crearNuevaCita,
} from "../models/citasModel.js";
import { obtenerUsuarioPorId } from "../models/usuariosModel.js";
import { validarSlotDisponible } from "./citasReservaService.js";
import { avisar } from "./avisosService.js";
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

const nombreCliente = async (clienteId) => {
    const { data } = await obtenerUsuarioPorId(clienteId);
    return `${data?.nombres ?? ""} ${data?.apellidos ?? ""}`.trim() ||
        "Un cliente";
};

// La cita nace confirmada: si el bloque está libre no hace falta que el
// barbero la apruebe. Él recibe un aviso de "cita agendada" y la ve en su
// agenda; el recordatorio de "llega un cliente" sigue saliendo aparte.
export const registrarCita = async (datos) => {
    const {
        cliente_id,
        barbero_id,
        servicio_id,
        fecha,
        hora,
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

    const { barbero, servicio, hora: horaLibre } =
        await validarSlotDisponible({
            barberoId: barbero_id,
            servicioId: servicio_id,
            fecha,
            hora,
        });

    const { data, error } = await crearNuevaCita({
        cliente_id,
        barbero_id,
        servicio_id,
        fecha,
        hora: horaLibre,
        duracion_minutos: servicio.duracion,
        precio: servicio.precio,
        estado: "Confirmada",
        observaciones: observaciones || null
    });

    if (error) {
        throw new Error(error.message);
    }

    const cliente = await nombreCliente(cliente_id);

    await avisar(
        barbero.usuario_id,
        "cita_nueva",
        "Nueva cita agendada",
        `${cliente} reservó ${servicio.nombre} para el ${fecha} a las ${horaLibre}.`,
        {
            cita_id: data.id,
            cliente_id,
            fecha,
            hora: horaLibre,
        }
    );

    return data;
};