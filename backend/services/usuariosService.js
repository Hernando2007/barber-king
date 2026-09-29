import {
  obtenerUsuarios,
  obtenerUsuarioPorId,
  actualizarUsuario,
} from "../models/usuariosModel.js";

/**
 * Obtiene todos los usuarios.
 */
export const listarUsuarios = async () => {
  const { data, error } = await obtenerUsuarios();

  if (error) {
    throw new Error(error.message);
  }

  return data || [];
};

/**
 * Obtiene un usuario por su ID.
 */
export const buscarUsuario = async (id) => {
  if (!id) {
    throw new Error("El ID del usuario es obligatorio.");
  }

  const { data, error } =
    await obtenerUsuarioPorId(id);

  if (error) {
    throw new Error(error.message);
  }

  if (!data) {
    throw new Error("Usuario no encontrado.");
  }

  return data;
};

/**
 * Obtiene el perfil completo del usuario autenticado.
 *
 * Incluye:
 * - Datos personales.
 * - Rol.
 * - Datos profesionales del barbero.
 * - Especialidad.
 * - Diploma.
 * - Estado de verificación.
 */
export const obtenerPerfilCompleto = async (
  id
) => {
  if (!id) {
    throw new Error(
      "El ID del usuario es obligatorio."
    );
  }

  const { data, error } =
    await obtenerUsuarioPorId(id);

  if (error) {
    throw new Error(error.message);
  }

  if (!data) {
    throw new Error(
      "No se encontró el perfil del usuario."
    );
  }

  const perfil = {
    id: data.id,
    nombres: data.nombres,
    apellidos: data.apellidos,
    correo: data.correo,
    telefono: data.telefono,
    fecha_nacimiento:
      data.fecha_nacimiento,
    estado: data.estado,
    rol_id: data.rol_id,
    rol: data.roles?.nombre ?? null,
    barbero: null,
  };

  if (
    Array.isArray(data.barberos) &&
    data.barberos.length > 0
  ) {
    perfil.barbero = data.barberos[0];
  } else if (
    data.barberos &&
    typeof data.barberos === "object"
  ) {
    perfil.barbero = data.barberos;
  }

  return perfil;
};

/**
 * Actualiza los datos básicos del usuario.
 */
export const editarPerfil = async (
  id,
  datos
) => {
  if (!id) {
    throw new Error(
      "El ID del usuario es obligatorio."
    );
  }

  const permitidos = [
    "nombres",
    "apellidos",
    "telefono",
    "fecha_nacimiento",
  ];

  const campos = Object.fromEntries(
    Object.entries(datos || {}).filter(
      ([key, value]) =>
        permitidos.includes(key) &&
        value !== null &&
        value !== undefined
    )
  );

  if (!Object.keys(campos).length) {
    throw new Error(
      "No hay datos válidos para actualizar."
    );
  }

  if (
    campos.nombres !== undefined &&
    String(campos.nombres).trim().length < 2
  ) {
    throw new Error(
      "El nombre debe tener al menos 2 caracteres."
    );
  }

  if (
    campos.apellidos !== undefined &&
    String(campos.apellidos).trim().length < 2
  ) {
    throw new Error(
      "Los apellidos deben tener al menos 2 caracteres."
    );
  }

  const { data, error } =
    await actualizarUsuario(id, campos);

  if (error) {
    throw new Error(error.message);
  }

  return data;
};