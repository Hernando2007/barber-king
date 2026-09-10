import {
    enviarMensaje,
    recomendarCorte,
    obtenerHistorial
} from "../services/chatService.js";

export const chatearConBarberKing = async (req, res) => {
    try {
        const { mensaje, sesionId } = req.body;
        const usuarioId = req.usuario?.id;

        if (!mensaje || !mensaje.trim()) {
            return res.status(400).json({
                success: false,
                message: "Debes enviar un mensaje."
            });
        }

        const resultado = await enviarMensaje(
            mensaje,
            usuarioId,
            sesionId
        );

        return res.status(200).json({
            success: true,
            ...resultado
        });

    } catch (error) {
        console.error("Error en chat:", error);

        return res.status(500).json({
            success: false,
            message: "Error al procesar el mensaje."
        });
    }
};

export const recomendarCorteConIA = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: "Debes enviar una imagen."
            });
        }

        const usuarioId = req.usuario?.id;
        const sesionId = req.body.sesionId;

        // req.file.path contiene la URL de Cloudinary
        const imagenUrl = req.file.path;

        const resultado = await recomendarCorte(
            imagenUrl,
            usuarioId,
            sesionId
        );

        return res.status(200).json({
            success: true,
            ...resultado
        });

    } catch (error) {
        console.error(
            "Error recomendando corte:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "No se pudo generar la recomendación.",
            error: error.message
        });
    }
};

export const obtenerHistorialBarberKing = async (
    req,
    res
) => {
    try {
        const { sesionId } = req.params;
        const usuarioId = req.usuario?.id;

        const historial = await obtenerHistorial(
            sesionId,
            usuarioId
        );

        return res.status(200).json({
            success: true,
            historial
        });

    } catch (error) {
        console.error(
            "Error obteniendo historial:",
            error
        );

        return res.status(500).json({
            success: false,
            message: "Error obteniendo el historial."
        });
    }
};