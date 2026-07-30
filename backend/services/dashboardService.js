import { obtenerDashboard } from "../models/dashboardModel.js";

export const dashboardGeneral = async () => {

    const dashboard = await obtenerDashboard();

    return {

        success: true,

        message: "Dashboard obtenido correctamente.",

        data: dashboard

    };

};