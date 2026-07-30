import supabase from "../config/supabase.js";



export const obtenerBarberos = async () => {

    return await supabase
        .from("barberos")
        .select(`
            *,
            usuarios(
                id,
                nombres,
                apellidos,
                correo,
                telefono,
                foto
            )
        `)
        .order("id");

};


export const obtenerBarberoPorId = async (id) => {

    return await supabase
        .from("barberos")
        .select(`
            *,
            usuarios(
                id,
                nombres,
                apellidos,
                correo,
                telefono,
                foto
            )
        `)
        .eq("id", id)
        .single();

};


export const crearBarbero = async (datos) => {

    return await supabase
        .from("barberos")
        .insert(datos)
        .select()
        .single();

};


export const actualizarBarbero = async (id, datos) => {

    return await supabase
        .from("barberos")
        .update(datos)
        .eq("id", id)
        .select()
        .single();

};


export const eliminarBarbero = async (id) => {

    return await supabase
        .from("barberos")
        .delete()
        .eq("id", id);

};