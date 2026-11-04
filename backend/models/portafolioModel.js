import supabase from "../config/supabase.js";

// Las fotos de trabajo del barbero. El archivo vive en Cloudinary;
// esta tabla guarda la url publica y el public_id para poder borrarlo.

const TABLA = "portafolio_barbero";
const MAXIMO_LISTADO = 60;

export const listarDelBarbero = async (barberoId) =>
    await supabase
        .from(TABLA)
        .select("*")
        .eq("barbero_id", barberoId)
        .order("created_at", { ascending: false })
        .limit(MAXIMO_LISTADO);

export const contarDelBarbero = async (barberoId) =>
    await supabase
        .from(TABLA)
        .select("id", { count: "exact", head: true })
        .eq("barbero_id", barberoId);

export const crearFotos = async (filas) =>
    await supabase.from(TABLA).insert(filas).select();

export const buscarFoto = async (id) =>
    await supabase.from(TABLA).select("*").eq("id", id).maybeSingle();

export const borrarFoto = async (id) =>
    await supabase.from(TABLA).delete().eq("id", id).select();
