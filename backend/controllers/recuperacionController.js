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

        // Verificamos que se haya enviado el correo
        if (!correo) {

            return res.status(400).json({
                success: false,
                message:
                    "El correo es obligatorio."
            });
        }

        // Ejecutamos la recuperación
        await solicitarRecuperacion(correo);

        // Por seguridad usamos el mismo mensaje
        // aunque el correo no exista
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

        // Validamos los datos
        if (!token || !nuevaContrasena) {

            return res.status(400).json({
                success: false,
                message:
                    "El token y la nueva contraseña son obligatorios."
            });
        }

        // Validamos la longitud de la contraseña
        if (nuevaContrasena.length < 6) {

            return res.status(400).json({
                success: false,
                message:
                    "La contraseña debe tener mínimo 6 caracteres."
            });
        }

        // Cambiamos la contraseña
        await restablecerContrasena(
            token,
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