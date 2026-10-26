import { obtenerVerificaciones } from "../services/verificacionesService.js";

export const listarVerificacionesAdmin = async (req, res, next) => {
    try {
        const data = await obtenerVerificaciones({
            limite: req.query.limite,
            desde: req.query.desde,
        });

        return res.status(200).json({
            success: true,
            message: "Verificaciones obtenidas correctamente.",
            data,
        });
    } catch (error) {
        next(error);
    }
};
