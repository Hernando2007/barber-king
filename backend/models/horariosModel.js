import supabase from "../config/supabase.js";
export const obtenerHorarios=async(barberoId)=>supabase.from("horarios").select("*").eq("barbero_id",barberoId).order("dia_semana");
export const obtenerHorario=async(id)=>supabase.from("horarios").select("*").eq("id",id).maybeSingle();
export const crearHorario=async(datos)=>supabase.from("horarios").insert(datos).select().single();
export const actualizarHorario=async(id,datos)=>supabase.from("horarios").update(datos).eq("id",id).select().single();
export const eliminarHorario=async(id)=>supabase.from("horarios").delete().eq("id",id);
