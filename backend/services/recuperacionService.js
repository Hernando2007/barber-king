import crypto from "crypto";
import bcrypt from "bcrypt";

import {
    obtenerUsuarioPorCorreo,
    guardarTokenRecuperacion,
    obtenerUsuarioPorToken,
    actualizarContrasena
} from "../models/usuariosModel.js";

import {
    enviarCorreoRecuperacion
} from "./emailService.js";

// Solicitar recuperación de contraseña
export const solicitarRecuperacion = async (
    correo
) => {

    // Buscamos al usuario por su correo
    const { data: usuario, error } =
        await obtenerUsuarioPorCorreo(correo);

    if (error) {
        throw new Error(error.message);
    }

    // No revelamos si el correo existe o no
    if (!usuario) {
        return true;
    }

    // Generamos un token aleatorio
    const token =
        crypto.randomBytes(32).toString("hex");

    // El token será válido durante 15 minutos
    const expiracion =
        new Date(
            Date.now() + 15 * 60 * 1000
        );

    // Guardamos el token en la base de datos
    const resultado =
        await guardarTokenRecuperacion(
            usuario.id,
            token,
            expiracion
        );

    if (resultado.error) {
        throw new Error(
            resultado.error.message
        );
    }

    // Enviamos el correo
    await enviarCorreoRecuperacion(
        usuario.correo,
        token
    );

    return true;
};

// Restablecer contraseña
export const restablecerContrasena = async (
    token,
    nuevaContrasena
) => {

    // Buscamos el usuario mediante el token
    const usuario =
        await obtenerUsuarioPorToken(token);

    if (!usuario) {
        throw new Error(
            "El enlace de recuperación es inválido o ha expirado."
        );
    }

    // Encriptamos la nueva contraseña
    const hash =
        await bcrypt.hash(
            nuevaContrasena,
            10
        );

    // Actualizamos la contraseña
    const resultado =
        await actualizarContrasena(
            usuario.id,
            hash
        );

    if (resultado.error) {
        throw new Error(
            resultado.error.message
        );
    }

    // Eliminamos el token después de utilizarlo
    const limpiarToken =
        await guardarTokenRecuperacion(
            usuario.id,
            null,
            null
        );

    if (limpiarToken.error) {
        throw new Error(
            limpiarToken.error.message
        );
    }

    return true;
};