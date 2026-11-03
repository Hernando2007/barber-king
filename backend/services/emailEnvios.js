import {
    crearTransporte,
    leerBrevo,
    leerResend,
} from "./emailConfig.js";

const enviarPorResend = async (correo, asunto, { text, html }) => {
    const { clave, remitente } = leerResend();

    const respuesta = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
            Authorization: `Bearer ${clave}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            from: remitente,
            to: [correo],
            subject: asunto,
            text,
            html,
        }),
    });

    if (!respuesta.ok) {
        const detalle = await respuesta.text().catch(() => "");
        throw new Error(
            `Resend respondió ${respuesta.status}. ${detalle}`.trim()
        );
    }
};

const enviarPorBrevo = async (correo, asunto, { text, html }) => {
    const { clave, remitente } = leerBrevo();

    const respuesta = await fetch("https://api.brevo.com/v3/smtp/email", {
        method: "POST",
        headers: {
            "api-key": clave,
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            sender: {
                name: process.env.APP_NAME || "Barber King",
                email: remitente,
            },
            to: [{ email: correo }],
            subject: asunto,
            htmlContent: html,
            textContent: text,
        }),
    });

    if (!respuesta.ok) {
        const detalle = await respuesta.text().catch(() => "");
        throw new Error(
            `Brevo respondió ${respuesta.status}. ${detalle}`.trim()
        );
    }
};

const enviarPorSmtp = async (correo, asunto, { text, html }) => {
    const transporte = crearTransporte();

    if (!transporte) {
        throw new Error(
            "El servicio de correo no está configurado. Define RESEND_API_KEY, BREVO_API_KEY o las variables SMTP."
        );
    }

    const info = await transporte.sendMail({
        from: `"${process.env.APP_NAME || "Barber King"}" <${process.env.EMAIL_USER}>`,
        to: correo,
        subject: asunto,
        text,
        html,
    });

    console.log("Correo enviado:", info.messageId);
};

export const enviarCorreo = async (correo, asunto, cuerpo) => {
    try {
        if (leerResend().clave) {
            await enviarPorResend(correo, asunto, cuerpo);
        } else if (leerBrevo().clave) {
            await enviarPorBrevo(correo, asunto, cuerpo);
        } else {
            await enviarPorSmtp(correo, asunto, cuerpo);
        }

        return true;
    } catch (error) {
        console.error("Error enviando correo:", error.message);
        throw error;
    }
};
