import Groq from "groq-sdk";
import { httpError } from "../utils/httpError.js";

const groq = new Groq({
    apiKey: process.env.GROQ_API_KEY,
});

export const MODELO_VISION = "qwen/qwen3.8-27b";
const CONFIANZA_MINIMA = 70;

const PISTEMA = `Eres un verificador de identidad para una plataforma de barbería.
Analiza el documento de la imagen y decide si es una credencial, diploma o
certificado REAL de barbería/estilismo (academia, federación, curso
profesional). Rechaza documentos modificados, imágenes sin texto, memes,
facturas, capturas de pantalla o documentos de otra profesión.
Responde ÚNICAMENTE con este JSON (sin markdown):
{"es_credencial_barberia": boolean, "confianza": 0-100,
"tipo_documento": "texto corto", "titular": "nombre si aparece",
"institucion": "nombre si aparece", "motivo": "explicación breve"}`;

// El diploma ya no toca el disco: se bajan los bytes desde Cloudinary.
export const descargarBase64 = async (url) => {
    if (!/^https?:\/\//i.test(String(url || ""))) {
        return null;
    }

    try {
        const respuesta = await fetch(url);

        if (!respuesta.ok) {
            throw new Error(`HTTP ${respuesta.status}`);
        }

        return (
            Buffer.from(await respuesta.arrayBuffer())
        ).toString("base64");
    } catch (error) {
        console.warn("⚠️ No se pudo descargar el documento:", error.message);

        throw httpError(
            500, "No fue posible leer el documento adjunto. Intenta de nuevo."
        );
    }
};

const extraerJson = (texto) => {
    const limpio = String(texto || "")
        .replace(/```json/gi, "")
        .replace(/```/g, "")
        .trim();

    try {
        return JSON.parse(limpio);
    } catch {
        const inicio = limpio.indexOf("{");
        const fin = limpio.lastIndexOf("}");
        if (inicio === -1 || fin <= inicio) return null;

        try {
            return JSON.parse(limpio.slice(inicio, fin + 1));
        } catch {
            return null;
        }
    }
};

const limpiarTexto = (valor, maximo = 200) =>
    String(valor || "").trim().slice(0, maximo) || null;

const analizarConIa = async (dataUri) => {
    let respuesta;

    try {
        respuesta = await groq.chat.completions.create({
            model: MODELO_VISION,
            messages: [
                { role: "system", content: PISTEMA },
                {
                    role: "user",
                    content: [
                        { type: "text", text: "Verifica si este documento es una credencial real de barbería." },
                        { type: "image_url", image_url: { url: dataUri } },
                    ],
                },
            ],
            temperature: 0.1,
            max_tokens: 400,
        });
    } catch (error) {
        console.error("⚠️ Error del proveedor de IA:", error.message);
        throw httpError(
            503,
            "El servicio de verificación no está disponible. Intenta más tarde."
        );
    }

    const contenido = respuesta.choices?.[0]?.message?.content || "";
    const analisis = extraerJson(contenido);

    if (!analisis || typeof analisis !== "object") {
        throw httpError(
            422, "No pudimos validar el documento. Sube una foto más nítida."
        );
    }

    return analisis;
};

const normalizarResultado = (analisis) => ({
    esValido:
        analisis.es_credencial_barberia === true &&
        Number(analisis.confianza) >= CONFIANZA_MINIMA,
    confianza: Number(analisis.confianza) || 0,
    tipoDocumento: limpiarTexto(analisis.tipo_documento, 120),
    titular: limpiarTexto(analisis.titular, 120),
    institucion: limpiarTexto(analisis.institucion, 160),
    motivo: limpiarTexto(analisis.motivo, 300),
});

/** Lee la imagen ya en base64 y devuelve el veredicto listo para guardar. */
export const analizarDocumento = async (dataUri) =>
    normalizarResultado(await analizarConIa(dataUri));
