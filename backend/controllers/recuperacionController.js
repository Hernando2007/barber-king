import {
    solicitarRecuperacion,
    restablecerContrasena
} from "../services/recuperacionService.js";

// Solicitar recuperación de contraseña
export const forgotPassword = async (
    req,
    res,
    next
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

        const correoNormalizado = correo
            .trim()
            .toLowerCase();

        await solicitarRecuperacion(
            correoNormalizado
        );

        return res.status(200).json({
            success: true,
            message:
                "Si el correo está registrado, recibirás un enlace para recuperar tu contraseña."
        });

    } catch (error) {

        next(error);

    }

};

// Restablecer contraseña
export const resetPassword = async (
    req,
    res,
    next
) => {

    try {

        const {
            token,
            nuevaContrasena
        } = req.body;

        if (!token || !nuevaContrasena) {

            return res.status(400).json({
                success: false,
                message:
                    "El token y la nueva contraseña son obligatorios."
            });

        }

        if (
            typeof nuevaContrasena !== "string"
        ) {

            return res.status(400).json({
                success: false,
                message:
                    "La contraseña no es válida."
            });

        }

        if (nuevaContrasena.length < 6) {

            return res.status(400).json({
                success: false,
                message:
                    "La contraseña debe tener mínimo 6 caracteres."
            });

        }

        await restablecerContrasena(
            token.trim(),
            nuevaContrasena
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