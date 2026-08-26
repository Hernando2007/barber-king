import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

import {
    buscarPorCorreo,
    crearUsuario,
    guardarTokenRecuperacion,
    actualizarPassword,
    limpiarToken,
    actualizarUltimoLogin
} from "../models/authModel.js";

import {
    enviarCodigoRecuperacion
} from "./emailService.js";

export const registrarUsuario = async (
    usuario
) => {

    const {
        rol_id,
        nombres,
        apellidos,
        correo,
        password
    } = usuario;

    if (
        !rol_id ||
        !nombres ||
        !apellidos ||
        !correo ||
        !password
    ) {

        throw new Error(
            "Todos los campos obligatorios deben ser enviados."
        );

    }

    const {
        data: existe
    } = await buscarPorCorreo(
        correo
    );

    if (existe) {

        throw new Error(
            "El correo ya está registrado."
        );

    }

    const passwordHash =
        await bcrypt.hash(
            password,
            10
        );

    const {
        data,
        error
    } = await crearUsuario({

        ...usuario,
        correo:
            correo
                .trim()
                .toLowerCase(),
        password:
            passwordHash

    });

    if (error) {

        throw new Error(
            error.message
        );

    }

    return data;

};

export const iniciarSesion = async ({
    correo,
    password
}) => {

    if (
        !correo ||
        !password
    ) {

        throw new Error(
            "Correo y contraseña son obligatorios."
        );

    }

    const {
        data: usuario
    } = await buscarPorCorreo(
        correo
            .trim()
            .toLowerCase()
    );

    if (!usuario) {

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

    await actualizarUltimoLogin(
        usuario.id
    );

    const token =
        jwt.sign(

            {
                id: usuario.id
            },

            process.env.JWT_SECRET,

            {
                expiresIn: "8h"
            }

        );

    delete usuario.password;

    return {

        token,
        usuario

    };

};

export const solicitarRecuperacion = async (
    correo
) => {

    const {
        data: usuario
    } = await buscarPorCorreo(
        correo
    );

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
        );

    const {
        error
    } =
        await guardarTokenRecuperacion(
            correo,
            codigo,
            expiracion
        );

    if (error) {

        throw new Error(
            error.message
        );

    }

    await enviarCodigoRecuperacion(
        correo,
        codigo
    );

    return true;

};

export const cambiarPassword = async (
    correo,
    codigo,
    nuevaPassword
) => {

    if (
        !correo ||
        !codigo ||
        !nuevaPassword
    ) {

        throw new Error(
            "Todos los campos son obligatorios."
        );

    }

    const {
        data: usuario
    } = await buscarPorCorreo(
        correo
    );

    if (!usuario) {

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
            nuevaPassword,
            10
        );

    const {
        error
    } =
        await actualizarPassword(
            usuario.id,
            passwordHash
        );

    if (error) {

        throw new Error(
            error.message
        );

    }

    await limpiarToken(
        usuario.id
    );

    return true;

};