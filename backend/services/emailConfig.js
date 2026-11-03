import nodemailer from "nodemailer";

const HOSTS_LOCALES = ["localhost", "127.0.0.1", "::1", ""];

export const leerSmtp = () => {
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

export const leerResend = () => ({
    clave: (process.env.RESEND_API_KEY || "").trim(),
    remitente: (
        process.env.EMAIL_FROM ||
        "Barber King <onboarding@resend.dev>"
    ).trim(),
});

export const leerBrevo = () => ({
    clave: (process.env.BREVO_API_KEY || "").trim(),
    remitente: (process.env.EMAIL_USER || "").trim(),
});

export const crearTransporte = () => {
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
    return (
        Boolean(leerResend().clave) ||
        Boolean(leerBrevo().clave) ||
        (smtp.completo && !smtp.esLocal)
    );
};

export const verificarEmailService = async () => {
    if (leerResend().clave) {
        console.log("✓ Correo configurado por Resend (API HTTP).");
        return;
    }

    if (leerBrevo().clave) {
        console.log("✓ Correo configurado por Brevo (API HTTP).");
        return;
    }

    const smtp = leerSmtp();

    if (!smtp.completo) {
        console.warn(
            "⚠ Correo sin configurar: define RESEND_API_KEY, BREVO_API_KEY o las variables SMTP."
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
