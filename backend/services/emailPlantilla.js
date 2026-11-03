import {
    codigoCorreo,
    disenoCorreo,
    escaparCorreo,
    notaCorreo,
    textoCorreo,
} from "./emailDiseno.js";

export const ASUNTO = "Código de recuperación";

export const contenido = (codigo, nombre = "") => {
    const saludo = nombre
        ? `Hola ${escaparCorreo(nombre)},`
        : "Hola,";

    return {
        text: `Barber King

${saludo}

Recibimos una solicitud para restablecer la contraseña de tu cuenta.

Tu código de recuperación es: ${codigo}

El código vence en 15 minutos. Si no solicitaste este cambio, ignora este mensaje y tu contraseña seguirá igual.

CORTE · ESTILO · EXPERIENCIA`,
        html: disenoCorreo({
            titulo: "Recupera tu contraseña",
            contenido: `
                ${textoCorreo(`${saludo} recibimos una solicitud para restablecer la contraseña de tu cuenta.`)}
                ${textoCorreo("Ingresa este código en la app para crear una contraseña nueva:")}
                ${codigoCorreo(codigo)}
                ${textoCorreo(`<span style="color:#D6B25E;font-weight:600;">El código vence en 15 minutos.</span>`)}
            `,
            nota: notaCorreo(
                "Si no solicitaste este cambio, ignora este mensaje. Tu contraseña actual seguirá funcionando."
            ),
            pie: "Este código fue enviado desde la app Barber King.",
        }),
    };
};
