import { httpError } from "../utils/httpError.js";
import {
    obtenerUsuarios,
    obtenerUsuarioPorId,
} from "../models/usuariosModel.js";
import { serializarUsuario } from "../utils/usuariosNormalizacion.js";

export const listarUsuarios = async () => {
    const { data, error } = await obtenerUsuarios();

    if (error) {
        throw new Error(error.message);
    }

    return (data || []).map(serializarUsuario);
};

export const buscarUsuario = async (id) => {
    if (!id) {
        throw httpError(400, "El ID del usuario es obligatorio.");
    }

    const { data, error } = await obtenerUsuarioPorId(id);

    if (error) {
        throw new Error(error.message);
    }

    if (!data) {
        throw httpError(404, "Usuario no encontrado.");
    }

    return serializarUsuario(data);
};

export const obtenerPerfilCompleto = async (id) =>
    await buscarUsuario(id);

export const obtenerMiPerfil = async (id) => {
    const perfil = await obtenerPerfilCompleto(id);

    return perfil;
};
