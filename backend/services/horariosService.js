import {
  obtenerHorarios,
  obtenerHorarioPorId,
  crearHorario,
  actualizarHorario,
  eliminarHorario,
} from "../models/horariosModel.js";

import {
  obtenerBarberoPorUsuario,
} from "../models/barberosModel.js";

const obtenerBarberoId = async (usuario) => {
  if (!usuario?.id) {
    throw new Error(
      "No se encontró el usuario autenticado."
    );
  }

  const { data, error } =
    await obtenerBarberoPorUsuario(usuario.id);

  if (error || !data) {
    throw new Error(
      "Perfil de barbero no encontrado."
    );
  }

  return data.id;
};


// ======================================================
// LISTAR HORARIOS DEL BARBERO AUTENTICADO
// ======================================================

export const listarHorarios = async (usuario) => {
  const barberoId =
    await obtenerBarberoId(usuario);

  const { data, error } =
    await obtenerHorarios(barberoId);

  if (error) {
    throw new Error(error.message);
  }

  return data || [];
};


// ======================================================
// CREAR HORARIO
// ======================================================

export const crear = async (
  usuario,
  datos
) => {
  const barberoId =
    await obtenerBarberoId(usuario);

  const {
    dia_semana,
    hora_inicio,
    hora_fin,
    activo,
  } = datos || {};

  if (
    dia_semana === undefined ||
    !hora_inicio ||
    !hora_fin
  ) {
    throw new Error(
      "Día, hora de inicio y hora de fin son obligatorios."
    );
  }

  if (hora_inicio >= hora_fin) {
    throw new Error(
      "La hora de inicio debe ser menor que la hora de fin."
    );
  }

  const { data, error } =
    await crearHorario({
      barbero_id: barberoId,
      dia_semana: Number(dia_semana),
      hora_inicio,
      hora_fin,
      activo:
        activo !== undefined
          ? activo
          : true,
    });

  if (error) {
    throw new Error(error.message);
  }

  return data;
};


// ======================================================
// NOMBRE COMPATIBLE CON EL CONTROLLER ACTUAL
// ======================================================

export const crearHorarioBarbero = async (
  usuario,
  datos
) => {
  return await crear(usuario, datos);
};


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
    campos.activo =
      datos.activo;
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