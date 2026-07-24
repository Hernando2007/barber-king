import {
    obtenerUsuarios,
    obtenerUsuarioPorId
} from "../models/usuariosModel.js";

export const listarUsuarios = async () => {

    return await obtenerUsuarios();

};

export const buscarUsuario = async (id) => {

    return await obtenerUsuarioPorId(id);

};