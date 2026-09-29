import supabase from "../config/supabase.js";

export const obtenerHorarios = async (
  barberoId
) => {
  return await supabase
    .from("horarios")
    .select(`
      id,
      barbero_id,
      dia_semana,
      hora_inicio,
      hora_fin,
      activo
    `)
    .eq("barbero_id", barberoId)
    .order("dia_semana", {
      ascending: true,
    })
    .order("hora_inicio", {
      ascending: true,
    });
};

export const obtenerHorarioPorId = async (
  id
) => {
  return await supabase
    .from("horarios")
    .select(`
      id,
      barbero_id,
      dia_semana,
      hora_inicio,
      hora_fin,
      activo
    `)
    .eq("id", id)
    .single();
};

export const crearHorario = async (
  datos
) => {
  return await supabase
    .from("horarios")
    .insert({
      barbero_id: datos.barbero_id,
      dia_semana: datos.dia_semana,
      hora_inicio: datos.hora_inicio,
      hora_fin: datos.hora_fin,
      activo:
        datos.activo !== undefined
          ? datos.activo
          : true,
    })
    .select()
    .single();
};

export const actualizarHorario = async (
  id,
  datos
) => {
  return await supabase
    .from("horarios")
    .update(datos)
    .eq("id", id)
    .select()
    .single();
};

export const eliminarHorario = async (
  id
) => {
  return await supabase
    .from("horarios")
    .delete()
    .eq("id", id);
};