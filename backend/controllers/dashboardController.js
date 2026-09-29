import {
    dashboardGeneral,
    dashboardBarbero
} from "../services/dashboardService.js";
 
export const obtenerDashboardAdmin = async (req, res, next) => {
    try {
        const dashboard = await dashboardGeneral();
 
        return res.status(200).json({
            success: true,
            message: "Dashboard obtenido correctamente.",
            data: dashboard
        });
    } catch (error) {
        next(error);
    }
};
 
export const obtenerDashboardBarbero = async (req, res, next) => {
    try {
        const dashboard = await dashboardBarbero(req.usuario.id);
 
        return res.status(200).json({
            success: true,
            message: "Panel del barbero obtenido correctamente.",
            data: dashboard
        });
    } catch (error) {
        next(error);
    }
};
