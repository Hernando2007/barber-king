import {
    solicitarRecuperacion,
    restablecerContrasena
} from "../services/recuperacionService.js";

// Solicita el envío del correo de recuperación
export const forgotPassword = async (
    req,
    res,
    next
) => {

    try {  

        const { correo } = req.body;

        // Validamos que se haya enviado el correo
        if (!correo) {

            return res.status(400).json({
                success: false,
                message:
                    "El correo es obligatorio."
            });
        }

        await solicitarRecuperacion(correo);

        res.status(200).json({
            success: true,
            message:
                "Si el correo está registrado, recibirás un enlace para recuperar tu contraseña."
        });

    } catch (error) {

        next(error);
    }
};

// Restablece la contraseña
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

        // Validamos los datos
        if (!token || !nuevaContrasena) {

            return res.status(400).json({
                success: false,
                message:
                    "El token y la nueva contraseña son obligatorios."
            });
        }

        // Validamos una longitud mínima
        if (nuevaContrasena.length < 6) {

            return res.status(400).json({
                success: false,
                message:
                    "La contraseña debe tener mínimo 6 caracteres."
            });
        }

        await restablecerContrasena(
            token,
            nuevaContrasena
        );

        res.status(200).json({
            success: true,
            message:
                "Contraseña actualizada correctamente."
        });

    } catch (error) {

        next(error);
    }
};