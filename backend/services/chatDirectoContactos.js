import { httpError } from "../utils/httpError.js";
import { asegurarPerfilBarbero } from "./barberosService.js";
import {
    listarBarberosConUsuario,
    listarClientesDeBarbero,
    listarUsuariosContactables,
    obtenerUsuarioBasico,
    listarMensajesDirectos,
} from "../models/chatDirectoModel.js";
import {
    ROL_BARBERO,
    ROL_CLIENTE,
    construirSesion,
    datosContacto,
    participantesDeSesion,
} from "./chatDirectoSesiones.js";

/** Personas con las que se puede chatear, ordenadas por el último mensaje. */
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
