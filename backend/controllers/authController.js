import {
    registrarUsuario,
    iniciarSesion,
    solicitarRecuperacion,
    cambiarPassword
} from "../services/authService.js";



// REGISTRO


export const registrar = async (
    req,
    res
) => {

    try {

        const usuario =
            await registrarUsuario(
                req.body
            );

        res.status(201).json({
            success: true,
            message:
                "Usuario registrado correctamente.",
            data: usuario
        });

    } catch (error) {

        res.status(400).json({
            success: false,
            message: error.message
        });

    }
};



// LOGIN


export const login = async (
    req,
    res
) => {

    try {

        const resultado =
            await iniciarSesion(
                req.body
            );

        res.status(200).json({
            success: true,
            message:
                "Inicio de sesión exitoso.",
            token: resultado.token,
            usuario: resultado.usuario
        });

    } catch (error) {

        res.status(401).json({
            success: false,
            message: error.message
        });

    }
};



// SOLICITAR RECUPERACIÓN


export const forgotPassword = async (
    req,
    res
) => {

    try {

        const { correo } =
            req.body;

        if (!correo) {

            return res.status(400).json({
                success: false,
                message:
                    "El correo es obligatorio."
            });

        }

        await solicitarRecuperacion(
            correo
        );

        res.status(200).json({
            success: true,
            message:
                "Si el correo existe, recibirás un enlace de recuperación."
        });

    } catch (error) {

        res.status(400).json({
            success: false,
            message: error.message
        });

    }
};



// MOSTRAR PÁGINA DE CAMBIO DE CONTRASEÑA


export const mostrarResetPassword = async (
    req,
    res
) => {

    const { token } =
        req.query;

    if (!token) {

        return res.status(400).send(`
            <!DOCTYPE html>

            <html lang="es">

            <head>
                <meta charset="UTF-8">
                <title>Barber King</title>
            </head>

            <body
                style="
                    font-family: Arial;
                    text-align: center;
                    padding: 50px;
                "
            >

                <h2>
                    Enlace inválido
                </h2>

                <p>
                    No se recibió un token de recuperación.
                </p>

            </body>

            </html>
        `);

    }

    res.send(`
        <!DOCTYPE html>

        <html lang="es">

        <head>

            <meta charset="UTF-8">

            <meta
                name="viewport"
                content="
                    width=device-width,
                    initial-scale=1.0
                "
            >

            <title>
                Barber King
            </title>

        </head>

        <body
            style="
                font-family: Arial;
                background: #111;
                color: white;
                padding: 30px;
            "
        >

            <div
                style="
                    max-width: 400px;
                    margin: auto;
                    background: #222;
                    padding: 30px;
                    border-radius: 15px;
                "
            >

                <h1>
                    ✂️ Barber King
                </h1>

                <h2>
                    Nueva contraseña
                </h2>

                <p>
                    Escribe tu nueva contraseña.
                </p>

                <input
                    id="password"
                    type="password"
                    placeholder="Nueva contraseña"
                    minlength="6"
                    style="
                        width: 100%;
                        box-sizing: border-box;
                        padding: 12px;
                        margin-top: 15px;
                    "
                >

                <input
                    id="confirmar"
                    type="password"
                    placeholder="Confirmar contraseña"
                    minlength="6"
                    style="
                        width: 100%;
                        box-sizing: border-box;
                        padding: 12px;
                        margin-top: 15px;
                    "
                >

                <button
                    onclick="cambiarPassword()"
                    style="
                        width: 100%;
                        padding: 12px;
                        margin-top: 20px;
                        cursor: pointer;
                    "
                >
                    Cambiar contraseña
                </button>

                <p id="mensaje"></p>

            </div>


            <script>

                async function cambiarPassword() {

                    const password =
                        document.getElementById(
                            "password"
                        ).value;

                    const confirmar =
                        document.getElementById(
                            "confirmar"
                        ).value;

                    const mensaje =
                        document.getElementById(
                            "mensaje"
                        );


                    if (!password || !confirmar) {

                        mensaje.innerText =
                            "Complete todos los campos.";

                        return;
                    }


                    if (password.length < 6) {

                        mensaje.innerText =
                            "La contraseña debe tener mínimo 6 caracteres.";

                        return;
                    }


                    if (password !== confirmar) {

                        mensaje.innerText =
                            "Las contraseñas no coinciden.";

                        return;
                    }


                    try {

                        const respuesta =
                            await fetch(
                                "/api/auth/reset-password",
                                {
                                    method: "POST",

                                    headers: {
                                        "Content-Type":
                                            "application/json"
                                    },

                                    body: JSON.stringify({

                                        token:
                                            "${token}",

                                        password:
                                            password

                                    })
                                }
                            );


                        const data =
                            await respuesta.json();


                        mensaje.innerText =
                            data.message;


                        if (data.success) {

                            mensaje.innerText =
                                "Contraseña actualizada correctamente. Ya puedes cerrar esta página e iniciar sesión.";

                        }

                    } catch (error) {

                        mensaje.innerText =
                            "Error al conectar con el servidor.";

                    }

                }

            </script>

        </body>

        </html>
    `);
};



// CAMBIAR CONTRASEÑA


export const resetPassword = async (
    req,
    res
) => {

    try {

        const {
            token,
            password
        } = req.body;

        await cambiarPassword(
            token,
            password
        );

        res.status(200).json({
            success: true,
            message:
                "Contraseña actualizada correctamente."
        });

    } catch (error) {

        res.status(400).json({
            success: false,
            message: error.message
        });

    }
};