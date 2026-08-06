import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

import {
    buscarPorCorreo,
    crearUsuario
} from "../models/authModel.js";

export const registrarUsuario = async (usuario) => {

    const { data: existe } = await buscarPorCorreo(usuario.correo);

    if (existe) {
        throw new Error("El correo ya está registrado.");
    }

    usuario.password = await bcrypt.hash(usuario.password, 10);

    const { data, error } = await crearUsuario(usuario);

    if (error) {
        throw new Error(error.message);
    }

    return data;

};

export const iniciarSesion = async (datos) => {

    const correo = datos.correo;
    const password = datos.password || datos.contrasena;

    console.log("=================================");
    console.log("Correo recibido:", correo);
    console.log("Password recibida:", password);

    const { data: usuario, error } = await buscarPorCorreo(correo);

    console.log("Usuario encontrado:", usuario);
    console.log("Error Supabase:", error);

    if (error || !usuario) {
        throw new Error("Correo o contraseña incorrectos.");
    }

    console.log("Password BD:", usuario.password);

    const coincide = await bcrypt.compare(
        password,
        usuario.password
    );

    console.log("¿Coincide?:", coincide);
    console.log("=================================");

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