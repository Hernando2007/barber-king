import { httpError } from "../utils/httpError.js";
import { contieneProfanidad } from "../utils/profanidad.js";
import {
    listarMensajesSesion,
    listarNovedadesDirectas,
    crearMensajeDirecto,
} from "../models/chatDirectoModel.js";
import {
    construirSesion,
    datosContacto,
    mensajeConEstado,
    nombreRol,
    validarDestinatario,
} from "./chatDirectoSesiones.js";

export const obtenerConversacion = async (
    usuario,
    contactoId,
    ultimoId = 0
) => {
    const destinatario = await validarDestinatario(
        usuario,
        contactoId
    );

    const sesionId = construirSesion(
        usuario.id,
        destinatario.id
    );

    const { data, error } = await listarMensajesSesion(
        sesionId,
        Number(ultimoId) || 0
    );

    if (error) {
        throw new Error(error.message);
    }

    return {
        sesion_id: sesionId,
        contacto: datosContacto(destinatario),
        mensajes: (data || []).map((mensaje) =>
            mensajeConEstado(mensaje, usuario.id)
        ),
    };
};

export const obtenerNovedadesChat = async (
    usuario,
    desdeId = 0
) => {
    if (!usuario?.id) {
        throw httpError(401, "Usuario no autenticado.");
    }

    const base = Number(desdeId) || 0;

    const { data, error } = await listarNovedadesDirectas(
        Number(usuario.id),
        base
    );

    if (error) {
        throw new Error(error.message);
    }

    const mensajes = (data || []).map((item) => {
        const emisor = item.usuarios || {};
        const nombre = `${emisor.nombres || ""} ${
            emisor.apellidos || ""
        }`.trim();

        return {
            id: item.id,
            sesion_id: item.sesion_id,
            usuario_id: item.usuario_id,
            mensaje: item.mensaje,
            imagen_url: item.imagen_url,
            created_at: item.created_at,
            emisor_nombre: nombre || "Usuario",
            emisor_foto: emisor.foto || null,
        };
    });

    const ultimoId = mensajes.length
        ? Number(mensajes[mensajes.length - 1].id)
        : base;

    return { mensajes, ultimo_id: ultimoId };
};

export const enviarMensajeDirecto = async (usuario, datos) => {
    const destinatario = await validarDestinatario(
        usuario,
        datos?.destinatario_id
    );

    const mensaje = String(datos?.mensaje || "").trim();
    const imagenUrl = datos?.imagen_url
        ? String(datos.imagen_url).trim()
        : null;

    if (!mensaje && !imagenUrl) {
        throw httpError(
            400,
            "Escribe un mensaje antes de enviarlo."
        );
    }

    if (contieneProfanidad(mensaje)) {
        throw httpError(
            400,
            "El mensaje tiene palabras no permitidas. Reformúlalo para enviarlo."
        );
    }

    if (mensaje.length > 2000) {
        throw httpError(
            400,
            "El mensaje no puede superar los 2000 caracteres."
        );
    }

    const sesionId = construirSesion(
        usuario.id,
        destinatario.id
    );

    const { data, error } = await crearMensajeDirecto({
        sesion_id: sesionId,
        usuario_id: usuario.id,
        emisor: "usuario",
        mensaje:
            mensaje ||
            "Imagen enviada.",
        imagen_url: imagenUrl,
        tipo_mensaje: "directo",
        metadata: {
            destinatario_id: destinatario.id,
            participantes: [usuario.id, destinatario.id],
            rol_emisor:
                usuario.rol || nombreRol(usuario.rol_id),
        },
    });

    if (error) {
        throw new Error(error.message);
    }

    return {
        sesion_id: sesionId,
        contacto: datosContacto(destinatario),
        mensaje: mensajeConEstado(data, usuario.id),
    };
};
