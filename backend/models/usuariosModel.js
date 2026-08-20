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
            token_recuperacion: token,
            token_expiracion: expiracion
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
            token_recuperacion,
            token_recuperacion_expira
        `)
        .eq("token_recuperacion", token)
        .maybeSingle();

    if (error) {
        throw new Error(error.message);
    }

    if (!data) {
        return null;
    }

    // Comprobamos que el token no haya expirado
    if (
        !data.token_recuperacion_expira ||
        new Date(data.token_recuperacion_expira) < new Date()
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
            password: contrasena
        })
        .eq("id", id)
        .select()
        .single();

};