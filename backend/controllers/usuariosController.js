import {
    listarUsuarios,
    buscarUsuario,
    obtenerPerfilCompleto,
    crearUsuarioAdmin,
    actualizarUsuarioAdmin,
    eliminarUsuarioAdmin,
    actualizarMiPerfil,
    guardarFotoPerfil,
    guardarDiplomaBarbero,
} from "../services/usuariosService.js";

export const getUsuarios = async (req, res, next) => {
    try {
        const usuarios = await listarUsuarios();

        return res.status(200).json({
            success: true,
            total: usuarios.length,
            data: usuarios,
        });
    } catch (error) {
        next(error);
    }
};

export const getUsuario = async (req, res, next) => {
    try {
        const usuario = await buscarUsuario(req.params.id);

        return res.status(200).json({
            success: true,
            data: usuario,
        });
    } catch (error) {
        next(error);
    }
};

export const getPerfilActual = async (req, res, next) => {
    try {
        const data = await obtenerPerfilCompleto(req.usuario.id);

        return res.status(200).json({
            success: true,
            data,
        });
    } catch (error) {
        next(error);
    }
};

export const putPerfilActual = async (req, res, next) => {
    try {
        const data = await actualizarMiPerfil(req.usuario, req.body);

        return res.status(200).json({
            success: true,
            message: "Perfil actualizado correctamente.",
            data,
        });
    } catch (error) {
        next(error);
    }
};

export const putFotoPerfil = async (req, res, next) => {
    try {
        const data = await guardarFotoPerfil(req.usuario, req.file);

        return res.status(200).json({
            success: true,
            message: "Foto de perfil actualizada.",
            data,
        });
    } catch (error) {
        next(error);
    }
};

export const putDiploma = async (req, res, next) => {
    try {
        const data = await guardarDiplomaBarbero(req.usuario, req.file);

        return res.status(200).json({
            success: true,
            message: "Diploma actualizado correctamente.",
            data,
        });
    } catch (error) {
        next(error);
    }
};

export const crearUsuario = async (req, res, next) => {
    try {
        const usuario = await crearUsuarioAdmin(req.usuario, req.body);

        return res.status(201).json({
            success: true,
            message: "Usuario creado correctamente.",
            data: usuario,
        });
    } catch (error) {
        next(error);
    }
};

export const actualizarUsuario = async (req, res, next) => {
    try {
        const usuario = await actualizarUsuarioAdmin(
            req.usuario,
            req.params.id,
            req.body
        );

        return res.status(200).json({
            success: true,
            message: "Usuario actualizado correctamente.",
            data: usuario,
        });
    } catch (error) {
        next(error);
    }
};

export const eliminarUsuario = async (req, res, next) => {
    try {
        const resultado = await eliminarUsuarioAdmin(
            req.usuario,
            req.params.id,
            { forzar: req.query.forzar === "true" }
        );

        return res.status(200).json({
            success: true,
            message: "Usuario eliminado correctamente.",
            data: resultado,
        });
    } catch (error) {
        next(error);
    }
};
