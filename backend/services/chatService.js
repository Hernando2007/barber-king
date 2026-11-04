import supabase from "../config/supabase.js";
import { groq, MODELO_TEXTO } from "../config/groq.js";
import { httpError } from "../utils/httpError.js";
import { contieneProfanidad } from "../utils/profanidad.js";
import { promptBarberKing } from "./chatPrompt.js";

const obtenerCatalogo = async () => {
    const { data: servicios } = await supabase
        .from("servicios")
        .select("nombre, precio, descripcion, duracion")
        .eq("estado", true)
        .order("nombre", { ascending: true });

    if (!servicios?.length) {
        return "No hay servicios publicados en este momento.";
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

export const enviarMensaje = async (mensaje, usuarioId, sesionId) => {
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

    const contexto = (historial || []).reverse().map((item) => ({
        role: item.emisor === "bot" ? "assistant" : "user",
        content: item.mensaje,
    }));

    const respuesta = await groq.chat.completions.create({
        model: MODELO_TEXTO,
        reasoning_effort: "low",
        messages: [
            {
                role: "system",
                content: promptBarberKing({ catalogo, barberos }),
            },
            ...contexto,
            { role: "user", content: mensaje },
        ],
        temperature: 0.3,
        max_tokens: 400,
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

    return { respuesta: texto, sesionId: sesion };
};

export const obtenerHistorial = async (sesionId, usuarioId) => {
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
        throw new Error(`Error obteniendo historial: ${error.message}`);
    }

    return data || [];
};
