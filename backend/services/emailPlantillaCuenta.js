import {
    disenoCorreo,
    escaparCorreo,
    listaCorreo,
    notaCorreo,
    textoCorreo,
} from "./emailDiseno.js";

export const ASUNTO_BIENVENIDA = "¡Bienvenido a Barber King!";

export const contenidoBienvenida = (nombre = "") => {
    const saludo = nombre
        ? `¡Bienvenido a Barber King, ${escaparCorreo(nombre)}!`
        : "¡Bienvenido a Barber King!";

    return {
        text: `Barber King

${saludo}

Tu cuenta ya está lista. Desde la app puedes:
- Reservar tu próximo corte en segundos.
- Encontrar barberos verificados cerca de ti.
- Ver la ubicación del barbero y coordinar la atención.

Nos vemos en la silla.

CORTE · ESTILO · EXPERIENCIA`,
        html: disenoCorreo({
            titulo: saludo,
            contenido: `
                ${textoCorreo("Tu cuenta ya está lista. Ahora todo tu estilo vive en un solo lugar:")}
                ${listaCorreo([
                    "<strong style=\"color:#F8FAFC;\">Reserva en segundos:</strong> elige barbero, servicio y hora.",
                    "<strong style=\"color:#F8FAFC;\">Barberos verificados:</strong> perfiles con diploma y reseñas reales.",
                    "<strong style=\"color:#F8FAFC;\">Ubicación en vivo:</strong> mira dónde está tu barbero cuando comparte su ubicación.",
                ])}
                ${textoCorreo("Abre la app, explora los barberos de tu zona y agenda tu próximo corte.")}
            `,
            nota: notaCorreo(
                "Consejo: completa tu perfil y activa las notificaciones para no perder ninguna cita ni mensaje."
            ),
            pie: "Recibes este correo porque creaste una cuenta en Barber King.",
        }),
    };
};

export const ASUNTO_PASSWORD_ACTUALIZADA = "Tu contraseña fue actualizada";

export const contenidoPasswordActualizada = ({
    nombre = "",
    correo = "",
    fecha = "",
} = {}) => {
    const saludo = nombre
        ? `Hola ${escaparCorreo(nombre)},`
        : "Hola,";

    const cuenta = correo
        ? ` de la cuenta <strong style="color:#F8FAFC;">${escaparCorreo(correo)}</strong>`
        : "";

    const cuando = fecha
        ? ` el <strong style="color:#F8FAFC;">${escaparCorreo(fecha)}</strong>`
        : "";

    return {
        text: `Barber King

${saludo}

La contraseña${correo ? ` de la cuenta ${correo}` : ""} se cambió correctamente${fecha ? ` el ${fecha}` : ""}.

Si fuiste tú, no necesitas hacer nada más. Si no reconoces este cambio, solicita un nuevo código de recuperación desde la app de inmediato.

CORTE · ESTILO · EXPERIENCIA`,
        html: disenoCorreo({
            titulo: "Tu contraseña fue actualizada",
            contenido: `
                ${textoCorreo(`${saludo} la contraseña${cuenta} se cambió correctamente${cuando}.`)}
                ${textoCorreo("Ya puedes iniciar sesión con tu nueva contraseña.")}
            `,
            nota: notaCorreo(
                "Si no reconoces este cambio, solicita un nuevo código de recuperación desde la app y cambia la contraseña de inmediato."
            ),
            pie: "Este aviso de seguridad fue enviado desde la app Barber King.",
        }),
    };
};
