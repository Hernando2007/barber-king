import bcrypt from "bcrypt";

import {
    obtenerUsuarioPorCorreo,
    guardarTokenRecuperacion,
    actualizarContrasena
} from "../models/usuariosModel.js";

import {
    enviarCodigoRecuperacion
} from "./emailService.js";

export const solicitarRecuperacion = async (
    correo
) => {

    const {
        data: usuario,
        error
    } =
        await obtenerUsuarioPorCorreo(
            correo
        );

    if (error) {

        throw new Error(
            error.message
        );

    }

    if (!usuario) {

        return true;

    }

    const codigo =
        Math.floor(
            100000 +
            Math.random() * 900000
        ).toString();

    const expiracion =
        new Date(
            Date.now() +
            15 * 60 * 1000
        ).toISOString();

    const resultado =
        await guardarTokenRecuperacion(
            usuario.id,
            codigo,
            expiracion
        );

    if (resultado.error) {

        throw new Error(
            resultado.error.message
        );

    }

    await enviarCodigoRecuperacion(
        usuario.correo,
        codigo
    );

    return true;

};

export const restablecerContrasena = async (
    correo,
    codigo,
    password
) => {

    const {
        data: usuario,
        error
    } =
        await obtenerUsuarioPorCorreo(
            correo
        );

    if (
        error ||
        !usuario
    ) {

        throw new Error(
            "Código inválido."
        );

    }

    if (
        usuario.token_recuperacion !==
        codigo
    ) {

        throw new Error(
            "Código inválido."
        );

    }

    if (
        !usuario.token_expiracion ||
        new Date(
            usuario.token_expiracion
        ) < new Date()
    ) {

        throw new Error(
            "El código ha expirado."
        );

    }

    const passwordHash =
        await bcrypt.hash(
            password,
            10
        );

    const resultado =
        await actualizarContrasena(
            usuario.id,
            passwordHash
        );

    if (resultado.error) {

        throw new Error(
            resultado.error.message
        );

    }

    await guardarTokenRecuperacion(
        usuario.id,
        null,
        null
    );

    return true;

};