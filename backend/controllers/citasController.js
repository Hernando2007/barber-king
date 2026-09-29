import {
    registrarCita,
    obtenerTodasLasCitas,
    obtenerUnaCita,
    obtenerCitasUsuario,
    editarCita,
    borrarCita
} from "../services/citasService.js";
 
export const crearCita = async (req, res, next) => {
    try {
        const cita = await registrarCita({
            ...req.body,
            cliente_id: req.usuario.id
        });
 
        return res.status(201).json({
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
        const citas = await obtenerCitasUsuario(req.usuario);
 
        return res.status(200).json({
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
        const citasUsuario = await obtenerCitasUsuario(req.usuario);
 
        const permitido = citasUsuario.some(
            (item) => Number(item.id) === Number(cita.id)
        );
 
        if (!permitido) {
            return res.status(403).json({
                success: false,
                message: "No tienes acceso a esta cita."
            });
        }
 
        return res.status(200).json({
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
            req.body,
            req.usuario
        );
 
        return res.status(200).json({
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
        await borrarCita(req.params.id, req.usuario);
 
        return res.status(200).json({
            success: true,
            message: "Cita eliminada correctamente."
        });
    } catch (error) {
        next(error);
    }
};
