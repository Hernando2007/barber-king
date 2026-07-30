import {
    registrarCita,
    obtenerTodasLasCitas,
    obtenerUnaCita,
    editarCita,
    borrarCita
} from "../services/citasService.js";


export const crearCita = async (req, res, next) => {

    try {

        const cita = await registrarCita(req.body);

        res.status(201).json({
            success: true,
            message: "Cita creada correctamente.",
            data: cita
        });

    } catch (error) {
        next(error);
    }

};


export const obtenerTodas = async (req, res, next) => {

    try {

        const citas = await obtenerTodasLasCitas();

        res.status(200).json({
            success: true,
            total: citas.length,
            data: citas
        });

    } catch (error) {
        next(error);
    }

};


export const obtenerPorId = async (req, res, next) => {

    try {

        const cita = await obtenerUnaCita(req.params.id);

        res.status(200).json({
            success: true,
            data: cita
        });

    } catch (error) {
        next(error);
    }

};


export const actualizar = async (req, res, next) => {

    try {

        const cita = await editarCita(
            req.params.id,
            req.body
        );

        res.status(200).json({
            success: true,
            message: "Cita actualizada correctamente.",
            data: cita
        });

    } catch (error) {
        next(error);
    }

};


export const eliminar = async (req, res, next) => {

    try {

        await borrarCita(req.params.id);

        res.status(200).json({
            success: true,
            message: "Cita eliminada correctamente."
        });

    } catch (error) {
        next(error);
    }

};