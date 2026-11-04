import { catalogoSolicitudes, resumenSolicitudes, leerSolicitudes } from "../services/solicitudesLecturaService.js";
import { contestar, solicitar } from "../services/solicitudesService.js";
import { httpError } from "../utils/httpError.js";

export const motivosSolicitud = (req, res) => {
    return res.status(200).json({
        success: true,
        data: catalogoSolicitudes(),
    });
};

export const misSolicitudes = async (req, res, next) => {
    try {
        const data = await leerSolicitudes(req.usuario, {
            estado: req.query?.estado || null,
            limite: Number(req.query?.limite) || 60,
        });

        return res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};

export const resumen = async (req, res, next) => {
    try {
        return res.status(200).json({
            success: true,
            data: await resumenSolicitudes(req.usuario),
        });
    } catch (error) {
        next(error);
    }
};

export const crearSolicitudController = async (req, res, next) => {
    try {
        const solicitud = await solicitar(req.usuario, req.body);

        return res.status(201).json({
            success: true,
            message: "Solicitud enviada.",
            data: solicitud,
        });
    } catch (error) {
        next(error);
    }
};

export const responderSolicitudController = async (req, res, next) => {
    try {
        const id = Number(req.params.id);

        if (!Number.isInteger(id) || id <= 0) {
            throw httpError(400, "Solicitud no válida.");
        }

        const solicitud = await contestar(req.usuario, {
            id,
            respuesta: req.body?.respuesta,
            nota: req.body?.nota,
        });

        return res.status(200).json({
            success: true,
            message: "Respuesta enviada.",
            data: solicitud,
        });
    } catch (error) {
        next(error);
    }
};
