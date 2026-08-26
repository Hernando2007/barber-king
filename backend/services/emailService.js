import nodemailer from "nodemailer";

const transporter = nodemailer.createTransport({

    host: process.env.SMTP_HOST,

    port: Number(
        process.env.SMTP_PORT
    ),

    secure:
        process.env.SMTP_SECURE === "true",

    auth: {

        user:
            process.env.EMAIL_USER,

        pass:
            process.env.EMAIL_PASS

    }

});

export const verificarEmailService =
    async () => {

        try {

            await transporter.verify();

            console.log(
                "✓ Servicio de correo conectado."
            );

        } catch (error) {

            console.error(
                "✗ Error SMTP:",
                error.message
            );

        }

    };

export const enviarCodigoRecuperacion =
    async (
        correo,
        codigo
    ) => {

        try {

            const info =
                await transporter.sendMail({

                    from:
                        `"${process.env.APP_NAME}" <${process.env.EMAIL_USER}>`,

                    to: correo,

                    subject:
                        "Código de recuperación",

                    text: `
Tu código de recuperación es:

${codigo}

Este código expira en 15 minutos.
`,

                    html: `
<div style="
font-family:Arial,sans-serif;
max-width:600px;
margin:auto;
padding:20px;
">

<h2>
Recuperación de contraseña
</h2>

<p>
Has solicitado recuperar tu contraseña.
</p>

<p>
Utiliza el siguiente código:
</p>

<div style="
font-size:32px;
font-weight:bold;
letter-spacing:8px;
padding:20px;
background:#f5f5f5;
text-align:center;
border-radius:8px;
">
${codigo}
</div>

<p style="
margin-top:20px;
">
Este código expira en
<strong>15 minutos</strong>.
</p>

<p>
Si no solicitaste este cambio,
puedes ignorar este mensaje.
</p>

</div>
`

                });

            console.log(
                "Correo enviado:",
                info.messageId
            );

            return true;

        } catch (error) {

            console.error(
                "Error enviando correo:",
                error.message
            );

            throw new Error(
                "No fue posible enviar el correo de recuperación."
            );

        }

    };