import supabase from "../config/supabase.js";

export const obtenerUsuarios = async () =>
  supabase
    .from("usuarios")
    .select(`
      id,
      nombres,
      apellidos,
      correo,
      telefono,
      fecha_nacimiento,
      estado,
      created_at,
      rol_id,
      roles(nombre),
      barberos(
        id,
        especialidad,
        diploma_url,
        diploma_nombre,
        verificacion_estado,
        activo
      )
    `)
    .order("id", { ascending: true });

export const obtenerUsuarioPorId = async (id) =>
  supabase
    .from("usuarios")
    .select(`
      id,
      nombres,
      apellidos,
      correo,
      telefono,
      fecha_nacimiento,
      estado,
      created_at,
      rol_id,
      roles(nombre),
      barberos(
        id,
        especialidad,
        diploma_url,
        diploma_nombre,
        verificacion_estado,
        activo
      )
    `)
    .eq("id", id)
    .single();

export const obtenerUsuarioPorCorreo = async (correo) =>
  supabase
    .from("usuarios")
    .select(`
      id,
      nombres,
      apellidos,
      correo,
      estado,
      rol_id,
      roles(nombre)
    `)
    .eq("correo", correo)
    .maybeSingle();

export const crearUsuarioGoogle = async ({
  nombres,
  apellidos,
  correo,
}) =>
  supabase
    .from("usuarios")
    .insert({
      nombres,
      apellidos,
      correo,
      rol_id: 3,
      estado: true,
      password: null,
    })
    .select(`
      id,
      nombres,
      apellidos,
      correo,
      estado,
      rol_id,
      roles(nombre)
    `)
    .single();

export const actualizarUsuario = async (
  id,
  campos
) =>
  supabase
    .from("usuarios")
    .update(campos)
    .eq("id", id)
    .select(`
      id,
      nombres,
      apellidos,
      correo,
      telefono,
      fecha_nacimiento,
      estado,
      rol_id,
      roles(nombre)
    `)
    .single();

export const guardarTokenRecuperacion = async (
  id,
  token,
  expiracion
) =>
  supabase
    .from("usuarios")
    .update({
      token_recuperacion: token,
      token_expiracion: expiracion,
    })
    .eq("id", id)
    .select()
    .single();

export const obtenerUsuarioPorToken = async (
  token
) => {
  const { data, error } =
    await supabase
      .from("usuarios")
      .select(`
        id,
        correo,
        token_recuperacion,
        token_expiracion
      `)
      .eq(
        "token_recuperacion",
        token
      )
      .maybeSingle();

  if (error) {
    throw new Error(error.message);
  }

  if (!data) return null;

  if (
    !data.token_expiracion ||
    new Date(data.token_expiracion) <
      new Date()
  ) {
    return null;
  }

  return data;
};

export const actualizarContrasena = async (
  id,
  contrasena
) =>
  supabase
    .from("usuarios")
    .update({
      password: contrasena,
    })
    .eq("id", id)
    .select()
    .single();