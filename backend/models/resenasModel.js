import supabase from "../config/supabase.js";
const detalle=`*,usuarios!cliente_id(id,nombres,apellidos),barberos(id,especialidad)`;
export const obtenerResenas=async()=>supabase.from("resenas").select(detalle).order("created_at",{ascending:false});
export const obtenerResenaPorId=async(id)=>supabase.from("resenas").select(detalle).eq("id",id).maybeSingle();
export const obtenerResenasPorBarbero=async(barberoId)=>supabase.from("resenas").select(`*,usuarios!cliente_id(id,nombres,apellidos)`).eq("barbero_id",barberoId).order("created_at",{ascending:false});
export const crearResena=async(datos)=>supabase.from("resenas").insert(datos).select().single();
export const actualizarResena=async(id,datos)=>supabase.from("resenas").update(datos).eq("id",id).select().single();
export const eliminarResena=async(id)=>supabase.from("resenas").delete().eq("id",id);
