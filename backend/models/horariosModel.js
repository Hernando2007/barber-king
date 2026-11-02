import supabase from "../config/supabase.js";

// La base de datos usa "disponible"; la app móvil consume "activo".
const normalizarHorario = (horario) => {
  if (!horario) {
    return horario;
  }

  const { disponible, activo, ...resto } =
    horario;

  const habilitado =
    disponible !== undefined
      ? disponible !== false
      : activo !== false;

  return {
    ...resto,
    disponible: habilitado,
    activo: habilitado,
  };
};

export const obtenerHorarios = async (
  barberoId
) => {
  const { data, error } = await supabase
    .from("horarios")
    .select(`
      id,
      barbero_id,
      dia_semana,
      hora_inicio,
      hora_fin,
      disponible
    `)
    .eq("barbero_id", barberoId)
    .order("dia_semana", {
      ascending: true,
    })
    .order("hora_inicio", {
      ascending: true,
    });

  return {
    data: Array.isArray(data)
      ? data.map(normalizarHorario)
      : data,
    error,
  };
};

export const obtenerHorarioPorId = async (
  id
) => {
  const { data, error } = await supabase
    .from("horarios")
    .select(`
      id,
      barbero_id,
      dia_semana,
      hora_inicio,
      hora_fin,
      disponible
    `)
    .eq("id", id)
    .single();

  return {
    data: normalizarHorario(data),
    error,
  };
};

export const crearHorario = async (
  datos
) => {
  const { data, error } = await supabase
    .from("horarios")
    .insert({
      barbero_id: datos.barbero_id,
      dia_semana: datos.dia_semana,
      hora_inicio: datos.hora_inicio,
      hora_fin: datos.hora_fin,
      disponible:
        datos.disponible !== undefined
          ? datos.disponible
          : datos.activo !== undefined
            ? datos.activo
            : true,
    })
    .select()
    .single();

  return {
    data: normalizarHorario(data),
    error,
  };
};

export const actualizarHorario = async (
  id,
  datos
) => {
  const campos = { ...datos };

  if (
    campos.activo !== undefined &&
    campos.disponible === undefined
  ) {
    campos.disponible = campos.activo;
  }

  delete campos.activo;

  const { data, error } = await supabase
    .from("horarios")
    .update(campos)
    .eq("id", id)
    .select()
    .single();

  return {
    data: normalizarHorario(data),
    error,
  };
};

export const eliminarHorario = async (
  id
) => {
  return await supabase
    .from("horarios")
    .delete()
    .eq("id", id);
};

// 1 = lunes ... 7 = domingo, igual que consulta la disponibilidad.
export const HORARIOS_POR_DEFECTO = [
  { dia_semana: 1, hora_inicio: "09:00", hora_fin: "19:00" },
  { dia_semana: 2, hora_inicio: "09:00", hora_fin: "19:00" },
  { dia_semana: 3, hora_inicio: "09:00", hora_fin: "19:00" },
  { dia_semana: 4, hora_inicio: "09:00", hora_fin: "19:00" },
  { dia_semana: 5, hora_inicio: "09:00", hora_fin: "19:00" },
  { dia_semana: 6, hora_inicio: "09:00", hora_fin: "18:00" },
  { dia_semana: 7, hora_inicio: "10:00", hora_fin: "14:00" },
];

export const asegurarHorariosPorDefecto = async (barberoId) => {
  if (!barberoId) {
    return { data: null, error: null };
  }

  const { data: existentes, error } = await supabase
    .from("horarios")
    .select("dia_semana")
    .eq("barbero_id", barberoId);

  if (error) {
    return { data: null, error };
  }

  const dias = new Set(
    (existentes || []).map((item) => Number(item.dia_semana))
  );

  const faltantes = HORARIOS_POR_DEFECTO.filter(
    (item) => !dias.has(item.dia_semana)
  );

  if (!faltantes.length) {
    return { data: [], error: null };
  }

  const { data, error: errorInsert } = await supabase
    .from("horarios")
    .insert(
      faltantes.map((item) => ({
        barbero_id: barberoId,
        hora_inicio: item.hora_inicio,
        hora_fin: item.hora_fin,
        dia_semana: item.dia_semana,
        disponible: true,
      }))
    )
    .select();

  return { data, error: errorInsert };
};
