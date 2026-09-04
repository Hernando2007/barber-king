import Groq from "groq-sdk";
import supabase from "../config/supabase.js"; // Ruta a tu cliente de Supabase existente

const groq = new Groq({
    apiKey: process.env.GROQ_API_KEY
});


export const chatearConBarberKing = async (
    req,
    res
) => {

    try {

        const {
            mensaje,
            sesionId,
            usuarioId
        } = req.body;


        if (!mensaje || !mensaje.trim()) {

            return res.status(400).json({

                message:
                    "Debes enviar un mensaje."

            });

        }


        // Si el cliente no manda sesion,
        // creamos un identificador temporal
        const idSesionValido =
            sesionId ||
            `barberking_sesion_${Date.now()}`;


        // 1. Obtener información de Barber King
        // desde Supabase
        const {
            data: servicios,
            error: errorServicios
        } = await supabase
            .from("servicios")
            .select("*");


        if (errorServicios) {

            console.error(
                "Error al consultar servicios:",
                errorServicios.message
            );

            return res.status(500).json({

                message:
                    "Error al consultar los servicios."

            });

        }


        // 2. Armar catálogo de servicios
        const catalogoTexto =
            servicios && servicios.length > 0

                ? servicios.map(servicio =>
                    `- ${servicio.nombre || servicio.nombre_servicio || "Servicio"}: $${Number(servicio.precio || 0).toLocaleString("es-CO")} COP | Descripcion: ${servicio.descripcion || "Sin descripción"}`
                ).join("\n")

                : "No hay servicios registrados actualmente.";


        const systemPrompt = `
Eres el asistente virtual de "Barber King",
una plataforma de barberías y servicios de barbería
en Colombia.

Eres amable, profesional, claro y servicial.

SERVICIOS ACTUALES DE BARBER KING:

${catalogoTexto}


REGLAS DE ATENCION:

1. Si el cliente solo saluda
   (ej: "Hola", "¿Cómo estás?"),
   responde con cortesía y cercanía sin
   mostrar todos los servicios ni precios.

2. Da información sobre servicios y precios
   únicamente cuando el cliente pregunte
   por ellos.

3. Especifica los valores siempre en pesos
   colombianos ($ COP).

4. Puedes orientar al cliente sobre servicios
   de barbería, cortes de cabello, barba,
   estilos y funcionamiento general de
   Barber King.

5. No inventes servicios, precios,
   barberías, horarios ni disponibilidad.

6. Si el cliente pregunta por una cita,
   disponibilidad o un horario específico,
   indica que debe consultarse la información
   disponible en Barber King.

7. No inventes información que no esté
   disponible en los datos proporcionados.

8. Sé conciso y completa tus oraciones.
`;


        // 3. Inferencia con Groq
        const completion =
            await groq.chat.completions.create({

                model:
                    "openai/gpt-oss-20b",

                messages: [

                    {
                        role:
                            "system",

                        content:
                            systemPrompt
                    },

                    {
                        role:
                            "user",

                        content:
                            mensaje
                    }

                ],

                temperature:
                    0.3,

                max_tokens:
                    500

            });


        const respuestaTexto =
            completion
                .choices[0]
                ?.message
                ?.content ||
            "No pude generar una respuesta.";


        // 4. Guardar ambos mensajes
        // en el historial de Barber King
        const registrosAInsertar = [

            {

                sesion_id:
                    idSesionValido,

                usuario_id:
                    usuarioId || null,

                emisor:
                    "user",

                mensaje:
                    mensaje.trim()

            },

            {

                sesion_id:
                    idSesionValido,

                usuario_id:
                    usuarioId || null,

                emisor:
                    "bot",

                mensaje:
                    respuestaTexto

            }

        ];


        const {
            error: errorInsert
        } = await supabase

            .from("mensajes_chat")

            .insert(
                registrosAInsertar
            );


        if (errorInsert) {

            console.error(
                "Error guardando el historial en Supabase:",
                errorInsert.message
            );

            // No frenamos la respuesta
            // al cliente aunque falle
            // el guardado en BD

        }


        return res.status(200).json({

            respuesta:
                respuestaTexto,

            sesionId:
                idSesionValido

        });


    } catch (error) {

        console.error(
            "Error en Barber King Chat:",
            error
        );

        return res.status(500).json({

            message:
                "Error al procesar la respuesta",

            error:
                error.message

        });

    }

};


// Endpoint extra para recuperar
// la conversación si el usuario vuelve
// a abrir la app
export const obtenerHistorialBarberKing = async (
    req,
    res
) => {

    try {

        const {
            sesionId
        } = req.params;


        const {
            data: historial,
            error
        } = await supabase

            .from("mensajes_chat")

            .select(
                "emisor, mensaje, created_at"
            )

            .eq(
                "sesion_id",
                sesionId
            )

            .order(
                "created_at",
                {
                    ascending: true
                }
            );


        if (error) {

            return res.status(500).json({

                message:
                    "Error al consultar historial",

                error:
                    error.message

            });

        }


        return res.status(200).json({

            historial:
                historial || []

        });


    } catch (error) {

        return res.status(500).json({

            message:
                "Error interno",

            error:
                error.message

        });

    }

};