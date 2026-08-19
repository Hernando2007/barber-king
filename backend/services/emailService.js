import nodemailer from "nodemailer";

// Configuración del servicio de correo
const transporter = nodemailer.createTransport({
    service: "gmail",

    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

// Envía el enlace para recuperar la contraseña
export const enviarCorreoRecuperacion = async (
    correo,
    token
) => {

    // Enlace que recibirá el usuario
    const enlace =
        `https://barberking.app/reset-password?token=${token}`;

    await transporter.sendMail({

        from:
            `"Barber King" <${process.env.EMAIL_USER}>`,

        to: correo,

        subject:
            "Recuperación de contraseña - Barber King",

        html: `
            <div style="font-family: Arial, sans-serif;">

                <h2>
                    Recuperación de contraseña
                </h2>

                <p>
                    Recibimos una solicitud para
                    restablecer tu contraseña.
                </p>

                <p>
                    Haz clic en el siguiente enlace:
                </p>

                <a href="${enlace}">
                    Restablecer contraseña
                </a>

                <p>
                    Este enlace es temporal.
                </p>

                <p>
                    Si no solicitaste este cambio,
                    puedes ignorar este correo.
                </p>

                <hr>

                <small>
                    Barber King ©
                </small>

            </div>
        `
    });
};