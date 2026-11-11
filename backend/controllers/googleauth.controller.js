import jwt from "jsonwebtoken";
import { OAuth2Client } from "google-auth-library";
import {
    obtenerUsuarioPorCorreo,
    crearUsuarioGoogle,
    actualizarUsuario,
    obtenerUsuarioPorId,
} from "../models/usuariosModel.js";
import { httpError } from "../utils/httpError.js";
import { enviarBienvenida } from "../services/emailService.js";

const clienteGoogle = new OAuth2Client();

const obtenerClientesPermitidos = () => {
    const valores = [
        process.env.GOOGLE_CLIENT_ID,
        process.env.GOOGLE_CLIENT_IDS,
    ]
        .filter(Boolean)
        .join(",")
        .split(/[\s,]+/)
        .map((valor) => valor.trim())
        .filter(Boolean);

    return [...new Set(valores)];
};

// Los tokens de Android/iOS del mismo proyecto de Google Cloud
// pueden tener una audiencia distinta a la del cliente web.
const mismoProyecto = (audiencia, clientes) => {
    const proyecto = String(audiencia || "").split("-")[0];

    return (
        Boolean(proyecto) &&
        clientes.some((cliente) => cliente.split("-")[0] === proyecto)
    );
};

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

        if (typeof idToken !== "string" || !idToken.trim()) {
            throw httpError(
                400,
                "El idToken de Google es requerido."
            );
        }

        const clientesPermitidos = obtenerClientesPermitidos();

        if (!clientesPermitidos.length) {
            throw httpError(
                500,
                "El inicio de sesión con Google no está configurado."
            );
        }

        const idTokenLimpio = idToken.trim();

        let tokenDecodificado = null;

        try {
            tokenDecodificado = jwt.decode(idTokenLimpio);
        } catch {
            tokenDecodificado = null;
        }

        if (!tokenDecodificado || typeof tokenDecodificado !== "object") {
            throw httpError(
                401,
                "El token de Google no tiene un formato válido. Inténtalo de nuevo."
            );
        }

        const audiencia = String(tokenDecodificado.aud || "");
        const emisor = String(tokenDecodificado.iss || "");
        const expiracion = Number(tokenDecodificado.exp || 0);
        const ahora = Math.floor(Date.now() / 1000);

        console.log("Google auth:", {
            aud: audiencia,
            iss: emisor,
            venceEnSegundos: expiracion ? expiracion - ahora : null,
        });

        if (
            emisor !== "accounts.google.com" &&
            emisor !== "https://accounts.google.com"
        ) {
            throw httpError(
                401,
                "El token de Google no fue emitido por Google."
            );
        }

        if (
            !clientesPermitidos.includes(audiencia) &&
            !mismoProyecto(audiencia, clientesPermitidos)
        ) {
            console.warn("Google auth: audiencia no configurada", {
                audiencia,
                clientesPermitidos,
            });

            throw httpError(
                401,
                "El token de Google pertenece a otra aplicación. " +
                    "Revisa el cliente OAuth configurado en el servidor."
            );
        }

        if (expiracion && expiracion < ahora - 60) {
            throw httpError(
                401,
                "El token de Google expiró. Activa la fecha y hora " +
                    "automáticas en el teléfono y vuelve a intentarlo."
            );
        }

        let ticket;

        try {
            ticket = await clienteGoogle.verifyIdToken({
                idToken: idTokenLimpio,
                audience: audiencia,
            });
        } catch (error) {
            console.error(
                "Google auth: verifyIdToken falló:",
                error.message
            );

            const expirado = /expir|Expiration Time/i.test(
                error.message || ""
            );

            throw httpError(
                401,
                expirado
                    ? "El token de Google expiró. Activa la fecha y " +
                          "hora automáticas en el teléfono y vuelve a " +
                          "intentarlo."
                    : "No fue posible validar el token de Google. " +
                          "Vuelve a intentarlo."
            );
        }

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

        const { data: existente, error: errorConsulta } =
            await obtenerUsuarioPorCorreo(correo);

        if (errorConsulta) {
            throw new Error(
                `No fue posible consultar el usuario: ${errorConsulta.message}`
            );
        }

        let usuarioFinal = null;
        let mensaje = "Inicio de sesión exitoso con Google.";
        let usuarioId = existente?.id || null;
        let esNuevo = false;

        if (existente) {
            if (existente.estado === false) {
                throw httpError(
                    403,
                    "Tu cuenta está desactivada. Contacta a un administrador."
                );
            }

            const cambios = {};

            if (!existente.google_id) {
                cambios.google_id = googleId;
            }

            if (!existente.avatar && avatar) {
                cambios.avatar = avatar;
            }

            if (!existente.email_verificado) {
                cambios.email_verificado = true;
            }

            if (Object.keys(cambios).length) {
                const { error: errorActualizacion } =
                    await actualizarUsuario(existente.id, cambios);

                if (errorActualizacion) {
                    throw new Error(
                        "No fue posible actualizar el usuario: " +
                            errorActualizacion.message
                    );
                }
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
            esNuevo = true;
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

        if (esNuevo) {
            try {
                await enviarBienvenida(correo, nombres);
            } catch (error) {
                console.error(
                    "No fue posible enviar el correo de bienvenida:",
                    error.message
                );
            }
        }

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
        console.error("Error en autenticación con Google:", error);

        if (error.statusCode) {
            return res.status(error.statusCode).json({
                success: false,
                message: error.message,
            });
        }

        return res.status(500).json({
            success: false,
            message:
                "No fue posible completar el inicio de sesión con Google. " +
                "Inténtalo de nuevo en unos minutos.",
        });
    }
};
