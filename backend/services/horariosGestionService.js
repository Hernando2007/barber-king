import {
  obtenerHorarioPorId,
  actualizarHorario,
  eliminarHorario,
} from "../models/horariosModel.js";

import { obtenerBarberoId } from "./horariosService.js";


// ======================================================
// EDITAR HORARIO
// ======================================================

export const editar = async (
  usuario,
  id,
  datos
) => {
  if (!id) {
    throw new Error(
      "El ID del horario es obligatorio."
    );
  }

  const barberoId =
    await obtenerBarberoId(usuario);

  const {
    data: horario,
    error: errorHorario,
  } = await obtenerHorarioPorId(id);

  if (errorHorario || !horario) {
    throw new Error(
      "Horario no encontrado."
    );
  }

  if (
    Number(horario.barbero_id) !==
    Number(barberoId)
  ) {
    throw new Error(
      "No tienes permiso para modificar este horario."
    );
  }

  const campos = {};

  if (
    datos?.dia_semana !== undefined
  ) {
    campos.dia_semana =
      Number(datos.dia_semana);
  }

  if (
    datos?.hora_inicio !== undefined
  ) {
    campos.hora_inicio =
      datos.hora_inicio;
  }

  if (
    datos?.hora_fin !== undefined
  ) {
    campos.hora_fin =
      datos.hora_fin;
  }

  if (
    datos?.activo !== undefined
  ) {
    campos.disponible =
      Boolean(datos.activo);
  }

  const horaInicio =
    campos.hora_inicio ??
    horario.hora_inicio;

  const horaFin =
    campos.hora_fin ??
    horario.hora_fin;

  if (horaInicio >= horaFin) {
    throw new Error(
      "La hora de inicio debe ser menor que la hora de fin."
    );
  }

  if (
    Object.keys(campos).length === 0
  ) {
    throw new Error(
      "No hay datos para actualizar."
    );
  }

  const { data, error } =
    await actualizarHorario(
      id,
      campos
    );

  if (error) {
    throw new Error(error.message);
  }

  return data;
};


// ======================================================
// NOMBRE COMPATIBLE CON EL CONTROLLER ACTUAL
// ======================================================

export const editarHorarioBarbero = async (
  usuario,
  id,
  datos
) => {
  return await editar(
    usuario,
    id,
    datos
  );
};


// ======================================================
// ELIMINAR HORARIO
// ======================================================

export const borrar = async (
  usuario,
  id
) => {
  if (!id) {
    throw new Error(
      "El ID del horario es obligatorio."
    );
  }

  const barberoId =
    await obtenerBarberoId(usuario);

  const {
    data: horario,
    error,
  } = await obtenerHorarioPorId(id);

  if (error || !horario) {
    throw new Error(
      "Horario no encontrado."
    );
  }

  if (
    Number(horario.barbero_id) !==
    Number(barberoId)
  ) {
    throw new Error(
      "No tienes permiso para eliminar este horario."
    );
  }

  const {
    error: errorEliminar,
  } = await eliminarHorario(id);

  if (errorEliminar) {
    throw new Error(
      errorEliminar.message
    );
  }

  return true;
};


// ======================================================
// NOMBRE COMPATIBLE CON EL CONTROLLER ACTUAL
// ======================================================

export const eliminarHorarioBarbero = async (
  usuario,
  id
) => {
  return await borrar(
    usuario,
    id
  );
};
