import {
    actualizarBarbero,
    obtenerBarberoPorId,
    obtenerBarberosPendientesRevision,
} from "../models/barberosModel.js";
import {
    decidirVerificacion,
    listarVerificacionesPorUsuarios,
} from "../models/verificacionesModel.js";
import { httpError } from "../utils/httpError.js";
import { texto } from "./authComun.js";

const VEREDICTOS = ["aprobado", "rechazado"];

const esColumnaRevisionFaltante = (error) =>
    error?.code === "42703" || error?.code === "PGRST204";

const nombreCompleto = (barbero) => {
    const u = barbero.usuarios || {};

    return [u.nombres, u.apellidos]
        .map((parte) => texto(parte))
        .filter(Boolean)
        .join(" ");
};

// El diploma sigue guardado en barberos.portafolio; la bandeja lo abre
// para que el administrador compare con lo que dijo la IA.
const diplomaDe = (barbero) => {
    const documentos = Array.isArray(barbero.portafolio)
        ? barbero.portafolio
        : [];
    const diploma = documentos.find((item) => item?.tipo === "diploma");

    return diploma?.url ? { url: diploma.url, nombre: diploma.nombre || "documento" } : null;
};

const opinionDeLaIA = (verificacion) =>
    verificacion
        ? {
            id: verificacion.id,
            estado: verificacion.estado,
            es_valido: verificacion.es_valido,
            confianza: verificacion.confianza,
            motivo: verificacion.motivo,
            institucion: verificacion.institucion,
            titular: verificacion.titular,
            revisado_por: verificacion.revisado_por,
            revisado_at: verificacion.revisado_at,
            nota_administrador: verificacion.nota_administrador,
            revisado_en: verificacion.created_at,
        }
        : null;

export const bandejaRevision = async () => {
    const { data: barberos, error } = await obtenerBarberosPendientesRevision({
        limite: 200,
    });

    if (error) {
        throw httpError(500, error.message);
    }

    const usuarioIds = (barberos || [])
        .map((b) => Number(b.usuario_id))
        .filter((id) => Number.isInteger(id) && id > 0);

    const { data: verificaciones } =
        await listarVerificacionesPorUsuarios(usuarioIds);

    // El listado ya viene ordenado del más reciente al más antiguo.
    const ultimaPorUsuario = new Map();
    for (const v of verificaciones || []) {
        const clave = Number(v.usuario_id);

        if (clave && !ultimaPorUsuario.has(clave)) {
            ultimaPorUsuario.set(clave, v);
        }
    }

    return (barberos || []).map((barbero) => ({
        barbero_id: barbero.id,
        usuario_id: barbero.usuario_id,
        nombre: nombreCompleto(barbero),
        correo: barbero.usuarios?.correo || null,
        telefono: barbero.usuarios?.telefono || null,
        especialidad: barbero.especialidad || null,
        experiencia: barbero.experiencia ?? null,
        verificacion_estado: barbero.verificacion_estado || "pendiente",
        diploma: diplomaDe(barbero),
        ia: opinionDeLaIA(ultimaPorUsuario.get(Number(barbero.usuario_id))),
    }));
};

export const decidirRevision = async ({
    barberoId,
    estado,
    revisorId,
    nota,
}) => {
    const veredicto = String(estado || "").toLowerCase();

    if (!VEREDICTOS.includes(veredicto)) {
        throw httpError(400, "La decisión debe ser aprobado o rechazado.");
    }

    const id = Number(barberoId);

    if (!Number.isInteger(id) || id <= 0) {
        throw httpError(400, "Barbero no válido.");
    }

    const { data: barbero, error: errorBusqueda } =
        await obtenerBarberoPorId(id);

    if (errorBusqueda) {
        throw httpError(500, errorBusqueda.message);
    }

    if (!barbero) {
        throw httpError(404, "Ese barbero no existe.");
    }

    const { error: errorBarbero } = await actualizarBarbero(id, {
        verificacion_estado: veredicto,
    });

    if (errorBarbero) {
        throw httpError(500, errorBarbero.message);
    }

    // Se anota la auditoría más reciente, si la IA llegó a opinar. Fallar
    // aquí no deshace la decisión del barbero.
    const { data: verificaciones } = await listarVerificacionesPorUsuarios([
        Number(barbero.usuario_id),
    ]);

    const masReciente = verificaciones?.[0];
    let auditoria = null;

    if (masReciente) {
        const resultado = await decidirVerificacion({
            id: masReciente.id,
            estado: veredicto,
            revisorId,
            nota: texto(nota),
        });

        if (resultado.error && esColumnaRevisionFaltante(resultado.error)) {
            console.warn(
                "⚠️ Falta la migración 15: la decisión no quedó anotada en la auditoría.",
            );
        } else if (resultado.error) {
            console.warn("⚠️ No se pudo anotar la auditoría:", resultado.error.message);
        } else {
            auditoria = resultado.data;
        }
    }

    return {
        barbero_id: id,
        verificacion_estado: veredicto,
        auditoria,
    };
};
