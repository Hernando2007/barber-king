import {
    listarServicios,
    listarMisServicios,
    obtenerUno,
    registrarServicio,
    editarServicio,
    borrarServicio
} from "../services/serviciosService.js";

export const obtenerTodos = async (req, res, next) => {
    try {
        const soloActivos = req.query.activos === "true";
        const servicios = await listarServicios({ soloActivos });

        return res.status(200).json({
            success: true,
            total: servicios.length,
            data: servicios
        });
    } catch (error) {
        next(error);
    }
};

export const obtenerMisServicios = async (req, res, next) => {
    try {
        const servicios = await listarMisServicios(req.usuario);

        return res.status(200).json({
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

        return res.status(200).json({
            success: true,
            data: servicio
        });
    } catch (error) {
        next(error);
    }
};

export const crear = async (req, res, next) => {
    try {
        const servicio = await registrarServicio(req.usuario, req.body);

        return res.status(201).json({
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
            req.usuario,
            req.params.id,
            req.body
        );

        return res.status(200).json({
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
        const forzar = req.query.forzar === "true";
        const resultado = await borrarServicio(
            req.usuario,
            req.params.id,
            { forzar }
        );

        return res.status(200).json({
            success: true,
            message: "Servicio eliminado correctamente.",
            data: resultado
        });
    } catch (error) {
        next(error);
    }
};
