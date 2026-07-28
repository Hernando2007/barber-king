import { obtenerDisponibilidad } from "../services/disponibilidadService.js";

export const consultarDisponibilidad = async (req, res) => {

    try {

        const {
            barbero_id,
            servicio_id,
            fecha
        } = req.query;

        const horarios = await obtenerDisponibilidad(
            barbero_id,
            servicio_id,
            fecha
        );

        res.json({
            success: true,
            horarios
        });

    } catch (error) {

        res.status(400).json({
            success: false,
            message: error.message
        });

    }

};