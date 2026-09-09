import {
    enviarMensaje,
    recomendarCorte,
    obtenerHistorial
} from "../services/chatService.js";


/*
    CHAT GENERAL
*/
export const chatearConBarberKing = async (
    req,
    res
) => {

    try {

        const {
            mensaje,
            sesionId
        } = req.body;


        if (
            !mensaje ||
            !mensaje.trim()
        ) {

            return res.status(400).json({

                success:
                    false,

                message:
                    "Debes enviar un mensaje."

            });

        }


        /*
            Usuario obtenido del JWT.
        */
        const usuarioId =
            req.usuario?.id ||
            null;


        const resultado =
            await enviarMensaje(

                mensaje,

                usuarioId,

                sesionId ||
                    null

            );


        return res.status(200).json({

            success:
                true,

            respuesta:
                resultado.respuesta,

            sesionId:
                resultado.sesionId

        });


    } catch (error) {

        console.error(
            "Error en Barber King Chat:",
            error
        );


        return res.status(500).json({

            success:
                false,

            message:
                "Error al procesar la respuesta.",

            error:
                error.message

        });

    }

};


/*
    RECOMENDAR CORTE CON IA

    Recibe la fotografía mediante Multer,
    obtiene el usuario desde el JWT,
    ejecuta la IA y guarda el resultado
    en mensajes_chat.
*/
export const recomendarCorteConIA =
    async (
        req,
        res
    ) => {

        try {

            /*
                Comprobar fotografía.
            */
            if (!req.file) {

                return res.status(400).json({

                    success:
                        false,

                    message:
                        "Debes enviar una fotografía."

                });

            }


            /*
                Usuario autenticado.
            */
            const usuarioId =
                req.usuario?.id ||
                null;


            /*
                La sesión puede venir desde
                Flutter o crearse automáticamente.
            */
            const sesionId =
                req.body.sesionId ||
                null;


            /*
                Ejecutar recomendación.
            */
            const resultado =
                await recomendarCorte(

                    req.file.path,

                    usuarioId,

                    sesionId

                );


            return res.status(200).json({

                success:
                    true,

                sesionId:
                    resultado.sesionId,

                recomendacion:
                    resultado.recomendacion

            });


        } catch (error) {

            console.error(
                "Error recomendando corte:",
                error
            );


            return res.status(500).json({

                success:
                    false,

                message:
                    "No fue posible generar la recomendación.",

                error:
                    error.message

            });

        }

    };


/*
    OBTENER HISTORIAL DEL CHAT
*/
export const obtenerHistorialBarberKing =
    async (
        req,
        res
    ) => {

        try {

            const {
                sesionId
            } = req.params;


            if (!sesionId) {

                return res.status(400).json({

                    success:
                        false,

                    message:
                        "Debes proporcionar una sesión."

                });

            }


            /*
                Usuario autenticado.
            */
            const usuarioId =
                req.usuario?.id ||
                null;


            const historial =
                await obtenerHistorial(

                    sesionId,

                    usuarioId

                );


            return res.status(200).json({

                success:
                    true,

                historial:
                    historial

            });


        } catch (error) {

            console.error(
                "Error obteniendo historial:",
                error
            );


            return res.status(500).json({

                success:
                    false,

                message:
                    "Error al consultar historial.",

                error:
                    error.message

            });

        }

    };