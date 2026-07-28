import {
    listarBarberos,
    obtenerUno,
    registrarBarbero,
    editarBarbero,
    borrarBarbero
} from "../services/barberosService.js";

/* ===========================================
   LISTAR BARBEROS
=========================================== */

export const obtenerTodos = async (req, res, next) => {

    try {

        const barberos = await listarBarberos();

        res.status(200).json({
            success: true,
            total: barberos.length,
            data: barberos
        });

    } catch (error) {
        next(error);
    }

};

/* ===========================================
   OBTENER BARBERO POR ID
=========================================== */

export const obtenerPorId = async (req, res, next) => {

    try {

        const barbero = await obtenerUno(req.params.id);

        res.status(200).json({
            success: true,
            data: barbero
        });

    } catch (error) {
        next(error);
    }

};

/* ===========================================
   CREAR BARBERO
=========================================== */

export const crear = async (req, res, next) => {

    try {

        const barbero = await registrarBarbero(req.body);

        res.status(201).json({
            success: true,
            message: "Barbero creado correctamente.",
            data: barbero
        });

    } catch (error) {
        next(error);
    }

};

/* ===========================================
   ACTUALIZAR BARBERO
=========================================== */

export const actualizar = async (req, res, next) => {

    try {

        const barbero = await editarBarbero(
            req.params.id,
            req.body
        );

        res.status(200).json({
            success: true,
            message: "Barbero actualizado correctamente.",
            data: barbero
        });

    } catch (error) {
        next(error);
    }

};

/* ===========================================
   ELIMINAR BARBERO
=========================================== */

export const eliminar = async (req, res, next) => {

    try {

        await borrarBarbero(req.params.id);

        res.status(200).json({
            success: true,
            message: "Barbero eliminado correctamente."
        });

    } catch (error) {
        next(error);
    }

};