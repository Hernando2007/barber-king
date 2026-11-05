import { httpError } from "../utils/httpError.js";
import { listarMotivos, opcionesPara } from "../utils/respuestasSolicitud.js";
import {
    contarPendientesBarbero,
    listarPorBarbero,
    listarPorCliente,
} from "../models/solicitudesModel.js";
import { listarNovedades } from "../models/avisosModel.js";
import { obtenerBarberoPorUsuario } from "../models/barberosModel.js";
import { contar, leer } from "../utils/solicitudesValidacion.js";

// Cada solicitud viaja con sus botones ya resueltos: la app no duplica el
// catálogo de respuestas y cliente y barbero siempre leen el mismo texto.
const nombre = (persona) =>
    [persona?.nombres, persona?.apellidos]
        .filter(Boolean)
        .join(" ")
        .trim();

const pintar = (fila) => {
    const opciones = fila.estado === "pendiente" ? opcionesPara(fila.motivo) : [];
    const respondida =
        opcionesPara(fila.motivo).find(
            (opcion) => opcion.clave === fila.respuesta
        )?.texto || null;

    return {
        ...fila,
        motivo_etiqueta:
            listarMotivos().find((motivo) => motivo.clave === fila.motivo)
                ?.etiqueta || fila.motivo,
        barbero_nombre: nombre(fila.barberos?.usuarios),
        cliente_nombre: nombre(fila.usuarios),
        opciones,
        respuesta_texto:
            respondida || fila.respuesta_nota || fila.nota || null,
    };
};

const bandeja = async (usuario, { estado = null, limite = 60 } = {}) => {
    const perfil = leer(await obtenerBarberoPorUsuario(usuario.id));

    if (!perfil) {
        throw httpError(404, "Tu perfil de barbero no existe.");
    }

    const lista = leer(
        await listarPorBarbero({
            barberoId: perfil.id,
            estado,
            limite,
        })
    );

    return {
        barbero_id: perfil.id,
        pendientes: contar(await contarPendientesBarbero(perfil.id)),
        solicitudes: (lista || []).map(pintar),
    };
};

const enviadas = async (usuario, { limite = 60 } = {}) => {
    const lista = leer(
        await listarPorCliente({ clienteId: usuario.id, limite })
    );

    const todas = lista || [];

    return {
        pendientes: todas.filter((fila) => fila.estado === "pendiente").length,
        solicitudes: todas.map(pintar),
    };
};

const novedades = async (usuario, { desdeId = 0, limite = 30 } = {}) => {
    const consulta = await listarNovedades({
        usuarioId: usuario.id,
        desdeId,
        limite,
    });

    // Un aviso que no se pudo leer no puede tumbar el polling: la app vuelve
    // a preguntar en el siguiente ciclo.
    if (consulta.error) {
        return { avisos: [], ultimo_id: Number(desdeId) || 0 };
    }

    const lista = (consulta.data || []).slice().reverse();

    return {
        avisos: lista.map((aviso) => ({
            id: aviso.id,
            tipo: aviso.tipo,
            titulo: aviso.titulo,
            cuerpo: aviso.cuerpo,
            datos: aviso.datos || {},
            creado: aviso.created_at,
        })),
        ultimo_id: lista.length ? lista[lista.length - 1].id : Number(desdeId) || 0,
    };
};

export const leerSolicitudes = async (usuario, consulta = {}) => {
    const rol = String(usuario?.rol || "");

    if (rol === "Barbero") {
        return bandeja(usuario, consulta);
    }

    if (rol === "Cliente") {
        return enviadas(usuario, consulta);
    }

    throw httpError(403, "Solo el barbero y el cliente ven sus solicitudes.");
};

// Solo el número, sin joins: es lo que preguntan el badge y el polling.
export const resumenSolicitudes = async (usuario) => {
    const rol = String(usuario?.rol || "");

    if (rol === "Barbero") {
        const perfil = leer(await obtenerBarberoPorUsuario(usuario.id));

        if (!perfil) {
            throw httpError(404, "Tu perfil de barbero no existe.");
        }

        return { pendientes: contar(await contarPendientesBarbero(perfil.id)) };
    }

    if (rol === "Cliente") {
        const todas =
            leer(await listarPorCliente({ clienteId: usuario.id, limite: 60 })) ||
            [];

        return {
            pendientes: todas.filter(
                (fila) => fila.estado === "pendiente"
            ).length,
        };
    }

    throw httpError(403, "Solo el barbero y el cliente ven su resumen.");
};

export const catalogoSolicitudes = () => ({
    motivos: listarMotivos().map((motivo) => ({
        ...motivo,
        opciones: opcionesPara(motivo.clave),
    })),
});

export const leerNovedadesAvisos = (usuario, consulta) =>
    novedades(usuario, consulta);
