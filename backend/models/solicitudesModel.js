import supabase from "../config/supabase.js";

// Todo lo que la app necesita para pintar una solicitud sin hacer
// segundas consultas: quién la envió, de qué barbero es y el contexto.
// barberos solo tiene una FK con usuarios, así que el anidado no necesita
// Hint.
const SELECCION = `
    *,
    barberos(
        id,
        usuario_id,
        especialidad,
        ciudad,
        zona,
        usuarios(nombres, apellidos, foto)
    ),
    usuarios!solicitudes_cliente_cliente_id_fkey(
        id,
        nombres,
        apellidos,
        foto
    ),
    servicios(id, nombre),
    citas(id, fecha, hora, estado)
`;

export const crearSolicitud = async (datos) => {
    return await supabase
        .from("solicitudes_cliente")
        .insert(datos)
        .select(SELECCION)
        .single();
};

export const obtenerSolicitud = async (id) => {
    return await supabase
        .from("solicitudes_cliente")
        .select(SELECCION)
        .eq("id", id)
        .maybeSingle();
};

export const listarPorBarbero = async ({
    barberoId,
    estado = null,
    limite = 60,
}) => {
    let consulta = supabase
        .from("solicitudes_cliente")
        .select(SELECCION)
        .eq("barbero_id", barberoId)
        .order("id", { ascending: false })
        .limit(Number(limite) || 60);

    if (estado) {
        consulta = consulta.eq("estado", estado);
    }

    return await consulta;
};

export const listarPorCliente = async ({ clienteId, limite = 60 }) => {
    return await supabase
        .from("solicitudes_cliente")
        .select(SELECCION)
        .eq("cliente_id", clienteId)
        .order("id", { ascending: false })
        .limit(Number(limite) || 60);
};

export const responderSolicitud = async (id, datos) => {
    return await supabase
        .from("solicitudes_cliente")
        .update(datos)
        .eq("id", id)
        .select(SELECCION)
        .single();
};

export const contarPendientesBarbero = async (barberoId) => {
    return await supabase
        .from("solicitudes_cliente")
        .select("id", { count: "exact", head: true })
        .eq("barbero_id", barberoId)
        .eq("estado", "pendiente");
};

export const contarPendientesCliente = async ({ clienteId, barberoId }) => {
    return await supabase
        .from("solicitudes_cliente")
        .select("id", { count: "exact", head: true })
        .eq("cliente_id", clienteId)
        .eq("barbero_id", barberoId)
        .eq("estado", "pendiente");
};
