import {
    enviarMensaje,
    obtenerHistorial,
} from "../services/chatService.js";
import { recomendarCorte } from "../services/chatVisionService.js";
import { subirImagenCloudinary } from "../services/cloudinaryService.js";
import { httpError } from "../utils/httpError.js";

export const chatearConBarberKing = async (req, res, next) => {
    try {
        const { mensaje, sesionId } = req.body || {};
        const usuarioId = req.usuario?.id;

        if (!usuarioId) {
            throw httpError(
                401,
                "No se encontró un usuario autenticado válido."
            );
        }

        if (!mensaje || !String(mensaje).trim()) {
            throw httpError(400, "Debes enviar un mensaje.");
        }

        const resultado = await enviarMensaje(
            String(mensaje).trim(),
            usuarioId,
            sesionId
        );

        return res.status(200).json({
            success: true,
            respuesta: resultado.respuesta,
            sesionId: resultado.sesionId,
        });
    } catch (error) {
        next(error);
    }
};

export const recomendarCorteConIA = async (req, res, next) => {
    try {
        if (!req.file) {
            throw httpError(400, "Debes enviar una imagen.");
        }

        const usuarioId = req.usuario?.id;

        if (!usuarioId) {
            throw httpError(401, "Sesión inválida o expirada.");
        }

        const imagen = await subirImagenCloudinary(
            req.file,
            "barber-king/chat"
        );

        const imagenDataUri = `data:${req.file.mimetype};base64,${req.file.buffer.toString("base64")}`;
        const imagenUrl = imagen.url;

        const resultado = await recomendarCorte(
            imagenDataUri,
            imagenUrl,
            usuarioId,
            req.body?.sesionId
        );

        return res.status(200).json({
            success: true,
            sesionId: resultado.sesionId,
            imagenUrl: resultado.imagenUrl,
            recomendacion: resultado.recomendacion,
        });
    } catch (error) {
        next(error);
    }
};

export const obtenerHistorialBarberKing = async (req, res, next) => {
    try {
        const { sesionId } = req.params;
        const usuarioId = req.usuario?.id;

        if (!usuarioId) {
            throw httpError(
                401,
                "Acceso denegado. Se requiere token válido."
            );
        }

        if (!sesionId) {
            throw httpError(400, "La sesión es obligatoria.");
        }

        const historial = await obtenerHistorial(
            sesionId,
            usuarioId
        );

        return res.status(200).json({
            success: true,
            historial,
        });
    } catch (error) {
        next(error);
    }
};
