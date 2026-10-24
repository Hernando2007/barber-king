import supabase from "../config/supabase.js";

const CAMPOS_CONTACTO = `
    id,
    nombres,
    apellidos,
    foto,
    correo,
    estado,
    rol_id,
    roles(nombre),
    barberos(
        id,
        especialidad,
        disponible,
        foto_trabajo
    )
`;

export const listarBarberosConUsuario = async () => {
    return await supabase
        .from("barberos")
        .select(`
            id,
            usuario_id,
            especialidad,
            disponible,
            foto_trabajo,
            usuarios(
                id,
                nombres,
                apellidos,
                foto,
                correo,
                estado,
                rol_id,
                roles(nombre)
            )
        `)
        .order("id", { ascending: true });
};

export const listarClientesDeBarbero = async (barberoId) => {
    return await supabase
        .from("citas")
        .select(`
            cliente_id,
            usuarios!cliente_id(
                id,
                nombres,
                apellidos,
                foto,
                correo,
                estado,
                rol_id,
                roles(nombre)
            )
        `)
        .eq("barbero_id", barberoId);
};

export const listarUsuariosContactables = async () => {
    return await supabase
        .from("usuarios")
        .select(CAMPOS_CONTACTO)
        .in("rol_id", [2, 3])
        .eq("estado", true)
        .order("nombres", { ascending: true });
};

export const obtenerUsuarioBasico = async (id) => {
    return await supabase
        .from("usuarios")
        .select(CAMPOS_CONTACTO)
        .eq("id", id)
        .maybeSingle();
};

export const listarMensajesDirectos = async (limite = 2000) => {
    return await supabase
        .from("mensajes_chat")
        .select(`
            id,
            sesion_id,
            usuario_id,
            emisor,
            mensaje,
            imagen_url,
            tipo_mensaje,
            metadata,
            created_at
        `)
        .eq("tipo_mensaje", "directo")
        .order("created_at", { ascending: false })
        .limit(limite);
};

export const listarMensajesSesion = async (
    sesionId,
    ultimoId = 0
) => {
    if (ultimoId > 0) {
        return await supabase
            .from("mensajes_chat")
            .select("*")
            .eq("sesion_id", sesionId)
            .eq("tipo_mensaje", "directo")
            .gt("id", ultimoId)
            .order("id", { ascending: true })
            .limit(200);
    }

    const resultado = await supabase
        .from("mensajes_chat")
        .select("*")
        .eq("sesion_id", sesionId)
        .eq("tipo_mensaje", "directo")
        .order("id", { ascending: false })
        .limit(200);

    if (Array.isArray(resultado.data)) {
        resultado.data.reverse();
    }

    return resultado;
};

export const crearMensajeDirecto = async (datos) => {
    return await supabase
        .from("mensajes_chat")
        .insert(datos)
        .select()
        .single();
};
