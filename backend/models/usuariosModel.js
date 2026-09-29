import supabase from "../config/supabase.js";
 
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
 
export const obtenerUsuarioPorId = async (id) => {
    return await supabase
        .from("usuarios")
        .select(`
            id,
            nombres,
            apellidos,
            correo,
            telefono,
            fecha_nacimiento,
            estado,
            created_at,
            rol_id,
            roles(nombre),
            barberos(*)
        `)
        .eq("id", id)
        .single();
};
 
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
 
export const actualizarContrasena = async (id, contrasena) => {
    return await supabase
        .from("usuarios")
        .update({ password: contrasena })
        .eq("id", id)
        .select()
        .single();
};
 
export const crearUsuarioGoogle = async ({
    nombre,
    email,
    googleId,
    avatar = null,
    rol = "cliente"
}) => {
    const { data, error } = await supabase
        .from("usuarios")
        .insert({
            nombre,
            email,
            password: null,
            rol,
            isVerified: true,
            googleId,
            avatar,
            codigoVerificacion: null,
            codigoVerificacionExpiracion: null
        })
        .select("id, nombre, email, rol, avatar")
        .single();
 
    return { data, error };
};
 
export const actualizarUsuario = async (id, campos) => {
    const { data, error } = await supabase
        .from("usuarios")
        .update(campos)
        .eq("id", id)
        .select()
        .single();
 
    return { data, error };
};
