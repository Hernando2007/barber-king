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