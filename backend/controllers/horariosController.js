import {
    listarHorarios,
    crearHorarioBarbero,
    editarHorarioBarbero,
    eliminarHorarioBarbero
} from "../services/horariosService.js";
 
export const obtenerHorarios = async (req, res, next) => {
    try {
        const horarios = await listarHorarios(req.params.barbero_id);
 
        return res.status(200).json({
            success: true,
            data: horarios
        });
    } catch (error) {
        next(error);
    }
};
 
export const crear = async (req, res, next) => {
    try {
        const horario = await crearHorarioBarbero(
            req.usuario.id,
            req.body
        );
 
        return res.status(201).json({
            success: true,
            message: "Horario creado correctamente.",
            data: horario
        });
    } catch (error) {
        next(error);
    }
};
 
export const actualizar = async (req, res, next) => {
    try {
        const horario = await editarHorarioBarbero(
            req.usuario.id,
            req.params.id,
            req.body
        );
 
        return res.status(200).json({
            success: true,
            message: "Horario actualizado correctamente.",
            data: horario
        });
    } catch (error) {
        next(error);
    }
};
 
export const eliminar = async (req, res, next) => {
    try {
        await eliminarHorarioBarbero(
            req.usuario.id,
            req.params.id
        );
 
        return res.status(200).json({
            success: true,
            message: "Horario eliminado correctamente."
        });
    } catch (error) {
        next(error);
    }
};
