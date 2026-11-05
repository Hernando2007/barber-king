import { httpError } from "../utils/httpError.js";
import { obtenerBarberoPorUsuario } from "../models/barberosModel.js";
import { obtenerUsuarioBasico } from "../models/chatDirectoModel.js";

export const ROL_ADMIN = 1;
export const ROL_BARBERO = 2;
export const ROL_CLIENTE = 3;

export const nombreRol = (rolId) => {
    if (Number(rolId) === ROL_ADMIN) {
        return "Administrador";
    }

    if (Number(rolId) === ROL_BARBERO) {
        return "Barbero";
    }

    return "Cliente";
};

export const construirSesion = (a, b) => {
    const menor = Math.min(Number(a), Number(b));
    const mayor = Math.max(Number(a), Number(b));

    return `directo_${menor}_${mayor}`;
};

export const participantesDeSesion = (sesionId) => {
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

export const datosContacto = (usuario, extra = {}) => {
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

export const validarDestinatario = async (usuario, contactoId) => {
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

export const mensajeConEstado = (mensaje, usuarioId) => ({
    ...mensaje,
    esMio:
        Number(mensaje.usuario_id) === Number(usuarioId),
});
