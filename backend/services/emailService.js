import nodemailer from "nodemailer";

export const enviarCorreoRecuperacion = async (correo, enlace) => {

    const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
            user: process.env.EMAIL_USER,
            pass: process.env.EMAIL_PASS
        }
    });

    await transporter.sendMail({
        from: `"Barber King" <${process.env.EMAIL_USER}>`,
        to: correo,
        subject: "Recuperación de contraseña - Barber King",
        html: `
            <div style="font-family: Arial, sans-serif;">
                <h2>Recuperación de contraseña</h2>

                <p>Hola.</p>

                <p>Recibimos una solicitud para restablecer tu contraseña.</p>

                <p>Haz clic en el siguiente enlace:</p>

                <a href="${enlace}">
                    Restablecer contraseña
                </a>

                <br><br>

                <p>Si no solicitaste este cambio, puedes ignorar este correo.</p>

                <hr>

                <small>Barber King ©</small>
            </div>
        `
    });

};