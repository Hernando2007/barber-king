import { crearNuevaCita, obtenerServicio, obtenerCitas, listarCitas, obtenerCitaPorId, actualizarCita, eliminarCita } from "../models/citasModel.js";
import { obtenerBarberoPorUsuario } from "../models/barberosModel.js";

const minutos = (hora) => {
  const [h, m] = String(hora).slice(0, 5).split(":").map(Number);
  return h * 60 + m;
};

export const registrarCita = async (datos, usuario) => {
  const { barbero_id, servicio_id, fecha, hora, observaciones } = datos || {};
  if (!barbero_id || !servicio_id || !fecha || !hora) throw new Error("Barbero, servicio, fecha y hora son obligatorios.");
  const fechaHora = new Date(`${fecha}T${hora}`);
  if (Number.isNaN(fechaHora.getTime()) || fechaHora < new Date()) throw new Error("La fecha y hora deben ser futuras.");
  const { data: servicio, error: es } = await obtenerServicio(servicio_id);
  if (es || !servicio) throw new Error("Servicio no encontrado.");
  const { data: citas, error: ec } = await obtenerCitas(barbero_id, fecha);
  if (ec) throw new Error(ec.message);
  const inicio = minutos(hora), fin = inicio + Number(servicio.duracion || 0);
  for (const cita of citas || []) {
    if ((cita.estado || "").toLowerCase() === "cancelada") continue;
    const ci = minutos(cita.hora), cf = ci + Number(cita.duracion_minutos || 0);
    if (inicio < cf && fin > ci) throw new Error("El barbero ya tiene una cita en ese horario.");
  }
  const { data, error } = await crearNuevaCita({
    cliente_id: usuario.id, barbero_id, servicio_id, fecha, hora,
    duracion_minutos: servicio.duracion, precio: servicio.precio,
    estado: "Pendiente", observaciones: observaciones || null,
  });
  if (error) throw new Error(error.message);
  return data;
};

export const obtenerTodasLasCitas = async (usuario) => {
  const filtro = usuario.rol === "Administrador"
    ? {} : usuario.rol === "Barbero" ? { barberoId: await buscarBarberoId(usuario.id) } : { clienteId: usuario.id };
  const { data, error } = await listarCitas(filtro);
  if (error) throw new Error(error.message);
  return data || [];
};

const buscarBarberoId = async (usuarioId) => {
  const { data, error } = await obtenerBarberoPorUsuario(usuarioId);
  if (error || !data) throw new Error("Perfil de barbero no encontrado.");
  return data.id;
};

export const obtenerUnaCita = async (id, usuario) => {
  const { data, error } = await obtenerCitaPorId(id);
  if (error || !data) throw new Error("Cita no encontrada.");
  if (!puedeGestionar(data, usuario)) throw new Error("No tienes permiso para consultar esta cita.");
  return data;
};

export const editarCita = async (id, datos, usuario) => {
  const actual = await obtenerUnaCita(id, usuario);
  const permitidos = usuario.rol === "Administrador" || usuario.rol === "Barbero"
    ? ["estado", "observaciones", "fecha", "hora"] : ["observaciones"];
  const cambios = Object.fromEntries(Object.entries(datos || {}).filter(([k]) => permitidos.includes(k)));
  if (!Object.keys(cambios).length) throw new Error("No hay cambios permitidos.");
  if (cambios.estado === "Completada" && usuario.rol === "Cliente") throw new Error("El cliente no puede completar una cita.");
  const { data, error } = await actualizarCita(actual.id, cambios);
  if (error) throw new Error(error.message);
  return data;
};

export const borrarCita = async (id, usuario) => {
  const actual = await obtenerUnaCita(id, usuario);
  if (usuario.rol === "Cliente" && actual.estado === "Completada") throw new Error("No puedes eliminar una cita completada.");
  const { error } = await eliminarCita(id);
  if (error) throw new Error(error.message);
  return true;
};

const puedeGestionar = (cita, usuario) => {
  if (usuario.rol === "Administrador") return true;
  if (usuario.rol === "Cliente") return Number(cita.cliente_id) === Number(usuario.id);
  return Number(cita.barberos?.usuario_id) === Number(usuario.id);
};
