import supabase from "../config/supabase.js";

const detalle = `*, usuarios!cliente_id(id,nombres,apellidos,correo), barberos(id,usuario_id,especialidad), servicios(id,nombre,precio,duracion)`;

export const obtenerHorarioBarbero = async (barberoId, diaSemana) => supabase.from("horarios")
  .select("*").eq("barbero_id", barberoId).eq("dia_semana", diaSemana).maybeSingle();
export const obtenerServicio = async (servicioId) => supabase.from("servicios")
  .select("*").eq("id", servicioId).maybeSingle();
export const obtenerCitas = async (barberoId, fecha) => supabase.from("citas")
  .select("*").eq("barbero_id", barberoId).eq("fecha", fecha);
export const crearNuevaCita = async (datos) => supabase.from("citas").insert(datos).select().single();
export const listarCitas = async (filtro) => {
  let q = supabase.from("citas").select(detalle).order("fecha", { ascending: true }).order("hora", { ascending: true });
  if (filtro?.clienteId) q = q.eq("cliente_id", filtro.clienteId);
  if (filtro?.barberoId) q = q.eq("barbero_id", filtro.barberoId);
  return q;
};
export const obtenerCitaPorId = async (id) => supabase.from("citas").select(detalle).eq("id", id).maybeSingle();
export const actualizarCita = async (id, datos) => supabase.from("citas").update(datos).eq("id", id).select().single();
export const eliminarCita = async (id) => supabase.from("citas").delete().eq("id", id);
