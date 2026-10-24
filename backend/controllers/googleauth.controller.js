import jwt from "jsonwebtoken";
import { OAuth2Client } from "google-auth-library";
import {
    obtenerUsuarioPorCorreo,
    crearUsuarioGoogle,
    actualizarUsuario,
    obtenerUsuarioPorId,
} from "../models/usuariosModel.js";
import { httpError } from "../utils/httpError.js";

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const nombreRol = (rolId) => {
    if (Number(rolId) === 1) {
        return "Administrador";
    }

    if (Number(rolId) === 2) {
        return "Barbero";
    }

    return "Cliente";
};

const separarNombre = (payload) => {
    const completo = String(payload.name || "").trim();

    const nombres =
        String(payload.given_name || "").trim() ||
        completo.split(/\s+/)[0] ||
        "Usuario";

    const apellidos =
        String(payload.family_name || "").trim() ||
        completo.split(/\s+/).slice(1).join(" ") ||
        "Google";

    return { nombres, apellidos };
};

export const autenticarConGoogle = async (req, res) => {
    try {
        const { idToken } = req.body || {};

        if (!idToken) {
            throw httpError(
                400,
                "El idToken de Google es requerido."
            );
        }

        if (!process.env.GOOGLE_CLIENT_ID) {
            throw httpError(
                500,
                "El inicio de sesión con Google no está configurado."
            );
        }

        const ticket = await client.verifyIdToken({
            idToken,
            audience: process.env.GOOGLE_CLIENT_ID,
        });

        const payload = ticket.getPayload();

        if (!payload?.email) {
            throw httpError(
                400,
                "La cuenta de Google no tiene un correo disponible."
            );
        }

        const correo = payload.email.toLowerCase();
        const { sub: googleId, picture: avatar } = payload;
        const { nombres, apellidos } = separarNombre(payload);

        const { data: existente } = await obtenerUsuarioPorCorreo(
            correo
        );

        let usuarioFinal = null;
        let mensaje = "Inicio de sesión exitoso con Google.";
        let usuarioId = existente?.id || null;

        if (existente) {
            if (existente.estado === false) {
                throw httpError(
                    403,
                    "Tu cuenta está desactivada. Contacta a un administrador."
                );
            }

            const cambios = {};

            if (!existente.googleId) {
                cambios.googleId = googleId;
            }

            if (!existente.avatar && avatar) {
                cambios.avatar = avatar;
            }

            if (!existente.email_verificado) {
                cambios.email_verificado = true;
            }

            if (Object.keys(cambios).length) {
                await actualizarUsuario(existente.id, cambios);
            }
        } else {
            const { data: nuevo, error } = await crearUsuarioGoogle({
                nombres,
                apellidos,
                correo,
                googleId,
                avatar,
            });

            if (error) {
                throw new Error(error.message);
            }

            usuarioId = nuevo.id;
            mensaje = "Registro exitoso con Google.";
        }

        const { data: completo, error: errorPerfil } =
            await obtenerUsuarioPorId(usuarioId);

        if (errorPerfil || !completo) {
            throw new Error(
                "No fue posible cargar el perfil del usuario."
            );
        }

        usuarioFinal = completo;

        const rol_nombre =
            usuarioFinal.roles?.nombre ||
            nombreRol(usuarioFinal.rol_id);

        const token = jwt.sign(
            {
                id: usuarioFinal.id,
                rol_id: usuarioFinal.rol_id,
                rol: rol_nombre,
            },
            process.env.JWT_SECRET,
            { expiresIn: "8h" }
        );

        return res.status(200).json({
            success: true,
            message: mensaje,
            token,
            usuario: {
                ...usuarioFinal,
                rol_nombre,
            },
        });
    } catch (error) {
        console.error("Error en autenticación con Google:", error.message);

        return res.status(error.statusCode || 401).json({
            success: false,
            message:
                error.statusCode
                    ? error.message
                    : "Token de Google inválido o expirado.",
        });
    }
};
