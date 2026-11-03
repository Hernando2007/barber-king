import supabase from "../config/supabase.js";
import { groq, MODELO_VISION } from "../config/groq.js";
import { httpError } from "../utils/httpError.js";

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
        throw httpError(502, "La IA no devolvió una recomendación válida.");
    }

    const corte = String(datos.corte_principal || datos.corte || "").trim();

    if (!corte) {
        throw httpError(502, "La IA no devolvió una recomendación válida.");
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
- Si la persona no tiene cabello en la cabeza (rapada o calva), no inventes un corte: propone rapado a cero con navaja, diseño o perfilado de barba y cuidado del cuero cabelludo, y explica por qué favorece.
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
                        image_url: { url: imagenDataUri },
                    },
                ],
            },
        ],
        temperature: 0.2,
        max_tokens: 700,
    });

    const recomendacion = normalizarRecomendacion(
        extraerJson(respuesta.choices[0]?.message?.content || "")
    );

    const { error } = await supabase
        .from("mensajes_chat")
        .insert([
            {
                sesion_id: sesion,
                usuario_id: usuarioId,
                emisor: "user",
                mensaje: "Solicitud de recomendación de corte mediante IA.",
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
        console.error("⚠️ No se pudo guardar la recomendación:", error.message);
    }

    return { sesionId: sesion, imagenUrl, recomendacion };
};
