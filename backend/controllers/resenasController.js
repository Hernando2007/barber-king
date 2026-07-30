import {

    listarResenas,
    obtenerUnaResena,
    listarResenasPorBarbero,
    registrarResena,
    editarResena,
    borrarResena

} from "../services/resenasService.js";


export const obtenerTodas = async (req, res, next) => {

    try {

        const resenas = await listarResenas();

        res.status(200).json({
            success: true,
            total: resenas.length,
            data: resenas
        });

    } catch (error) {
        next(error);
    }

};


export const obtenerPorId = async (req, res, next) => {

    try {

        const resena = await obtenerUnaResena(req.params.id);

        res.status(200).json({
            success: true,
            data: resena
        });

    } catch (error) {
        next(error);
    }

};



export const obtenerPorBarbero = async (req, res, next) => {

    try {

        const resenas = await listarResenasPorBarbero(req.params.barbero_id);

        res.status(200).json({
            success: true,
            total: resenas.length,
            data: resenas
        });

    } catch (error) {
        next(error);
    }

};


export const crear = async (req, res, next) => {

    try {

        const resena = await registrarResena(req.body);

        res.status(201).json({
            success: true,
            message: "Reseña creada correctamente.",
            data: resena
        });

    } catch (error) {
        next(error);
    }

};



export const actualizar = async (req, res, next) => {

    try {

        const resena = await editarResena(
            req.params.id,
            req.body
        );

        res.status(200).json({
            success: true,
            message: "Reseña actualizada correctamente.",
            data: resena
        });

    } catch (error) {
        next(error);
    }

};



export const eliminar = async (req, res, next) => {

    try {

        await borrarResena(req.params.id);

        res.status(200).json({
            success: true,
            message: "Reseña eliminada correctamente."
        });

    } catch (error) {
        next(error);
    }

};