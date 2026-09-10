import Groq from "groq-sdk";
import supabase from "../config/supabase.js";

const groq = new Groq({
    apiKey: process.env.GROQ_API_KEY
});

// Chat normal
export const enviarMensaje = async (
    mensaje,
    usuarioId,
    sesionId
) => {
    const sesion = sesionId || `sesion_${Date.now()}`;

    const { data: servicios } = await supabase
        .from("servicios")
        .select("nombre, precio, descripcion");

    const catalogo = servicios?.length
        ? servicios.map(s =>
            `- ${s.nombre}: $${s.precio} COP - ${s.descripcion || ""}`
        ).join("\n")
        : "No hay servicios disponibles.";

    const respuesta = await groq.chat.completions.create({
        model: "qwen/qwen3.6-27b",
        reasoning_effort: "none",
        messages: [
            {
                role: "system",
                content: `
Eres el asistente virtual de Barber King.
Ayuda con servicios, precios y cortes de cabello.
Responde de forma clara y breve.

SERVICIOS:
${catalogo}
`
            },
            {
                role: "user",
                content: mensaje
            }
        ],
        temperature: 0.3,
        max_tokens: 500
    });

    const texto =
        respuesta.choices[0]?.message?.content ||
        "No pude generar una respuesta.";

    await supabase.from("mensajes_chat").insert([
        {
            sesion_id: sesion,
            usuario_id: usuarioId,
            emisor: "user",
            mensaje: mensaje.trim(),
            tipo_mensaje: "texto"
        },
        {
            sesion_id: sesion,
            usuario_id: usuarioId,
            emisor: "bot",
            mensaje: texto,
            tipo_mensaje: "texto"
        }
    ]);

    return {
        respuesta: texto,
        sesionId: sesion
    };
};

// Recomendación de corte mediante imagen
export const recomendarCorte = async (
    imagenUrl,
    usuarioId,
    sesionId
) => {
    const sesion =
        sesionId || `sesion_ia_${Date.now()}`;

    const respuesta = await groq.chat.completions.create({
        model: "qwen/qwen3.6-27b",
        reasoning_effort: "none",
        response_format: {
            type: "json_object"
        },
        messages: [
            {
                role: "system",
                content: `
Eres un asesor de cortes de cabello
para Barber King.

Analiza únicamente características
visibles relacionadas con el cabello
y el estilo.

No identifiques a la persona.
No hagas diagnósticos médicos.
No hagas comparaciones de atractivo.

Devuelve solamente JSON:

{
  "corte_principal": "nombre del corte",
  "explicacion": "explicación breve",
  "alternativas": [
    "corte 1",
    "corte 2"
  ],
  "recomendacion_barbero": "consejo breve"
}
`
            },
            {
                role: "user",
                content: [
                    {
                        type: "text",
                        text: "Analiza la imagen y recomienda un corte de cabello."
                    },
                    {
                        type: "image_url",
                        image_url: {
                            url: imagenUrl
                        }
                    }
                ]
            }
        ],
        temperature: 0.2,
        max_tokens: 400
    });

    let texto =
        respuesta.choices[0]?.message?.content ||
        "{}";

    texto = texto
        .replace(/```json/gi, "")
        .replace(/```/g, "")
        .trim();

    let recomendacion;

    try {
        recomendacion = JSON.parse(texto);
    } catch (error) {
        throw new Error(
            "La IA devolvió una respuesta que no es JSON válido."
        );
    }

    if (!recomendacion.corte_principal) {
        throw new Error(
            "La IA no devolvió una recomendación válida."
        );
    }

    // Guardamos la solicitud y la respuesta
    // junto con la URL de Cloudinary.
    const { error } = await supabase
        .from("mensajes_chat")
        .insert([
            {
                sesion_id: sesion,
                usuario_id: usuarioId,
                emisor: "user",
                mensaje:
                    "Solicitud de recomendación de corte mediante IA.",
                imagen_url: imagenUrl,
                tipo_mensaje:
                    "recomendacion_corte",
                metadata: {
                    tipo: "solicitud"
                }
            },
            {
                sesion_id: sesion,
                usuario_id: usuarioId,
                emisor: "bot",
                mensaje:
                    recomendacion.corte_principal,
                imagen_url: imagenUrl,
                tipo_mensaje:
                    "recomendacion_corte",
                metadata: recomendacion
            }
        ]);

    if (error) {
        console.error(
            "Error guardando recomendación:",
            error
        );

        throw new Error(
            "La recomendación fue generada, pero no se pudo guardar."
        );
    }

    return {
        sesionId: sesion,
        imagenUrl,
        recomendacion
    };
};

// Obtener historial
export const obtenerHistorial = async (
    sesionId,
    usuarioId
) => {
    const { data, error } = await supabase
        .from("mensajes_chat")
        .select(`
            id,
            emisor,
            mensaje,
            imagen_url,
            tipo_mensaje,
            metadata,
            created_at
        `)
        .eq("sesion_id", sesionId)
        .eq("usuario_id", usuarioId)
        .order("created_at", {
            ascending: true
        });

    if (error) {
        throw new Error(
            `Error obteniendo historial: ${error.message}`
        );
    }

    return data || [];
};