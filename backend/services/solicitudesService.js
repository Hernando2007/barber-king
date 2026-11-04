import { httpError } from "../utils/httpError.js";
import { esMotivoValido, resolverRespuesta } from "../utils/respuestasSolicitud.js";
import {
    contarPendientesCliente,
    crearSolicitud,
    obtenerSolicitud,
    responderSolicitud,
} from "../models/solicitudesModel.js";
import { obtenerBarberoPorId } from "../models/barberosModel.js";
import {
    etiquetaMotivo,
    fechaPropuesta,
    leer,
    contar,
    notaBarbero,
    notaCliente,
    resolverDestino,
    avisar,
} from "../utils/solicitudesValidacion.js";

const MAX_PENDIENTES_POR_PAREJA = 3;

// Crear solicitudes: el cliente elige un motivo fijo y, si quiere, deja una
// línea de contexto. No es un chat: se responde una vez y se cierra.
export const solicitar = async (usuario, datos = {}) => {
    const barberoId = Number(datos.barbero_id);
    const motivo = String(datos.motivo || "").trim();

    if (!barberoId) {
        throw httpError(400, "Falta indicar el barbero.");
    }

    if (!esMotivoValido(motivo)) {
        throw httpError(400, "El motivo de la solicitud no es válido.");
    }

    const citaId = Number(datos.cita_id) || null;
    const servicioId = Number(datos.servicio_id) || null;

    const barbero = await resolverDestino(usuario, {
        barberoId,
        citaId,
        servicioId,
        motivo,
    });

    const pendientes = contar(
        await contarPendientesCliente({ clienteId: usuario.id, barberoId })
    );

    if (pendientes >= MAX_PENDIENTES_POR_PAREJA) {
        throw httpError(
            400,
            "Ya tienes varias solicitudes sin respuesta para este barbero."
        );
    }

    const creada = leer(
        await crearSolicitud({
            barbero_id: barberoId,
            cliente_id: usuario.id,
            cita_id: citaId,
            servicio_id: servicioId,
            motivo,
            fecha_propuesta: fechaPropuesta(datos.fecha_propuesta),
            nota: notaCliente(datos.nota),
        })
    );

    await avisar(
        barbero.usuario_id,
        "solicitud_nueva",
        "Nueva solicitud",
        `${usuario.nombres || "Un cliente"}: ${etiquetaMotivo(motivo)}`,
        { solicitud_id: creada.id, motivo, cliente_id: usuario.id }
    );

    return creada;
};

export const contestar = async (usuario, { id, respuesta, nota }) => {
    const solicitudId = Number(id);
    const clave = String(respuesta || "").trim();

    if (!solicitudId || !clave) {
        throw httpError(400, "Falta la solicitud o la respuesta.");
    }

    const actual = leer(await obtenerSolicitud(solicitudId));

    if (!actual) {
        throw httpError(404, "La solicitud no existe.");
    }

    const elegida = resolverRespuesta(actual.motivo, clave);

    if (!elegida) {
        throw httpError(400, "Esa respuesta no aplica a esta solicitud.");
    }

    const barbero = leer(await obtenerBarberoPorId(actual.barbero_id));

    if (Number(barbero?.usuario_id) !== Number(usuario.id)) {
        throw httpError(403, "Solo el barbero citado puede responder.");
    }

    if (actual.estado !== "pendiente") {
        throw httpError(409, "Esa solicitud ya fue respondida.");
    }

    const respondida = leer(
        await responderSolicitud(solicitudId, {
            estado: elegida.estado,
            respuesta: elegida.clave,
            respuesta_nota: notaBarbero(nota),
            respondido_at: new Date().toISOString(),
        })
    );

    await avisar(
        actual.cliente_id,
        "solicitud_respuesta",
        elegida.estado === "aceptada"
            ? "Te aceptaron la solicitud"
            : "Respuesta a tu solicitud",
        `${usuario.nombres || "Tu barbero"}: ${elegida.texto}`,
        {
            solicitud_id: solicitudId,
            motivo: actual.motivo,
            estado: elegida.estado,
        }
    );

    return respondida;
};
