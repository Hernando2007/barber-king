import supabase from "../config/supabase.js";

export const obtenerBarberos = async () => {

    return await supabase
        .from("barberos")
        .select(`
            *,
            usuarios(
                id,
                nombres,
                apellidos,
                correo,
                telefono,
                foto
            )
        `)
        .order(
            "id",
            {
                ascending: true
            }
        );

};

export const obtenerBarberoPorId = async (
    id
) => {

    return await supabase
        .from("barberos")
        .select(`
            *,
            usuarios(
                id,
                nombres,
                apellidos,
                correo,
                telefono,
                foto
            )
        `)
        .eq("id", id)
        .maybeSingle();

};

export const obtenerBarberoPorUsuario = async (
    usuarioId
) => {

    return await supabase
        .from("barberos")
        .select("*")
        .eq(
            "usuario_id",
            usuarioId
        )
        .maybeSingle();

};

export const crearBarbero = async (
    datos
) => {

    return await supabase
        .from("barberos")
        .insert(datos)
        .select()
        .single();

};

export const actualizarBarbero = async (
    id,
    datos
) => {

    return await supabase
        .from("barberos")
        .update(datos)
        .eq("id", id)
        .select()
        .single();

};

export const eliminarBarbero = async (
    id
) => {

    return await supabase
        .from("barberos")
        .delete()
        .eq("id", id);

};