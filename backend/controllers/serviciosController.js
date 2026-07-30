import {
    listarServicios,
    obtenerUno,
    registrarServicio,
    editarServicio,
    borrarServicio
} from "../services/serviciosService.js";


export const obtenerTodos = async (req, res, next) => {

    try {

        const servicios = await listarServicios();

        res.status(200).json({
            success: true,
            total: servicios.length,
            data: servicios
        });

    } catch (error) {
        next(error);
    }

};


export const obtenerPorId = async (req, res, next) => {

    try {

        const servicio = await obtenerUno(req.params.id);

        res.status(200).json({
            success: true,
            data: servicio
        });

    } catch (error) {
        next(error);
    }

};


export const crear = async (req, res, next) => {

    try {

        const servicio = await registrarServicio(req.body);

        res.status(201).json({
            success: true,
            message: "Servicio creado correctamente.",
            data: servicio
        });

    } catch (error) {
        next(error);
    }

};


export const actualizar = async (req, res, next) => {

    try {

        const servicio = await editarServicio(
            req.params.id,
            req.body
        );

        res.status(200).json({
            success: true,
            message: "Servicio actualizado correctamente.",
            data: servicio
        });

    } catch (error) {
        next(error);
    }

};


export const eliminar = async (req, res, next) => {

    try {

        await borrarServicio(req.params.id);

        res.status(200).json({
            success: true,
            message: "Servicio eliminado correctamente."
        });

    } catch (error) {
        next(error);
    }

};