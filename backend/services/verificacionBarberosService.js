import { crearVerificacion } from "../models/verificacionesModel.js";
import { actualizarBarbero } from "../models/barberosModel.js";
import { httpError } from "../utils/httpError.js";
import {
    MODELO_VISION,
    analizarDocumento,
    descargarBase64,
} from "./verificacionBarberosIA.js";

export const esColumnaEstadoFaltante = (error) =>
    error?.code === "42703" || error?.code === "PGRST204";

const registrarAuditoria = async (resultado, contexto) => {
    await crearVerificacion({
        barberoId: contexto.barberoId,
        usuarioId: contexto.usuarioId,
        documentoUrl: contexto.documentoUrl,
        documentoNombre: contexto.documentoNombre,
        origen: contexto.origen,
        modelo: MODELO_VISION,
        ...resultado,
    }).catch((error) => {
        console.warn("⚠️ Auditoría de verificación no guardada:", error.message);
    });
};

export const verificarDiplomaBarbero = async ({
    urlPublica,
    mimetype,
    nombreOriginal,
    origen = "registro",
    usuarioId = null,
    barberoId = null,
}) => {
    if (mimetype === "application/pdf") {
        throw httpError(
            400, "La verificación automática solo acepta imágenes JPG, PNG o WEBP."
        );
    }

    const base64 = await descargarBase64(urlPublica);

    if (!base64) {
        throw httpError(400, "Adjunta el diploma o certificado de barbería.");
    }

    const mime = mimetype || "image/jpeg";
    const resultado = await analizarDocumento(`data:${mime};base64,${base64}`);

    await registrarAuditoria(resultado, {
        barberoId,
        usuarioId,
        documentoUrl: urlPublica,
        documentoNombre: nombreOriginal,
        origen,
    });

    if (!resultado.esValido) {
        // El documento se guarda en Cloudinary aunque la IA lo rechace:
        // la bandeja del administrador necesita poder abrirlo.
        throw httpError(
            422,
            `El documento no pasó la verificación: ${
                resultado.motivo ||
                "no se identificó como un diploma o certificado real de barbería."
            }`
        );
    }

    return resultado;
};

export const marcarBarberoVerificado = async (barberoId) => {
    if (!barberoId) return;

    const { error } = await actualizarBarbero(barberoId, {
        verificacion_estado: "aprobado",
    });

    if (error && !esColumnaEstadoFaltante(error)) {
        console.warn(
            "⚠️ No se pudo actualizar verificacion_estado:",
            error.message
        );
    }
};
