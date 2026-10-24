import {
    obtenerContactosDirectos,
    obtenerConversacion,
    enviarMensajeDirecto,
} from "../services/chatDirectoService.js";

export const contactosDirectos = async (req, res, next) => {
    try {
        const data = await obtenerContactosDirectos(req.usuario);

        return res.status(200).json({
            success: true,
            total: data.length,
            data,
        });
    } catch (error) {
        next(error);
    }
};

export const mensajesDirectos = async (req, res, next) => {
    try {
        const data = await obtenerConversacion(
            req.usuario,
            req.params.contactoId,
            req.query.ultimo_id
        );

        return res.status(200).json({
            success: true,
            data,
        });
    } catch (error) {
        next(error);
    }
};

export const enviarDirecto = async (req, res, next) => {
    try {
        const data = await enviarMensajeDirecto(
            req.usuario,
            req.body
        );

        return res.status(201).json({
            success: true,
            message: "Mensaje enviado.",
            data,
        });
    } catch (error) {
        next(error);
    }
};
