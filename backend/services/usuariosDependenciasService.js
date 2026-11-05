import {
    contarCitasCliente,
    contarCitasBarbero,
    contarResenasCliente,
    contarResenasBarbero,
    contarMensajesUsuario,
    contarHorariosBarbero,
    obtenerIdsCitasDeUsuario,
    eliminarResenasDeUsuario,
    eliminarCitasDeUsuario,
    eliminarMensajesDeUsuario,
    eliminarHorariosDeBarbero,
} from "../models/usuariosDependenciasModel.js";
import { eliminarBarbero } from "../models/barberosModel.js";

/** Cuánto historial cuelga de una cuenta antes de borrarla o bajarla de rol. */
export const contarDependencias = async (usuarioId, barberoId = null) => {
    const [
        citasCliente,
        citasBarbero,
        resenasCliente,
        resenasBarbero,
        mensajes,
        horarios,
    ] = await Promise.all([
        contarCitasCliente(usuarioId),
        barberoId
            ? contarCitasBarbero(barberoId)
            : Promise.resolve({ count: 0 }),
        contarResenasCliente(usuarioId),
        barberoId
            ? contarResenasBarbero(barberoId)
            : Promise.resolve({ count: 0 }),
        contarMensajesUsuario(usuarioId),
        barberoId
            ? contarHorariosBarbero(barberoId)
            : Promise.resolve({ count: 0 }),
    ]);

    const error = [
        citasCliente.error,
        citasBarbero.error,
        resenasCliente.error,
        resenasBarbero.error,
        mensajes.error,
        horarios.error,
    ].find(Boolean);

    if (error) {
        throw new Error(error.message);
    }

    const resumen = {
        citas:
            (citasCliente.count || 0) +
            (citasBarbero.count || 0),
        resenas:
            (resenasCliente.count || 0) +
            (resenasBarbero.count || 0),
        mensajes: mensajes.count || 0,
        horarios: horarios.count || 0,
    };

    return {
        ...resumen,
        total:
            resumen.citas +
            resumen.resenas +
            resumen.mensajes +
            resumen.horarios,
    };
};

/** Borra el historial completo; asume que el administrador ya confirmó. */
export const eliminarDependencias = async (
    usuarioId,
    barberoId = null
) => {
    const { data: citas } = await obtenerIdsCitasDeUsuario(
        usuarioId,
        barberoId
    );

    const citaIds = (citas || []).map((cita) => cita.id);

    const { error: errorResenas } = await eliminarResenasDeUsuario({
        clienteId: usuarioId,
        barberoId,
        citaIds,
    });

    if (errorResenas) {
        throw new Error(errorResenas.message);
    }

    const { error: errorCitas } = await eliminarCitasDeUsuario(
        usuarioId,
        barberoId
    );

    if (errorCitas) {
        throw new Error(errorCitas.message);
    }

    if (barberoId) {
        const { error: errorHorarios } =
            await eliminarHorariosDeBarbero(barberoId);

        if (errorHorarios) {
            throw new Error(errorHorarios.message);
        }

        const { error: errorBarbero } = await eliminarBarbero(barberoId);

        if (errorBarbero) {
            throw new Error(errorBarbero.message);
        }
    }

    const { error: errorMensajes } = await eliminarMensajesDeUsuario(
        usuarioId
    );

    if (errorMensajes) {
        throw new Error(errorMensajes.message);
    }
};
