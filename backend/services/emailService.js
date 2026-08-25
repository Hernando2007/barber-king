import nodemailer from "nodemailer";

const transporter = nodemailer.createTransport({

    service: "gmail",

    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }

});

// Envía correo de recuperación
export const enviarCorreoRecuperacion = async (
    correo,
    token
) => {

    const frontendUrl =
        process.env.FRONTEND_URL ||
        "https://barberking.app";

    const enlace =
        `${frontendUrl}/reset-password?token=${token}`;

    await transporter.sendMail({

        from:
            `"Barber King" <${process.env.EMAIL_USER}>`,

        to: correo,

        subject:
            "Recuperación de contraseña - Barber King",

        html: `
            <div style="
                font-family: Arial, sans-serif;
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
            ">

                <h2>
                    Recuperación de contraseña
                </h2>

                <p>
                    Hemos recibido una solicitud para
                    restablecer tu contraseña.
                </p>

                <p>
                    Haz clic en el botón para continuar:
                </p>

                <p style="margin:30px 0;">

                    <a
                        href="${enlace}"
                        style="
                            background:#000;
                            color:#fff;
                            padding:12px 24px;
                            text-decoration:none;
                            border-radius:6px;
                            display:inline-block;
                        "
                    >
                        Restablecer contraseña
                    </a>

                </p>

                <p>
                    Este enlace expirará en 15 minutos.
                </p>

                <p>
                    Si no solicitaste este cambio,
                    puedes ignorar este correo.
                </p>

                <hr>

                <small>
                    Barber King © ${new Date().getFullYear()}
                </small>

            </div>
        `

    });

};