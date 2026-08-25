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

    const { data: usuario, error } =
        await obtenerUsuarioPorCorreo(correo);

    if (error) {
        throw new Error(error.message);
    }

    // No revelar si el usuario existe
    if (!usuario) {
        return true;
    }

    // Token que recibirá el usuario
    const tokenPlano =
        crypto.randomBytes(32).toString("hex");

    // Hash que se almacenará en BD
    const tokenHash = crypto
        .createHash("sha256")
        .update(tokenPlano)
        .digest("hex");

    const expiracion = new Date(
        Date.now() + 15 * 60 * 1000
    ).toISOString();

    const resultado =
        await guardarTokenRecuperacion(
            usuario.id,
            tokenHash,
            expiracion
        );

    if (resultado.error) {
        throw new Error(
            resultado.error.message
        );
    }

    // Se envía el token plano
    await enviarCorreoRecuperacion(
        usuario.correo,
        tokenPlano
    );

    return true;
};

// Restablecer contraseña
export const restablecerContrasena = async (
    token,
    nuevaContrasena
) => {

    // Convertimos el token recibido a hash
    const tokenHash = crypto
        .createHash("sha256")
        .update(token)
        .digest("hex");

    const usuario =
        await obtenerUsuarioPorToken(
            tokenHash
        );

    if (!usuario) {
        throw new Error(
            "El enlace de recuperación es inválido o ha expirado."
        );
    }

    const hash =
        await bcrypt.hash(
            nuevaContrasena,
            10
        );

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