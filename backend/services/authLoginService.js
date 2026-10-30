import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { buscarPorCorreo, actualizarUltimoLogin } from "../models/authModel.js";
import { httpError } from "../utils/httpError.js";
import { nombreRol, quitarDatosSensibles } from "./authComun.js";

export const iniciarSesion = async ({ correo, password }) => {
    if (!correo || !password) {
        throw httpError(
            400,
            "Correo y contraseña son obligatorios."
        );
    }

    const email = String(correo).trim().toLowerCase();

    const { data: usuario } = await buscarPorCorreo(email);

    if (!usuario) {
        throw httpError(
            401,
            "Correo o contraseña incorrectos."
        );
    }

    if (usuario.estado === false) {
        throw httpError(
            403,
            "Tu cuenta está desactivada. Contacta a un administrador."
        );
    }

    if (!usuario.password) {
        throw httpError(
            400,
            "Esta cuenta está vinculada a Google. Inicia sesión con Google."
        );
    }

    const coincide = await bcrypt.compare(
        String(password),
        usuario.password
    );

    if (!coincide) {
        throw httpError(
            401,
            "Correo o contraseña incorrectos."
        );
    }

    await actualizarUltimoLogin(usuario.id);

    const rol_nombre = nombreRol(usuario.rol_id);

    const token = jwt.sign(
        {
            id: usuario.id,
            rol_id: usuario.rol_id,
            rol: rol_nombre,
        },
        process.env.JWT_SECRET,
        { expiresIn: "8h" }
    );

    return {
        token,
        usuario: {
            ...quitarDatosSensibles(usuario),
            rol_nombre,
        },
    };
};
