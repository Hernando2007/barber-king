import { ASUNTO, contenido } from "./emailPlantilla.js";
import {
    ASUNTO_BIENVENIDA,
    ASUNTO_PASSWORD_ACTUALIZADA,
    contenidoBienvenida,
    contenidoPasswordActualizada,
} from "./emailPlantillaCuenta.js";
import { enviarCorreo } from "./emailEnvios.js";

export {
    correoConfigurado,
    verificarEmailService,
} from "./emailConfig.js";

export const enviarCodigoRecuperacion = async (
    correo,
    codigo,
    nombre = ""
) => {
    try {
        await enviarCorreo(correo, ASUNTO, contenido(codigo, nombre));
        return true;
    } catch (error) {
        throw new Error(
            "No fue posible enviar el correo de recuperación. Revisa RESEND_API_KEY, BREVO_API_KEY o la configuración SMTP del servidor."
        );
    }
};

export const enviarBienvenida = async (correo, nombre = "") => {
    await enviarCorreo(
        correo,
        ASUNTO_BIENVENIDA,
        contenidoBienvenida(nombre)
    );
};

export const enviarPasswordActualizada = async (datos) => {
    await enviarCorreo(
        datos.correo,
        ASUNTO_PASSWORD_ACTUALIZADA,
        contenidoPasswordActualizada(datos)
    );
};
