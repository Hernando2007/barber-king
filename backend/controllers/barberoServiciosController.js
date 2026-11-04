import {
    obtenerServiciosDelBarbero,
} from "../models/barberoServiciosModel.js";
import {
    guardarServiciosDelBarbero,
    serviciosDelBarbero,
} from "../services/barberoServiciosService.js";
import { httpError } from "../utils/httpError.js";

export const obtenerMis = async (req, res, next) => {
    try {
        const servicios = await serviciosDelBarbero(req.usuario);

        return res.status(200).json({
            success: true,
            total: servicios.length,
            data: servicios,
        });
    } catch (error) {
        next(error);
    }
};

export const guardarMis = async (req, res, next) => {
    try {
        const servicios = await guardarServiciosDelBarbero(
            req.usuario,
            req.body?.servicios
        );

        return res.status(200).json({
            success: true,
            total: servicios.length,
            data: servicios,
            message: "Servicios actualizados.",
        });
    } catch (error) {
        next(error);
    }
};

// La ficha pública: qué hace este barbero y a qué precio.
export const obtenerDeBarbero = async (req, res, next) => {
    try {
        const barberoId = Number(req.params.barberoId);

        if (!Number.isInteger(barberoId) || barberoId <= 0) {
            throw httpError(400, "Barbero no válido.");
        }

        const { data, error } = await obtenerServiciosDelBarbero(barberoId);

        if (error) {
            throw httpError(500, error.message);
        }

        return res.status(200).json({
            success: true,
            total: (data || []).length,
            data: data || [],
        });
    } catch (error) {
        next(error);
    }
};
