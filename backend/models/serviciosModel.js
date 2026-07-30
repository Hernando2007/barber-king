import supabase from "../config/supabase.js";



export const obtenerServicios = async () => {

    return await supabase
        .from("servicios")
        .select("*")
        .order("id");

};


export const obtenerServicioPorId = async (id) => {

    return await supabase
        .from("servicios")
        .select("*")
        .eq("id", id)
        .single();

};


export const crearServicio = async (datos) => {

    return await supabase
        .from("servicios")
        .insert(datos)
        .select()
        .single();

};


export const actualizarServicio = async (id, datos) => {

    return await supabase
        .from("servicios")
        .update(datos)
        .eq("id", id)
        .select()
        .single();

};


export const eliminarServicio = async (id) => {

    return await supabase
        .from("servicios")
        .delete()
        .eq("id", id);

};