import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

import {
    buscarPorCorreo,
    crearUsuario
} from "../models/authModel.js";

export const registrarUsuario = async (usuario) => {

    // Verificar si el correo ya existe
    const { data: existe } = await buscarPorCorreo(usuario.correo);

    if (existe) {
        throw new Error("El correo ya está registrado.");
    }

    // Encriptar contraseña
    usuario.password = await bcrypt.hash(usuario.password, 10);

    // Crear usuario
    const { data, error } = await crearUsuario(usuario);

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

export const iniciarSesion = async ({ correo, password }) => {

    const { data: usuario, error } = await buscarPorCorreo(correo);

    if (error || !usuario) {
        throw new Error("Correo o contraseña incorrectos.");
    }

    const coincide = await bcrypt.compare(
        password,
        usuario.password
    );

    if (!coincide) {
        throw new Error("Correo o contraseña incorrectos.");
    }

    const token = jwt.sign(
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