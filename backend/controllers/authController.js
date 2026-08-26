import {
    registrarUsuario,
    iniciarSesion,
    solicitarRecuperacion,
    cambiarPassword
} from "../services/authService.js";

export const registrar = async (
    req,
    res,
    next
) => {

    try {

        const usuario =
            await registrarUsuario(
                req.body
            );

        return res.status(201).json({

            success: true,
            message:
                "Usuario registrado correctamente.",
            data: usuario

        });

    } catch (error) {

        next(error);

    }

};

export const login = async (
    req,
    res,
    next
) => {

    try {

        const {
            correo,
            password
        } = req.body;

        const resultado =
            await iniciarSesion({
                correo,
                password
            });

        return res.status(200).json({

            success: true,
            message:
                "Inicio de sesión exitoso.",
            token:
                resultado.token,
            usuario:
                resultado.usuario

        });

    } catch (error) {

        next(error);

    }

};

export const forgotPassword = async (
    req,
    res,
    next
) => {

    try {

        const { correo } =
            req.body;

        await solicitarRecuperacion(
            correo
        );

        return res.status(200).json({

            success: true,
            message:
                "Si el correo existe, se envió un código de recuperación."

        });

    } catch (error) {

        next(error);

    }

};

export const resetPassword = async (
    req,
    res,
    next
) => {

    try {

        const {
            correo,
            codigo,
            password
        } = req.body;

        await cambiarPassword(
            correo,
            codigo,
            password
        );

        return res.status(200).json({

            success: true,
            message:
                "Contraseña actualizada correctamente."

        });

    } catch (error) {

        next(error);

    }

};