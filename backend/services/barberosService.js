import {
    actualizarBarbero,
    crearBarbero,
    eliminarBarbero,
    obtenerBarberoPorId,
    obtenerBarberoPorUsuario,
    obtenerBarberos,
} from "../models/barberosModel.js";
import { obtenerUsuarioPorId } from "../models/usuariosModel.js";
import { httpError } from "../utils/httpError.js";
import { normalizarBarbero } from "./barberosNormalizador.js";
import { anotarCalificaciones } from "./barberosRankingService.js";

export const asegurarPerfilBarbero = async (usuarioId) => {
    const { data: existente, error } =
        await obtenerBarberoPorUsuario(usuarioId);

    if (error) {
        throw new Error(error.message);
    }

    if (existente) {
        return existente;
    }

    const { data: usuario, error: errorUsuario } =
        await obtenerUsuarioPorId(usuarioId);

    if (errorUsuario) {
        throw new Error(errorUsuario.message);
    }

    if (!usuario) {
        throw httpError(404, "Usuario no encontrado.");
    }

    if (Number(usuario.rol_id) !== 2) {
        throw httpError(403, "El usuario no tiene rol de barbero.");
    }

    const { data, error: errorCrear } = await crearBarbero({
        usuario_id: Number(usuarioId),
        especialidad: "Barbero profesional",
        experiencia: 0,
        descripcion: null,
        disponible: true,
        portafolio: [],
    });

    if (errorCrear) {
        throw new Error(errorCrear.message);
    }

    return data;
};

export const listarBarberos = async () => {
    const { data, error } = await obtenerBarberos();

    if (error) {
        throw new Error(error.message);
    }

    return await anotarCalificaciones(data || []);
};

export const obtenerUno = async (id) => {
    if (!id) {
        throw httpError(400, "El ID es obligatorio.");
    }

    const { data, error } = await obtenerBarberoPorId(id);

    if (error) {
        throw new Error(error.message);
    }

    if (!data) {
        throw httpError(404, "Barbero no encontrado.");
    }

    const [barbero] = await anotarCalificaciones([data]);
    return barbero;
};

export const registrarBarbero = async (datos) => {
    const usuarioId = Number(datos?.usuario_id);

    if (!usuarioId) {
        throw httpError(400, "El usuario es obligatorio.");
    }

    const { data: existe } = await obtenerBarberoPorUsuario(usuarioId);

    if (existe) {
        throw httpError(
            409,
            "Este usuario ya está registrado como barbero."
        );
    }

    const campos = normalizarBarbero(datos, { parcial: false });

    const { data, error } = await crearBarbero({
        ...campos,
        usuario_id: usuarioId,
        disponible: campos.disponible !== false,
        portafolio: campos.portafolio || [],
    });

    if (error) {
        throw new Error(error.message);
    }

    return data;
};

export const editarBarbero = async (id, datos) => {
    if (!id) {
        throw httpError(400, "El ID del barbero es obligatorio.");
    }

    const { data: existe } = await obtenerBarberoPorId(id);

    if (!existe) {
        throw httpError(404, "Barbero no encontrado.");
    }

    const campos = normalizarBarbero(datos);

    if (!Object.keys(campos).length) {
        throw httpError(400, "No hay datos válidos para actualizar.");
    }

    const { data, error } = await actualizarBarbero(id, campos);

    if (error) {
        throw new Error(error.message);
    }

    return data;
};

export const editarPerfilBarbero = async (usuarioId, datos) => {
    const { data: barbero } = await obtenerBarberoPorUsuario(usuarioId);

    if (!barbero) {
        throw httpError(404, "Perfil de barbero no encontrado.");
    }

    const campos = normalizarBarbero(datos);

    if (!Object.keys(campos).length) {
        throw httpError(400, "No hay datos válidos para actualizar.");
    }

    const { data, error } = await actualizarBarbero(barbero.id, campos);

    if (error) {
        throw new Error(error.message);
    }

    return data;
};

export const borrarBarbero = async (id) => {
    if (!id) {
        throw httpError(400, "El ID del barbero es obligatorio.");
    }

    const { data: existe } = await obtenerBarberoPorId(id);

    if (!existe) {
        throw httpError(404, "Barbero no encontrado.");
    }

    const { error } = await eliminarBarbero(id);

    if (error) {
        throw new Error(error.message);
    }

    return true;
};
