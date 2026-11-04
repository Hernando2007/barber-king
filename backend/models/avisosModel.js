import supabase from "../config/supabase.js";

export const crearAviso = async ({
    usuarioId,
    tipo,
    titulo,
    cuerpo,
    datos = {},
}) => {
    return await supabase
        .from("avisos_usuario")
        .insert({
            usuario_id: usuarioId,
            tipo,
            titulo,
            cuerpo,
            datos,
        })
        .select("*")
        .single();
};

// La app guarda el último id que ya leyó y pregunta por lo que sigue. Se pide
// de más nuevo a más viejo y se invierte: con watermark 0 un "order asc"
// traería los avisos más viejos de toda la tabla, no los que faltan.
export const listarNovedades = async ({
    usuarioId,
    desdeId = 0,
    limite = 30,
}) => {
    const cantidad = Number(limite) || 30;

    return await supabase
        .from("avisos_usuario")
        .select("*")
        .eq("usuario_id", usuarioId)
        .gt("id", Number(desdeId) || 0)
        .order("id", { ascending: false })
        .limit(cantidad);
};
