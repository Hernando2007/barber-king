import nodemailer from "nodemailer";

const HOSTS_LOCALES = ["localhost", "127.0.0.1", "::1", ""];
const ASUNTO = "Código de recuperación";

const leerSmtp = () => {
    const host = (process.env.SMTP_HOST || "").trim();
    const puerto = Number(process.env.SMTP_PORT || 587);
    const usuario = (process.env.EMAIL_USER || "").trim();
    const clave = process.env.EMAIL_PASS || "";

    return {
        host,
        puerto,
        usuario,
        clave,
        esLocal: HOSTS_LOCALES.includes(host.toLowerCase()),
        completo: Boolean(host && usuario && clave),
        secure: process.env.SMTP_SECURE === "true" || puerto === 465,
    };
};

const leerResend = () => ({
    clave: (process.env.RESEND_API_KEY || "").trim(),
    remitente: (
        process.env.EMAIL_FROM ||
        "Barber King <onboarding@resend.dev>"
    ).trim(),
});

const crearTransporte = () => {
    const smtp = leerSmtp();

    if (!smtp.completo) {
        return null;
    }

    return nodemailer.createTransport({
        host: smtp.host,
        port: smtp.puerto,
        secure: smtp.secure,
        auth: {
            user: smtp.usuario,
            pass: smtp.clave,
        },
    });
};

export const correoConfigurado = () => {
    const smtp = leerSmtp();
    return Boolean(leerResend().clave) || (smtp.completo && !smtp.esLocal);
};

export const verificarEmailService = async () => {
    if (leerResend().clave) {
        console.log("✓ Correo configurado por Resend (API HTTP).");
        return;
    }

    const smtp = leerSmtp();

    if (!smtp.completo) {
        console.warn(
            "⚠ Correo sin configurar: define RESEND_API_KEY o SMTP_HOST, EMAIL_USER y EMAIL_PASS."
        );
        return;
    }

    if (smtp.esLocal) {
        console.warn(
            "⚠ SMTP_HOST apunta a localhost. Usa el host real de tu proveedor (por ejemplo smtp.gmail.com)."
        );
        return;
    }

    try {
        await crearTransporte().verify();
        console.log("✓ Servicio de correo SMTP conectado.");
    } catch (error) {
        console.error("✗ Error SMTP:", error.message);
    }
};

const contenido = (codigo) => ({
    text: `
Tu código de recuperación es:

${codigo}

Este código expira en 15 minutos.
`,
    html: `
<div style="font-family:Arial,sans-serif;max-width:600px;margin:auto;padding:20px;">
    <h2>Recuperación de contraseña</h2>
    <p>Has solicitado recuperar tu contraseña.</p>
    <p>Utiliza el siguiente código:</p>
    <div style="font-size:32px;font-weight:bold;letter-spacing:8px;padding:20px;background:#f5f5f5;text-align:center;border-radius:8px;">
        ${codigo}
    </div>
    <p style="margin-top:20px;">Este código expira en <strong>15 minutos</strong>.</p>
    <p>Si no solicitaste este cambio, puedes ignorar este mensaje.</p>
</div>
`,
});

const enviarPorResend = async (correo, codigo) => {
    const { clave, remitente } = leerResend();
    const { text, html } = contenido(codigo);

    const respuesta = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
            Authorization: `Bearer ${clave}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            from: remitente,
            to: [correo],
            subject: ASUNTO,
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

export const enviarCodigoRecuperacion = async (correo, codigo) => {
    try {
        if (leerResend().clave) {
            await enviarPorResend(correo, codigo);
        } else {
            const transporte = crearTransporte();

            if (!transporte) {
                throw new Error(
                    "El servicio de correo no está configurado. Define RESEND_API_KEY o las variables SMTP."
                );
            }

            const { text, html } = contenido(codigo);

            const info = await transporte.sendMail({
                from: `"${process.env.APP_NAME || "Barber King"}" <${process.env.EMAIL_USER}>`,
                to: correo,
                subject: ASUNTO,
                text,
                html,
            });

            console.log("Correo enviado:", info.messageId);
        }

        return true;
    } catch (error) {
        console.error("Error enviando correo:", error.message);
        throw new Error(
            "No fue posible enviar el correo de recuperación. Revisa RESEND_API_KEY o la configuración SMTP del servidor."
        );
    }
};
