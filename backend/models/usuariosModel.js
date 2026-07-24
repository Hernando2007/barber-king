import supabase from "../config/supabase.js";

// Obtener todos los usuarios
export const obtenerUsuarios = async () => {

    return await supabase
        .from("usuarios")
        .select(`
            id,
            nombres,
            apellidos,
            correo,
            telefono,
            estado,
            created_at,
            roles(nombre)
        `)
        .order("id", { ascending: true });

};

// Obtener usuario por ID
export const obtenerUsuarioPorId = async (id) => {

    return await supabase
        .from("usuarios")
        .select(`
            id,
            nombres,
            apellidos,
            correo,
            telefono,
            estado,
            roles(nombre)
        `)
        .eq("id", id)
        .single();

};