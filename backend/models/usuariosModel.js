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

// Buscar usuario por correo
export const obtenerUsuarioPorCorreo = async (correo) => {

    return await supabase
        .from("usuarios")
        .select(`
            id,
            nombres,
            apellidos,
            correo,
            nombres
        `)
        .eq("correo", correo)
        .maybeSingle();

};

// Guardar o eliminar el token de recuperación
export const guardarTokenRecuperacion = async (
    id,
    token,
    expiracion
) => {

    return await supabase
        .from("usuarios")
        .update({
            reset_token: token,
            reset_token_expira: expiracion
        })
        .eq("id", id)
        .select()
        .single();

};

// Buscar usuario mediante el token de recuperación
export const obtenerUsuarioPorToken = async (token) => {

    const { data, error } = await supabase
        .from("usuarios")
        .select(`
            id,
            correo,
            reset_token,
            reset_token_expira
        `)
        .eq("reset_token", token)
        .maybeSingle();

    if (error) {
        throw new Error(error.message);
    }

    if (!data) {
        return null;
    }

    // Comprobamos que el token no haya expirado
    if (
        !data.reset_token_expira ||
        new Date(data.reset_token_expira) < new Date()
    ) {
        return null;
    }

    return data;

};

// Actualizar la contraseña del usuario
export const actualizarContrasena = async (
    id,
    contrasena
) => {

    return await supabase
        .from("usuarios")
        .update({
            contrasena: contrasena
        })
        .eq("id", id)
        .select()
        .single();

};