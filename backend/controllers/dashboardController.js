import {
    dashboardGeneral
} from "../services/dashboardService.js";

export const obtenerDashboardAdmin = async (
    req,
    res,
    next
) => {

    try {

        const dashboard =
            await dashboardGeneral();

        return res.status(200).json({
            success: true,
            message:
                "Dashboard obtenido correctamente.",
            data: dashboard
        });

    } catch (error) {

        next(error);

    }

};