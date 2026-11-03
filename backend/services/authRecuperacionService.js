import bcrypt from "bcrypt";
import {
    buscarPorCorreo,
    guardarTokenRecuperacion,
    actualizarPassword,
    limpiarToken,
} from "../models/authModel.js";
import {
    enviarCodigoRecuperacion,
    enviarPasswordActualizada,
} from "./emailService.js";
import { httpError } from "../utils/httpError.js";
import { texto } from "./authComun.js";

export const solicitarRecuperacion = async (correo) => {
    const email = texto(correo)?.toLowerCase();

    if (!email) {
        throw httpError(
            400,
            "El correo electrónico es obligatorio."
        );
    }

    const { data: usuario } = await buscarPorCorreo(email);

    if (!usuario) {
        return true;
    }

    const codigo = Math.floor(
        100000 + Math.random() * 900000
    ).toString();

    const expiracion = new Date(
        Date.now() + 15 * 60 * 1000
    );

    const { error } = await guardarTokenRecuperacion(
        email,
        codigo,
        expiracion
    );

    if (error) {
        throw new Error(error.message);
    }

    await enviarCodigoRecuperacion(
        email,
        codigo,
        usuario.nombres
    );

    return true;
};

export const cambiarPassword = async (
    correo,
    codigo,
    password
) => {
    if (!correo || !codigo || !password) {
        throw httpError(
            400,
            "Todos los campos son obligatorios."
        );
    }

    if (String(password).length < 6) {
        throw httpError(
            400,
            "La contraseña debe tener mínimo 6 caracteres."
        );
    }

    const email = String(correo).trim().toLowerCase();

    const { data: usuario } = await buscarPorCorreo(email);

    if (!usuario) {
        throw httpError(400, "Código inválido.");
    }

    if (String(usuario.token_recuperacion) !== String(codigo)) {
        throw httpError(400, "Código inválido.");
    }

    if (
        !usuario.token_expiracion ||
        new Date(usuario.token_expiracion) < new Date()
    ) {
        throw httpError(400, "El código ha expirado.");
    }

    const passwordHash = await bcrypt.hash(String(password), 10);

    const { error } = await actualizarPassword(
        usuario.id,
        passwordHash
    );

    if (error) {
        throw new Error(error.message);
    }

    await limpiarToken(usuario.id);

    const fecha = new Date().toLocaleString("es-CO", {
        dateStyle: "long",
        timeStyle: "short",
    });

    try {
        await enviarPasswordActualizada({
            correo: usuario.correo,
            nombre: usuario.nombres,
            fecha,
        });
    } catch (error) {
        console.error(
            "No fue posible enviar el aviso de contraseña actualizada:",
            error.message
        );
    }

    return true;
};
