import {
  obtenerHorarios,
  crearHorario,
} from "../models/horariosModel.js";

import { asegurarPerfilBarbero } from "./barberosService.js";

export const obtenerBarberoId = async (usuario) => {
  if (!usuario?.id) {
    throw new Error(
      "No se encontró el usuario autenticado."
    );
  }

  const barbero = await asegurarPerfilBarbero(usuario.id);

  if (!barbero) {
    throw new Error(
      "Perfil de barbero no encontrado."
    );
  }

  return barbero.id;
};


// ======================================================
// LISTAR HORARIOS DEL BARBERO AUTENTICADO
// ======================================================

export const listarHorarios = async (usuarioOBarberoId) => {
  const esUsuario =
    usuarioOBarberoId &&
    typeof usuarioOBarberoId === "object";

  const barberoId = esUsuario
    ? await obtenerBarberoId(usuarioOBarberoId)
    : Number(usuarioOBarberoId);

  if (!barberoId || Number.isNaN(barberoId)) {
    throw new Error("Barbero inválido.");
  }

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
      disponible:
        activo !== undefined
          ? Boolean(activo)
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
