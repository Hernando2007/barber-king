import Groq from "groq-sdk";

export const groq = new Groq({
    apiKey: process.env.GROQ_API_KEY,
});

// Modelo del chat de texto. Se puede cambiar sin desplegar código nuevo:
// GROQ_MODELO_TEXTO=openai/gpt-oss-120b
export const MODELO_TEXTO =
    process.env.GROQ_MODELO_TEXTO || "openai/gpt-oss-20b";

export const MODELO_VISION = "qwen/qwen3.8-27b";
