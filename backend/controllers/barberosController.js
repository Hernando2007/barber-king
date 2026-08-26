import {
    listarBarberos,
    obtenerUno,
    registrarBarbero,
    editarBarbero,
    borrarBarbero
} from "../services/barberosService.js";

export const obtenerTodos = async (
    req,
    res,
    next
) => {

    try {

        const barberos =
            await listarBarberos();

        return res.status(200).json({
            success: true,
            total: barberos.length,
            data: barberos
        });

    } catch (error) {

        next(error);

    }

};

export const obtenerPorId = async (
    req,
    res,
    next
) => {

    try {

        const barbero =
            await obtenerUno(
                req.params.id
            );

        return res.status(200).json({
            success: true,
            data: barbero
        });

    } catch (error) {

        next(error);

    }

};

export const crear = async (
    req,
    res,
    next
) => {

    try {

        const barbero =
            await registrarBarbero(
                req.body
            );

        return res.status(201).json({
            success: true,
            message:
                "Barbero creado correctamente.",
            data: barbero
        });

    } catch (error) {

        next(error);

    }

};

export const actualizar = async (
    req,
    res,
    next
) => {

    try {

        const barbero =
            await editarBarbero(
                req.params.id,
                req.body
            );

        return res.status(200).json({
            success: true,
            message:
                "Barbero actualizado correctamente.",
            data: barbero
        });

    } catch (error) {

        next(error);

    }

};

export const eliminar = async (
    req,
    res,
    next
) => {

    try {

        await borrarBarbero(
            req.params.id
        );

        return res.status(200).json({
            success: true,
            message:
                "Barbero eliminado correctamente."
        });

    } catch (error) {

        next(error);

    }

};