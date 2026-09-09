import Groq from "groq-sdk";
import fs from "fs";
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

    const prompt = `
Eres el asistente virtual de Barber King.
Ayuda al usuario con servicios, precios y cortes de cabello.
Responde de forma clara y breve.

SERVICIOS:
${catalogo}
`;

    const respuesta = await groq.chat.completions.create({
        model: "qwen/qwen3.6-27b",
        messages: [
            { role: "system", content: prompt },
            { role: "user", content: mensaje }
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

// Recomendar corte usando una imagen
export const recomendarCorte = async (
    rutaImagen,
    usuarioId,
    sesionId
) => {
    const sesion = sesionId || `sesion_ia_${Date.now()}`;

    try {
        const imagen = fs.readFileSync(rutaImagen);
        const base64 = imagen.toString("base64");

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
Eres un asesor de cortes de cabello de Barber King.

Analiza únicamente características visibles y generales
relacionadas con el estilo del cabello.

No identifiques a la persona.
No hagas diagnósticos médicos.
No hagas comparaciones de atractivo.

Devuelve SOLO JSON con esta estructura:
{
  "corte_principal": "nombre del corte",
  "explicacion": "explicación breve",
  "alternativas": ["corte 1", "corte 2"],
  "recomendacion_barbero": "consejo breve"
}
`
                },
                {
                    role: "user",
                    content: [
                        {
                            type: "text",
                            text: "Recomiéndame un corte de cabello basándote en la imagen."
                        },
                        {
                            type: "image_url",
                            image_url: {
                                url: `data:image/jpeg;base64,${base64}`
                            }
                        }
                    ]
                }
            ],
            temperature: 0.2,
            max_tokens: 400
        });

        let texto =
            respuesta.choices[0]?.message?.content || "{}";

        // Elimina posibles bloques Markdown
        texto = texto
            .replace(/```json/gi, "")
            .replace(/```/g, "")
            .trim();

        const recomendacion = JSON.parse(texto);

        // Guardar solicitud y respuesta en mensajes_chat
        await supabase.from("mensajes_chat").insert([
            {
                sesion_id: sesion,
                usuario_id: usuarioId,
                emisor: "user",
                mensaje: "Solicitud de recomendación de corte mediante IA.",
                tipo_mensaje: "recomendacion_corte",
                metadata: {
                    tipo: "solicitud",
                    tiene_imagen: true
                }
            },
            {
                sesion_id: sesion,
                usuario_id: usuarioId,
                emisor: "bot",
                mensaje: recomendacion.corte_principal,
                tipo_mensaje: "recomendacion_corte",
                metadata: recomendacion
            }
        ]);

        return {
            sesionId: sesion,
            recomendacion
        };

    } finally {
        // Eliminar imagen temporal
        if (fs.existsSync(rutaImagen)) {
            fs.unlinkSync(rutaImagen);
        }
    }
};

// Obtener historial
export const obtenerHistorial = async (
    sesionId,
    usuarioId
) => {
    let consulta = supabase
        .from("mensajes_chat")
        .select(`
            id,
            emisor,
            mensaje,
            tipo_mensaje,
            metadata,
            created_at
        `)
        .eq("sesion_id", sesionId)
        .order("created_at", { ascending: true });

    if (usuarioId) {
        consulta = consulta.eq("usuario_id", usuarioId);
    }

    const { data, error } = await consulta;

    if (error) {
        throw new Error(
            `Error obteniendo historial: ${error.message}`
        );
    }

    return data || [];
};