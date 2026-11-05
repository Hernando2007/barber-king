import supabase from "../config/supabase.js";

const CAMPOS_USUARIO = `
    id,
    rol_id,
    nombres,
    apellidos,
    correo,
    telefono,
    foto,
    fecha_nacimiento,
    estado,
    vip,
    created_at,
    updated_at,
    ultimo_login,
    email_verificado,
    roles(nombre),
    barberos(
        id,
        usuario_id,
        especialidad,
        experiencia,
        descripcion,
        foto_trabajo,
        disponible,
        direccion,
        portafolio,
        created_at,
        updated_at
    )
`;

export const obtenerUsuarios = async () => {
    return await supabase
        .from("usuarios")
        .select(CAMPOS_USUARIO)
        .order("id", { ascending: true });
};

export const obtenerUsuarioPorId = async (id) => {
    return await supabase
        .from("usuarios")
        .select(CAMPOS_USUARIO)
        .eq("id", id)
        .maybeSingle();
};

export const obtenerUsuarioConPassword = async (id) => {
    return await supabase
        .from("usuarios")
        .select("id, correo, password, estado, rol_id")
        .eq("id", id)
        .maybeSingle();
};

export const obtenerUsuarioPorCorreo = async (correo) => {
    return await supabase
        .from("usuarios")
        .select(`
            id,
            rol_id,
            nombres,
            apellidos,
            correo,
            telefono,
            foto,
            fecha_nacimiento,
            estado,
            googleId,
            avatar,
            password
        `)
        .eq("correo", correo)
        .maybeSingle();
};

export const existeCorreo = async (correo, excluirId = null) => {
    let consulta = supabase
        .from("usuarios")
        .select("id")
        .eq("correo", correo);

    if (excluirId) {
        consulta = consulta.neq("id", excluirId);
    }

    const { data, error } = await consulta.maybeSingle();

    if (error) {
        throw new Error(error.message);
    }

    return Boolean(data);
};

export const crearUsuario = async (datos) => {
    return await supabase
        .from("usuarios")
        .insert(datos)
        .select("id")
        .single();
};

export const actualizarUsuario = async (id, campos) => {
    return await supabase
        .from("usuarios")
        .update(campos)
        .eq("id", id)
        .select("id")
        .single();
};

export const eliminarUsuario = async (id) => {
    return await supabase
        .from("usuarios")
        .delete()
        .eq("id", id);
};

export const contarUsuariosPorRol = async (rolId) => {
    return await supabase
        .from("usuarios")
        .select("*", { count: "exact", head: true })
        .eq("rol_id", rolId);
};

export const crearUsuarioGoogle = async ({
    nombres,
    apellidos,
    correo,
    googleId,
    avatar = null
}) => {
    return await supabase
        .from("usuarios")
        .insert({
            rol_id: 3,
            nombres,
            apellidos,
            correo,
            password: null,
            estado: true,
            email_verificado: true,
            googleId,
            avatar
        })
        .select("id")
        .single();
};
