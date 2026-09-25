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
            correo
        `)
        .eq("correo", correo)
        .maybeSingle();

};

// Guardar o eliminar token de recuperación
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

// Buscar usuario mediante token
export const obtenerUsuarioPorToken = async (token) => {

    const { data, error } = await supabase
        .from("usuarios")
        .select(`
            id,
            correo,
            token_recuperacion,
            token_expiracion
        `)
        .eq("token_recuperacion", token)
        .maybeSingle();

    if (error) {
        throw new Error(error.message);
    }

    if (!data) {
        return null;
    }

    if (
        !data.token_expiracion ||
        new Date(data.token_expiracion) < new Date()
    ) {
        return null;
    }

    return data;

};

// Actualizar contraseña
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

//Función específica para los usuarios autenticados con Google
export const crearUsuarioGoogle = async ({ nombre, email, googleId, avatar = null, rol = 'cliente' }) => {
    const { data, error } = await supabase
        .from('usuarios')
        .insert({
            nombre,
            email,
            password: null,              // No requiere contraseña
            rol,
            isVerified: true,            // Google ya validó este correo
            googleId,
            avatar,
            codigoVerificacion: null,
            codigoVerificacionExpiracion: null
        })
        .select('id, nombre, email, rol, avatar')
        .single();

    return { data, error };
};

//Actualizar campos de vinculación
export const actualizarUsuario = async (id, campos) => {
    const { data, error } = await supabase
        .from('usuarios')
        .update(campos)
        .eq('id', id)
        .select()
        .single();

    return { data, error };
};

