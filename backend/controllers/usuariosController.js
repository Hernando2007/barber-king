import {
    listarUsuarios,
    buscarUsuario
} from "../services/usuariosService.js";

// Obtener todos
export const getUsuarios = async (req, res) => {

    const { data, error } = await listarUsuarios();

    if (error) {

        return res.status(500).json(error);

    }

    res.json(data);

};

// Obtener uno
export const getUsuario = async (req, res) => {

    const { id } = req.params;

    const { data, error } = await buscarUsuario(id);

    if (error) {

        return res.status(404).json(error);

    }

    res.json(data);

};