import supabase from "../config/supabase.js";

// Solo estas columnas existen en la tabla "usuarios".
// Cualquier otro campo (ej. especialidad, experiencia) se descarta para que el insert no falle.
const COLUMNAS_USUARIO = [
    "rol_id",
    "nombres",
    "apellidos",
    "correo",
    "telefono",
    "password",
    "foto",
    "fecha_nacimiento",
    "estado"
];

export const buscarPorCorreo = async (correo) => {
    return await supabase
        .from("usuarios")
        .select("*")
        .eq("correo", correo)
        .maybeSingle();
};

export const crearUsuario = async (usuario) => {
    const datos = Object.fromEntries(
        Object.entries(usuario).filter(([campo]) =>
            COLUMNAS_USUARIO.includes(campo)
        )
    );

    return await supabase
        .from("usuarios")
        .insert(datos)
        .select()
        .single();
};

export const guardarTokenRecuperacion = async (correo, codigo, expiracion) => {
    return await supabase
        .from("usuarios")
        .update({
            token_recuperacion: codigo,
            token_expiracion: expiracion
        })
        .eq("correo", correo)
        .select()
        .single();
};

export const actualizarPassword = async (id, password) => {
    return await supabase
        .from("usuarios")
        .update({ password })
        .eq("id", id)
        .select()
        .single();
};

export const limpiarToken = async (id) => {
    return await supabase
        .from("usuarios")
        .update({
            token_recuperacion: null,
            token_expiracion: null
        })
        .eq("id", id);
};

export const actualizarUltimoLogin = async (id) => {
    return await supabase
        .from("usuarios")
        .update({ ultimo_login: new Date() })
        .eq("id", id);
};