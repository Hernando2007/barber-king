import { dashboardGeneral } from "../services/dashboardService.js";

import { successResponse } from "../utils/response.js";

export const obtenerDashboardAdmin = async (

    req,

    res,

    next

) => {

    try {

        const dashboard = await dashboardGeneral();

        return successResponse(

            res,

            "Dashboard obtenido correctamente.",

            dashboard.data

        );

    } catch (error) {

        next(error);

    }

};