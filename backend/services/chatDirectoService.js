import { httpError } from "../utils/httpError.js";
import { contieneProfanidad } from "../utils/profanidad.js";
import { obtenerBarberoPorUsuario } from "../models/barberosModel.js";
import { asegurarPerfilBarbero } from "./barberosService.js";
import {
    listarBarberosConUsuario,
    listarClientesDeBarbero,
    listarUsuariosContactables,
    obtenerUsuarioBasico,
    listarMensajesDirectos,
    listarMensajesSesion,
    listarNovedadesDirectas,
    crearMensajeDirecto,
} from "../models/chatDirectoModel.js";

const ROL_ADMIN = 1;
const ROL_BARBERO = 2;
const ROL_CLIENTE = 3;

const nombreRol = (rolId) => {
    if (Number(rolId) === ROL_ADMIN) {
        return "Administrador";
    }

    if (Number(rolId) === ROL_BARBERO) {
        return "Barbero";
    }

    return "Cliente";
};

const construirSesion = (a, b) => {
    const menor = Math.min(Number(a), Number(b));
    const mayor = Math.max(Number(a), Number(b));

    return `directo_${menor}_${mayor}`;
};

const participantesDeSesion = (sesionId) => {
    const coincidencia = /^directo_(\d+)_(\d+)$/.exec(
        String(sesionId || "")
    );

    if (!coincidencia) {
        return null;
    }

    return [Number(coincidencia[1]), Number(coincidencia[2])];
};

const validarRelacion = (rolEmisor, rolDestino) => {
    const emisor = Number(rolEmisor);
    const destino = Number(rolDestino);

    if (emisor === ROL_CLIENTE && destino !== ROL_BARBERO) {
        throw httpError(
            403,
            "Solo puedes escribir a los barberos."
        );
    }

    if (emisor === ROL_BARBERO && destino !== ROL_CLIENTE) {
        throw httpError(
            403,
            "Solo puedes escribir a tus clientes."
        );
    }

    if (emisor === ROL_ADMIN && destino === ROL_ADMIN) {
        throw httpError(
            403,
            "No puedes iniciar un chat con otro administrador."
        );
    }
};

const datosContacto = (usuario, extra = {}) => {
    const barberos = Array.isArray(usuario.barberos)
        ? usuario.barberos
        : usuario.barberos
          ? [usuario.barberos]
          : [];

    const barbero = barberos[0] || null;

    return {
        usuario_id: usuario.id ?? usuario.usuario_id ?? null,
        nombres: usuario.nombres || "",
        apellidos: usuario.apellidos || "",
        foto: usuario.foto || null,
        rol:
            extra.rol ||
            usuario.roles?.nombre ||
            nombreRol(usuario.rol_id),
        rol_id: Number(usuario.rol_id),
        barbero_id: barbero?.id ?? extra.barbero_id ?? null,
        especialidad:
            barbero?.especialidad ?? extra.especialidad ?? null,
        disponible:
            barbero?.disponible ?? extra.disponible ?? null,
        activo: usuario.estado !== false,
    };
};

const validarDestinatario = async (usuario, contactoId) => {
    const miId = Number(usuario.id);
    const destinoId = Number(contactoId);

    if (!destinoId) {
        throw httpError(
            400,
            "El contacto es obligatorio."
        );
    }

    if (destinoId === miId) {
        throw httpError(
            400,
            "No puedes iniciar un chat contigo mismo."
        );
    }

    const { data, error } = await obtenerUsuarioBasico(destinoId);

    if (error) {
        throw new Error(error.message);
    }

    if (!data) {
        throw httpError(404, "Contacto no encontrado.");
    }

    if (data.estado === false) {
        throw httpError(
            400,
            "El contacto se encuentra desactivado."
        );
    }

    let miRolChat = Number(usuario.rol_id);

    if (miRolChat === ROL_CLIENTE) {
        const { data: miPerfilBarbero } =
            await obtenerBarberoPorUsuario(miId);

        if (miPerfilBarbero) {
            miRolChat = ROL_BARBERO;
        }
    }

    const tienePerfilBarbero = Array.isArray(data.barberos)
        ? data.barberos.length > 0
        : Boolean(data.barberos);

    const rolBase = Number(data.rol_id);
    const rolDestinoChat =
        rolBase === ROL_CLIENTE && tienePerfilBarbero
            ? ROL_BARBERO
            : rolBase;

    validarRelacion(miRolChat, rolDestinoChat);

    return data;
};

const mensajeConEstado = (mensaje, usuarioId) => ({
    ...mensaje,
    esMio:
        Number(mensaje.usuario_id) === Number(usuarioId),
});

export const obtenerContactosDirectos = async (usuario) => {
    if (!usuario?.id) {
        throw httpError(401, "Usuario no autenticado.");
    }

    const miId = Number(usuario.id);
    const miRol = Number(usuario.rol_id);
    const contactos = new Map();

    const agregar = (contacto) => {
        if (
            !contacto.usuario_id ||
            Number(contacto.usuario_id) === miId ||
            contactos.has(Number(contacto.usuario_id))
        ) {
            return;
        }

        contactos.set(Number(contacto.usuario_id), contacto);
    };

    if (miRol === ROL_CLIENTE) {
        const [perfiles, usuarios] = await Promise.all([
            listarBarberosConUsuario(),
            listarUsuariosContactables(),
        ]);

        if (perfiles.error) {
            throw new Error(perfiles.error.message);
        }

        if (usuarios.error) {
            throw new Error(usuarios.error.message);
        }

        for (const barbero of perfiles.data || []) {
            if (!barbero.usuarios || barbero.usuarios.estado === false) {
                continue;
            }

            agregar(
                datosContacto(barbero.usuarios, {
                    rol: "Barbero",
                    barbero_id: barbero.id,
                    especialidad: barbero.especialidad,
                    disponible: barbero.disponible,
                })
            );
        }

        for (const item of usuarios.data || []) {
            if (Number(item.rol_id) !== ROL_BARBERO) {
                continue;
            }

            agregar(
                datosContacto(item, {
                    rol: "Barbero",
                })
            );
        }
    } else if (miRol === ROL_BARBERO) {
        const barbero = await asegurarPerfilBarbero(miId);

        const { data, error } = await listarClientesDeBarbero(
            barbero.id
        );

        if (error) {
            throw new Error(error.message);
        }

        for (const cita of data || []) {
            if (!cita.usuarios || cita.usuarios.estado === false) {
                continue;
            }

            agregar(datosContacto(cita.usuarios));
        }
    } else {
        const { data, error } = await listarUsuariosContactables();

        if (error) {
            throw new Error(error.message);
        }

        for (const item of data || []) {
            agregar(datosContacto(item));
        }
    }

    const { data: mensajes, error: errorMensajes } =
        await listarMensajesDirectos(miId);

    if (errorMensajes) {
        throw new Error(errorMensajes.message);
    }

    const ultimos = new Map();

    for (const mensaje of mensajes || []) {
        const participantes = participantesDeSesion(
            mensaje.sesion_id
        );

        if (!participantes || !participantes.includes(miId)) {
            continue;
        }

        if (!ultimos.has(mensaje.sesion_id)) {
            ultimos.set(mensaje.sesion_id, mensaje);
        }

        const otroId = participantes.find(
            (id) => Number(id) !== miId
        );

        if (
            !otroId ||
            contactos.has(Number(otroId))
        ) {
            continue;
        }

        const { data: usuarioContacto } =
            await obtenerUsuarioBasico(otroId);

        if (
            usuarioContacto &&
            usuarioContacto.estado !== false
        ) {
            agregar(datosContacto(usuarioContacto));
        }
    }

    const lista = Array.from(contactos.values()).map((contacto) => {
        const sesionId = construirSesion(
            miId,
            contacto.usuario_id
        );

        const ultimo = ultimos.get(sesionId) || null;

        return {
            ...contacto,
            sesion_id: sesionId,
            ultimo_mensaje: ultimo
                ? {
                      id: ultimo.id,
                      mensaje: ultimo.mensaje,
                      imagen_url: ultimo.imagen_url,
                      usuario_id: ultimo.usuario_id,
                      created_at: ultimo.created_at,
                  }
                : null,
        };
    });

    lista.sort((a, b) => {
        const fechaA = a.ultimo_mensaje?.created_at || "";
        const fechaB = b.ultimo_mensaje?.created_at || "";

        if (fechaA !== fechaB) {
            return fechaB.localeCompare(fechaA);
        }

        return `${a.nombres} ${a.apellidos}`.localeCompare(
            `${b.nombres} ${b.apellidos}`
        );
    });

    return lista;
};

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
