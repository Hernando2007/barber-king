import { leerNovedadesAvisos } from "../services/avisosService.js";

export const novedadesAvisos = async (req, res, next) => {
    try {
        const data = await leerNovedadesAvisos(req.usuario, {
            desdeId: Number(req.query?.desde_id) || 0,
            limite: Number(req.query?.limite) || 30,
        });

        return res.status(200).json({ success: true, data });
    } catch (error) {
        next(error);
    }
};
