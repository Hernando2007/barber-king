import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import crypto from "crypto";

import {
    buscarPorCorreo,
    crearUsuario,
    guardarTokenRecuperacion,
    buscarPorToken,
    actualizarPassword,
    limpiarToken
} from "../models/authModel.js";

import { enviarCorreoRecuperacion } from "./emailService.js";


// =====================================================
// REGISTRO
// =====================================================

export const registrarUsuario = async (usuario) => {

    const { data: existe } =
        await buscarPorCorreo(usuario.correo);

    if (existe) {
        throw new Error(
            "El correo ya está registrado."
        );
    }

    usuario.password =
        await bcrypt.hash(
            usuario.password,
            10
        );

    const { data, error } =
        await crearUsuario(usuario);

    if (error) {
        throw new Error(error.message);
    }

    return data;
};


// =====================================================
// LOGIN
// =====================================================

export const iniciarSesion = async ({
    correo,
    password
}) => {

    const {
        data: usuario,
        error
    } = await buscarPorCorreo(correo);

    if (error || !usuario) {
        throw new Error(
            "Correo o contraseña incorrectos."
        );
    }

    const coincide =
        await bcrypt.compare(
            password,
            usuario.password
        );

    if (!coincide) {
        throw new Error(
            "Correo o contraseña incorrectos."
        );
    }

    const token =
        jwt.sign(
            {
                id: usuario.id,
                rol: usuario.rol_id
            },
            process.env.JWT_SECRET,
            {
                expiresIn: "8h"
            }
        );

    return {
        token,
        usuario
    };
};


// =====================================================
// SOLICITAR RECUPERACIÓN
// =====================================================

export const solicitarRecuperacion = async (
    correo
) => {

    const {
        data: usuario,
        error
    } = await buscarPorCorreo(correo);

    // Por seguridad no revelamos si el correo existe
    if (error || !usuario) {
        return true;
    }

    // Generar token único
    const token =
        crypto.randomUUID();

    // El token será válido durante 30 minutos
    const expiracion =
        new Date(
            Date.now() +
            30 * 60 * 1000
        );

    // Guardar token en Supabase
    const {
        error: errorToken
    } =
        await guardarTokenRecuperacion(
            correo,
            token,
            expiracion
        );

    if (errorToken) {
        throw new Error(
            "No se pudo guardar el token de recuperación."
        );
    }

    // Enlace que llegará al correo
    const enlace =
    `barberking://reset-password?token=${token}`;

    // Enviar correo
    await enviarCorreoRecuperacion(
        correo,
        enlace
    );

    return true;
};


// =====================================================
// CAMBIAR CONTRASEÑA
// =====================================================

export const cambiarPassword = async (
    token,
    nuevaPassword
) => {

    if (!token) {
        throw new Error(
            "Token de recuperación requerido."
        );
    }

    if (!nuevaPassword) {
        throw new Error(
            "La nueva contraseña es obligatoria."
        );
    }

    if (nuevaPassword.length < 6) {
        throw new Error(
            "La contraseña debe tener mínimo 6 caracteres."
        );
    }

    // Buscar usuario por token
    const {
        data: usuario,
        error
    } =
        await buscarPorToken(token);

    if (error || !usuario) {
        throw new Error(
            "El enlace de recuperación no es válido."
        );
    }

    // Comprobar expiración
    const fechaExpiracion =
        new Date(
            usuario.token_expiracion
        );

    if (
        fechaExpiracion < new Date()
    ) {
        throw new Error(
            "El enlace de recuperación ha expirado."
        );
    }

    // Encriptar nueva contraseña
    const passwordHash =
        await bcrypt.hash(
            nuevaPassword,
            10
        );

    // Actualizar contraseña
    const {
        error: errorPassword
    } =
        await actualizarPassword(
            usuario.id,
            passwordHash
        );

    if (errorPassword) {
        throw new Error(
            errorPassword.message
        );
    }

    // Eliminar token para que no pueda reutilizarse
    const {
        error: errorToken
    } =
        await limpiarToken(
            usuario.id
        );

    if (errorToken) {
        throw new Error(
            errorToken.message
        );
    }

    return true;
};