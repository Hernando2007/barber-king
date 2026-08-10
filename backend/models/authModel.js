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

// Guardar token de recuperación
export const guardarTokenRecuperacion = async (
    correo,
    token,
    expiracion
) => {

    return await supabase
        .from("usuarios")
        .update({
            token_recuperacion: token,
            token_expiracion: expiracion
        })
        .eq("correo", correo);

};

// Buscar usuario por token
export const buscarPorToken = async (token) => {

    return await supabase
        .from("usuarios")
        .select("*")
        .eq("token_recuperacion", token)
        .single();

};

// Actualizar contraseña
export const actualizarPassword = async (
    id,
    password
) => {

    return await supabase
        .from("usuarios")
        .update({
            password: password
        })
        .eq("id", id);

};

// Limpiar token de recuperación
export const limpiarToken = async (id) => {

    return await supabase
        .from("usuarios")
        .update({
            token_recuperacion: null,
            token_expiracion: null
        })
        .eq("id", id);

};