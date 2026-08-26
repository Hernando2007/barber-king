import {
    listarUsuarios,
    buscarUsuario
} from "../services/usuariosService.js";

export const getUsuarios = async (
    req,
    res,
    next
) => {

    try {

        const {
            data,
            error
        } =
            await listarUsuarios();

        if (error) {

            return res.status(500).json({
                success: false,
                message:
                    error.message
            });

        }

        return res.status(200).json({
            success: true,
            data
        });

    } catch (error) {

        next(error);

    }

};

export const getUsuario = async (
    req,
    res,
    next
) => {

    try {

        const { id } =
            req.params;

        const {
            data,
            error
        } =
            await buscarUsuario(id);

        if (
            error ||
            !data
        ) {

            return res.status(404).json({
                success: false,
                message:
                    "Usuario no encontrado."
            });

        }

        return res.status(200).json({
            success: true,
            data
        });

    } catch (error) {

        next(error);

    }

};