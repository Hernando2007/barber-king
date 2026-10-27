import nodemailer from "nodemailer";

const HOSTS_LOCALES = ["localhost", "127.0.0.1", "::1", ""];

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
    return smtp.completo && !smtp.esLocal;
};

export const verificarEmailService = async () => {
    const smtp = leerSmtp();

    if (!smtp.completo) {
        console.warn(
            "⚠ Correo sin configurar: define SMTP_HOST, EMAIL_USER y EMAIL_PASS en backend/.env"
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
        console.log("✓ Servicio de correo conectado.");
    } catch (error) {
        console.error("✗ Error SMTP:", error.message);
    }
};

export const enviarCodigoRecuperacion = async (correo, codigo) => {
    const transporte = crearTransporte();

    if (!transporte) {
        throw new Error(
            "El servicio de correo no está configurado en el servidor. Define SMTP_HOST, EMAIL_USER y EMAIL_PASS."
        );
    }

    try {
        const info = await transporte.sendMail({
            from: `"${process.env.APP_NAME || "Barber King"}" <${process.env.EMAIL_USER}>`,
            to: correo,
            subject: "Código de recuperación",
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

        console.log("Correo enviado:", info.messageId);
        return true;
    } catch (error) {
        console.error("Error enviando correo:", error.message);
        throw new Error(
            "No fue posible enviar el correo de recuperación. Revisa la configuración SMTP del servidor."
        );
    }
};
