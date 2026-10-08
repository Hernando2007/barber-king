import { obtenerUsuarios, obtenerUsuarioPorId, actualizarUsuario } from "../models/usuariosModel.js";

export const listarUsuarios = async () => {
  const { data, error } = await obtenerUsuarios();
  if (error) throw new Error(error.message);
  return data || [];
};

export const buscarUsuario = async (id) => {
  const { data, error } = await obtenerUsuarioPorId(id);
  if (error || !data) throw new Error("Usuario no encontrado.");
  return data;
};

export const editarPerfil = async (id, datos) => {
  const permitidos = ["nombres", "apellidos", "telefono", "fecha_nacimiento"];
  const campos = Object.fromEntries(Object.entries(datos || {})
    .filter(([key, value]) => permitidos.includes(key) && value !== null && value !== undefined));
  if (!Object.keys(campos).length) throw new Error("No hay datos válidos para actualizar.");
  if (campos.nombres !== undefined && String(campos.nombres).trim().length < 2) {
    throw new Error("El nombre debe tener al menos 2 caracteres.");
  }
  if (campos.apellidos !== undefined && String(campos.apellidos).trim().length < 2) {
    throw new Error("Los apellidos deben tener al menos 2 caracteres.");
  }
  const { data, error } = await actualizarUsuario(id, campos);
  if (error) throw new Error(error.message);
  return data;
};
