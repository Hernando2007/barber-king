import {
    solicitarRecuperacion,
    restablecerContrasena
} from "../services/recuperacionService.js";

export const forgotPassword = async (
    req,
    res
) => {

    try {

        const { correo } = req.body;

        if (!correo) {

            return res.status(400).json({
                success: false,
                message:
                    "El correo es obligatorio."
            });

        }

        await solicitarRecuperacion(
            correo.trim().toLowerCase()
        );

        return res.status(200).json({
            success: true,
            message:
                "Si el correo existe, recibirás un código de recuperación."
        });

    } catch (error) {

        return res.status(500).json({
            success: false,
            message:
                error.message
        });

    }

};

export const resetPassword = async (
    req,
    res
) => {

    try {

        const {
            correo,
            codigo,
            password
        } = req.body;

        if (
            !correo ||
            !codigo ||
            !password
        ) {

            return res.status(400).json({
                success: false,
                message:
                    "Correo, código y contraseña son obligatorios."
            });

        }

        if (password.length < 6) {

            return res.status(400).json({
                success: false,
                message:
                    "La contraseña debe tener mínimo 6 caracteres."
            });

        }

        await restablecerContrasena(
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

        return res.status(400).json({
            success: false,
            message:
                error.message
        });

    }

};