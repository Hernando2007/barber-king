import supabase from "../config/supabase.js";

// El esquema nuevo usa `google_id`, pero algunas bases creadas con
// versiones anteriores conservan `googleId`. Se detecta una sola vez
// para que el inicio de sesión con Google funcione en ambas.
let columnaGoogleId = null;

const detectarColumnaGoogleId = async () => {
    if (columnaGoogleId) {
        return columnaGoogleId;
    }

    const { error } = await supabase
        .from("usuarios")
        .select("google_id")
        .limit(1);

    if (!error) {
        columnaGoogleId = "google_id";
    } else if (error.code === "42703") {
        columnaGoogleId = "googleId";
    } else {
        throw new Error(error.message);
    }

    return columnaGoogleId;
};

const normalizarCamposGoogle = async (campos) => {
    if (
        !campos ||
        !Object.prototype.hasOwnProperty.call(campos, "google_id")
    ) {
        return campos;
    }

    const columna = await detectarColumnaGoogleId();

    if (columna === "google_id") {
        return campos;
    }

    const { google_id, ...resto } = campos;

    return { ...resto, [columna]: google_id };
};

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
    const columna = await detectarColumnaGoogleId();

    const { data, error } = await supabase
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
            ${columna},
            avatar,
            password
        `)
        .eq("correo", correo)
        .maybeSingle();

    if (data && columna !== "google_id") {
        data.google_id = data[columna];
    }

    return { data, error };
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
    const datos = await normalizarCamposGoogle(campos);

    return await supabase
        .from("usuarios")
        .update(datos)
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
    const columna = await detectarColumnaGoogleId();

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
            [columna]: googleId,
            avatar
        })
        .select("id")
        .single();
};
