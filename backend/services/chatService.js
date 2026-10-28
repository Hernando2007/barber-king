import Groq from "groq-sdk";
import supabase from "../config/supabase.js";
import { httpError } from "../utils/httpError.js";
import { contieneProfanidad } from "../utils/profanidad.js";

const groq = new Groq({
    apiKey: process.env.GROQ_API_KEY,
});

const MODELO_TEXTO = "openai/gpt-oss-20b";
const MODELO_VISION = "qwen/qwen3.8-27b";

const obtenerCatalogo = async () => {
    const { data: servicios } = await supabase
        .from("servicios")
        .select("nombre, precio, descripcion, duracion")
        .eq("estado", true)
        .order("nombre", { ascending: true });

    if (!servicios?.length) {
        return "No hay servicios disponibles en este momento.";
    }

    return servicios
        .map(
            (servicio) =>
                `- ${servicio.nombre}: $${servicio.precio} COP, ${servicio.duracion} min. ${servicio.descripcion || ""}`
        )
        .join("\n");
};

const obtenerBarberos = async () => {
    const { data } = await supabase
        .from("barberos")
        .select(`
            especialidad,
            disponible,
            usuarios(nombres, apellidos)
        `)
        .eq("disponible", true);

    if (!data?.length) {
        return "No hay barberos disponibles en este momento.";
    }

    return data
        .map((barbero) => {
            const usuario = Array.isArray(barbero.usuarios)
                ? barbero.usuarios[0]
                : barbero.usuarios;
            const nombre = usuario
                ? `${usuario.nombres || ""} ${usuario.apellidos || ""}`.trim()
                : "Barbero";
            return `- ${nombre}: ${barbero.especialidad || "corte y estilo"}`;
        })
        .join("\n");
};

const limpiarJson = (texto) =>
    String(texto || "")
        .replace(/```json/gi, "")
        .replace(/```/g, "")
        .trim();

const extraerJson = (texto) => {
    const limpio = limpiarJson(texto);

    try {
        return JSON.parse(limpio);
    } catch {
        const inicio = limpio.indexOf("{");
        const fin = limpio.lastIndexOf("}");

        if (inicio === -1 || fin <= inicio) {
            throw httpError(
                502,
                "La IA no devolvió una recomendación válida. Intenta con otra foto."
            );
        }

        try {
            return JSON.parse(limpio.slice(inicio, fin + 1));
        } catch {
            throw httpError(
                502,
                "La IA no devolvió una recomendación válida. Intenta con otra foto."
            );
        }
    }
};

const normalizarRecomendacion = (datos) => {
    if (!datos || typeof datos !== "object") {
        throw httpError(
            502,
            "La IA no devolvió una recomendación válida."
        );
    }

    const corte = String(
        datos.corte_principal || datos.corte || ""
    ).trim();

    if (!corte) {
        throw httpError(
            502,
            "La IA no devolvió una recomendación válida."
        );
    }

    const alternativas = Array.isArray(datos.alternativas)
        ? datos.alternativas
              .map((item) => String(item).trim())
              .filter(Boolean)
              .slice(0, 3)
        : [];

    return {
        corte_principal: corte,
        explicacion: String(
            datos.explicacion || "Recomendación generada según tu foto."
        ).trim(),
        alternativas,
        recomendacion_barbero: String(
            datos.recomendacion_barbero ||
                "Muestra esta referencia a tu barbero para ajustar el corte."
        ).trim(),
    };
};

export const enviarMensaje = async (
    mensaje,
    usuarioId,
    sesionId
) => {
    if (contieneProfanidad(mensaje)) {
        throw httpError(
            400,
            "El mensaje tiene palabras no permitidas. Reformúlalo para enviarlo."
        );
    }

    const sesion = sesionId || `sesion_${Date.now()}`;

    const [catalogo, barberos] = await Promise.all([
        obtenerCatalogo(),
        obtenerBarberos(),
    ]);

    const { data: historial } = await supabase
        .from("mensajes_chat")
        .select("emisor, mensaje")
        .eq("sesion_id", sesion)
        .eq("usuario_id", usuarioId)
        .in("tipo_mensaje", ["texto"])
        .order("created_at", { ascending: false })
        .limit(8);

    const contexto = (historial || [])
        .reverse()
        .map((item) => ({
            role:
                item.emisor === "bot"
                    ? "assistant"
                    : "user",
            content: item.mensaje,
        }));

    const respuesta = await groq.chat.completions.create({
        model: MODELO_TEXTO,
        reasoning_effort: "low",
        messages: [
            {
                role: "system",
                content: `Eres BarberKing IA, el asistente virtual de la barbería Barber King.
Ayudas a los clientes con servicios, precios, duración, recomendaciones de estilo y cómo agendar una cita.
Responde siempre en español, de forma clara, amable y breve (máximo 5 oraciones).
No inventes precios ni horarios que no estén en el catálogo.

SERVICIOS DISPONIBLES:
${catalogo}

BARBEROS DISPONIBLES:
${barberos}

Si el cliente quiere reservar, indícale que puede hacerlo desde la sección "Citas" de la aplicación.`,
            },
            ...contexto,
            {
                role: "user",
                content: mensaje,
            },
        ],
        temperature: 0.4,
        max_tokens: 500,
    });

    const texto =
        respuesta.choices[0]?.message?.content?.trim() ||
        "No pude generar una respuesta en este momento. Intenta de nuevo.";

    const { error: errorInsert } = await supabase
        .from("mensajes_chat")
        .insert([
            {
                sesion_id: sesion,
                usuario_id: usuarioId,
                emisor: "user",
                mensaje: mensaje.trim(),
                tipo_mensaje: "texto",
            },
            {
                sesion_id: sesion,
                usuario_id: usuarioId,
                emisor: "bot",
                mensaje: texto,
                tipo_mensaje: "texto",
            },
        ]);

    if (errorInsert) {
        console.error(
            "⚠️ No se pudo guardar el historial del chat IA:",
            errorInsert.message
        );
    }

    return {
        respuesta: texto,
        sesionId: sesion,
    };
};

export const recomendarCorte = async (
    imagenDataUri,
    imagenUrl,
    usuarioId,
    sesionId
) => {
    const sesion = sesionId || `sesion_ia_${Date.now()}`;

    const respuesta = await groq.chat.completions.create({
        model: MODELO_VISION,
        messages: [
            {
                role: "system",
                content: `Eres un asesor profesional de cortes de cabello para Barber King.
Analiza la foto y recomienda un corte que favorezca la forma del rostro y el tipo de cabello.

Reglas:
- Evalúa únicamente cabello, barba y estilo.
- No identifiques a la persona ni hagas diagnósticos médicos.
- No opines sobre atractivo físico.
- Devuelve únicamente JSON válido, sin texto adicional.

Formato exacto:
{
  "corte_principal": "nombre del corte",
  "explicacion": "por qué favorece a esta persona (2 oraciones)",
  "alternativas": ["corte alternativo 1", "corte alternativo 2"],
  "recomendacion_barbero": "consejo práctico para el barbero"
}`,
            },
            {
                role: "user",
                content: [
                    {
                        type: "text",
                        text: "Analiza esta foto y recomienda el mejor corte de cabello para la persona.",
                    },
                    {
                        type: "image_url",
                        image_url: {
                            url: imagenDataUri,
                        },
                    },
                ],
            },
        ],
        temperature: 0.2,
        max_tokens: 700,
    });

    const contenido =
        respuesta.choices[0]?.message?.content || "";

    const recomendacion = normalizarRecomendacion(
        extraerJson(contenido)
    );

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
                tipo_mensaje: "recomendacion_corte",
                metadata: { tipo: "solicitud" },
            },
            {
                sesion_id: sesion,
                usuario_id: usuarioId,
                emisor: "bot",
                mensaje: recomendacion.corte_principal,
                imagen_url: imagenUrl,
                tipo_mensaje: "recomendacion_corte",
                metadata: recomendacion,
            },
        ]);

    if (error) {
        console.error(
            "⚠️ No se pudo guardar la recomendación:",
            error.message
        );
    }

    return {
        sesionId: sesion,
        imagenUrl,
        recomendacion,
    };
};

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
        .order("created_at", { ascending: true });

    if (error) {
        throw new Error(
            `Error obteniendo historial: ${error.message}`
        );
    }

    return data || [];
};
