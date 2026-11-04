import {
    bandejaRevision,
    decidirRevision,
} from "../services/revisionBarberosService.js";
import { httpError } from "../utils/httpError.js";

export const pendientesRevision = async (req, res, next) => {
    try {
        const barberos = await bandejaRevision();

        return res.status(200).json({
            success: true,
            total: barberos.length,
            data: barberos,
        });
    } catch (error) {
        next(error);
    }
};

export const decidirPendiente = async (req, res, next) => {
    try {
        const id = Number(req.params.id);

        if (!Number.isInteger(id) || id <= 0) {
            throw httpError(400, "Barbero no válido.");
        }

        const resultado = await decidirRevision({
            barberoId: id,
            estado: req.body?.estado,
            revisorId: req.usuario?.id ?? null,
            nota: req.body?.nota,
        });

        return res.status(200).json({
            success: true,
            data: resultado,
            message: `Barbero ${resultado.verificacion_estado}.`,
        });
    } catch (error) {
        next(error);
    }
};
