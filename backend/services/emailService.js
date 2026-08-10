import nodemailer from "nodemailer";

export const enviarCorreoRecuperacion = async (
    correo,
    enlace
) => {

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

        subject:
            "Recuperación de contraseña - Barber King",

        html: `
            <div
                style="
                    font-family: Arial, sans-serif;
                    max-width: 600px;
                    margin: auto;
                    padding: 20px;
                "
            >

                <h2>
                    Recuperación de contraseña
                </h2>

                <p>
                    Hola.
                </p>

                <p>
                    Recibimos una solicitud para
                    restablecer tu contraseña de
                    Barber King.
                </p>

                <p>
                    Haz clic en el siguiente enlace
                    para crear una nueva contraseña:
                </p>

                <p>
                    <a
                        href="${enlace}"
                        style="
                            background-color: #d4af37;
                            color: black;
                            padding: 12px 20px;
                            text-decoration: none;
                            border-radius: 5px;
                            display: inline-block;
                        "
                    >
                        Restablecer contraseña
                    </a>
                </p>

                <p>
                    Este enlace tiene un tiempo
                    limitado de validez.
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