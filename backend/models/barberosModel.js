import supabase from "../config/supabase.js";
import { asegurarHorariosPorDefecto } from "./horariosModel.js";
 
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
        .order("id", { ascending: true });
};
 
export const obtenerBarberoPorId = async (id) => {
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
 
export const obtenerBarberoPorUsuario = async (usuarioId) => {
    return await supabase
        .from("barberos")
        .select("*")
        .eq("usuario_id", usuarioId)
        .maybeSingle();
};
 
export const crearBarbero = async (datos) => {
    const resultado = await supabase
        .from("barberos")
        .insert(datos)
        .select()
        .single();

    if (!resultado.error && resultado.data?.id) {
        await asegurarHorariosPorDefecto(resultado.data.id);
    }

    return resultado;
};
 
export const actualizarBarbero = async (id, datos) => {
    return await supabase
        .from("barberos")
        .update(datos)
        .eq("id", id)
        .select()
        .single();
};
 
export const eliminarBarbero = async (id) => {
    return await supabase
        .from("barberos")
        .delete()
        .eq("id", id);
};
 
export const obtenerBarberoPorUsuarioCompleto = async (usuarioId) => {
    return await supabase
        .from("barberos")
        .select("*")
        .eq("usuario_id", usuarioId)
        .maybeSingle();
};

export const obtenerCalificacionesBarberos = async () => {
    return await supabase
        .from("resenas")
        .select("barbero_id, calificacion");
};
