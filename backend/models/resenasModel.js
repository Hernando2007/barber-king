import supabase from "../config/supabase.js";


export const obtenerResenas = async () => {

    return await supabase
        .from("resenas")
        .select("*")
        .order("id");

};


export const obtenerResenaPorId = async (id) => {

    return await supabase
        .from("resenas")
        .select("*")
        .eq("id", id)
        .single();

};


export const obtenerResenasPorBarbero = async (barberoId) => {

    return await supabase
        .from("resenas")
        .select("*")
        .eq("barbero_id", barberoId)
        .order("created_at", { ascending: false });

};


export const crearResena = async (datos) => {

    return await supabase
        .from("resenas")
        .insert(datos)
        .select()
        .single();

};


export const actualizarResena = async (id, datos) => {

    return await supabase
        .from("resenas")
        .update(datos)
        .eq("id", id)
        .select()
        .single();

};


export const eliminarResena = async (id) => {

    return await supabase
        .from("resenas")
        .delete()
        .eq("id", id);

};