import crypto from "crypto";

import {
    obtenerUsuarioPorCorreo,
    guardarTokenRecuperacion,
    obtenerUsuarioPorToken,
    actualizarContrasena
} from "../models/usuariosModel.js";

import { enviarCorreoRecuperacion } from "./emailService.js";

import bcrypt from "bcrypt";

// Solicita la recuperación de contraseña
export const solicitarRecuperacion = async (correo) => {

    // Buscamos el usuario por su correo
    const usuario =
        await obtenerUsuarioPorCorreo(correo);

    // Por seguridad no revelamos si el correo existe
    if (!usuario) {
        return true;
    }

    // Generamos un token aleatorio
    const token =
        crypto.randomBytes(32).toString("hex");

    // El token tendrá una duración limitada
    const expiracion =
        new Date(Date.now() + 15 * 60 * 1000);

    // Guardamos el token y su fecha de expiración
    await guardarTokenRecuperacion(
        usuario.id,
        token,
        expiracion
    );

    // Enviamos el correo
    await enviarCorreoRecuperacion(
        usuario.correo,
        token
    );

    return true;
};

// Cambia la contraseña utilizando el token
export const restablecerContrasena = async (
    token,
    nuevaContrasena
) => {

    // Buscamos el usuario relacionado con el token
    const usuario =
        await obtenerUsuarioPorToken(token);

    if (!usuario) {
        throw new Error(
            "El enlace de recuperación es inválido o ha expirado."
        );
    }

    // Encriptamos la nueva contraseña
    const hash =
        await bcrypt.hash(nuevaContrasena, 10);

    // Actualizamos la contraseña
    await actualizarContrasena(
        usuario.id,
        hash
    );

    // Eliminamos el token para impedir reutilizarlo
    await guardarTokenRecuperacion(
        usuario.id,
        null,
        null
    );

    return true;
};