import {
    iniciarSesion,
    solicitarRecuperacion,
    cambiarPassword
} from "../services/authService.js";
import { registrarUsuario } from "../services/registroService.js";

// Registrar usuario (cliente o barbero)
export const registrar = async (req, res, next) => {
    try {
        const usuario = await registrarUsuario(req.body, req.files || {});

        return res.status(201).json({
            success: true,
            message: "Usuario registrado correctamente.",
            data: usuario
        });
    } catch (error) {
        next(error);
    }
};

// Inicio de sesión
export const login = async (req, res, next) => {
    try {
        const { correo, password } = req.body;

        const resultado = await iniciarSesion({ correo, password });

        return res.status(200).json({
            success: true,
            message: "Inicio de sesión exitoso.",
            token: resultado.token,
            usuario: resultado.usuario
        });
    } catch (error) {
        next(error);
    }
};

// Recuperación de contraseña
export const forgotPassword = async (req, res, next) => {
    try {
        const { correo } = req.body;

        await solicitarRecuperacion(correo);

        return res.status(200).json({
            success: true,
            message: "Si el correo existe, se envió un código de recuperación."
        });
    } catch (error) {
        next(error);
    }
};

// Restablecer contraseña
export const resetPassword = async (req, res) => {
    try {
        const { correo, codigo, password } = req.body;

        if (!correo || !codigo || !password) {
            return res.status(400).json({
                success: false,
                message: "Correo, código y contraseña son obligatorios."
            });
        }

        if (password.length < 6) {
            return res.status(400).json({
                success: false,
                message: "La contraseña debe tener mínimo 6 caracteres."
            });
        }

        await cambiarPassword(correo, codigo, password);

        return res.status(200).json({
            success: true,
            message: "Contraseña actualizada correctamente."
        });
    } catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message
        });
    }
};