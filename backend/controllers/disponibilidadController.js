import {
    obtenerDisponibilidad
} from "../services/disponibilidadService.js";

export const consultarDisponibilidad = async (
    req,
    res,
    next
) => {

    try {

        const {
            barbero_id,
            servicio_id,
            fecha
        } = req.query;

        if (
            !barbero_id ||
            !servicio_id ||
            !fecha
        ) {

            return res.status(400).json({
                success: false,
                message:
                    "barbero_id, servicio_id y fecha son obligatorios."
            });

        }

        const horarios =
            await obtenerDisponibilidad(
                barbero_id,
                servicio_id,
                fecha
            );

        return res.status(200).json({
            success: true,
            horarios
        });

    } catch (error) {

        next(error);

    }

};