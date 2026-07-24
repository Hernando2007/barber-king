import supabase from "../config/supabase.js";

// Buscar usuario por correo
export const buscarPorCorreo = async (correo) => {

    return await supabase
        .from("usuarios")
        .select("*")
        .eq("correo", correo)
        .single();

};

// Crear usuario
export const crearUsuario = async (usuario) => {

    return await supabase
        .from("usuarios")
        .insert(usuario)
        .select()
        .single();

};