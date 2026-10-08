import { obtenerResenas, obtenerResenaPorId, obtenerResenasPorBarbero, crearResena, actualizarResena, eliminarResena } from "../models/resenasModel.js";
import { obtenerCitaPorId } from "../models/citasModel.js";
export const listarResenas=async()=>{const{data,error}=await obtenerResenas();if(error)throw new Error(error.message);return data||[];};
export const obtenerUnaResena=async(id)=>{const{data,error}=await obtenerResenaPorId(id);if(error||!data)throw new Error("Reseña no encontrada.");return data;};
export const listarResenasPorBarbero=async(id)=>{const{data,error}=await obtenerResenasPorBarbero(id);if(error)throw new Error(error.message);return data||[];};
export const registrarResena=async(datos,usuario)=>{
  const{cita_id,barbero_id,calificacion,comentario}=datos||{};
  if(!cita_id||!barbero_id||!calificacion)throw new Error("Cita, barbero y calificación son obligatorios.");
  if(Number(calificacion)<1||Number(calificacion)>5)throw new Error("La calificación debe estar entre 1 y 5.");
  const{data:cita,error:ec}=await obtenerCitaPorId(cita_id);if(ec||!cita)throw new Error("Cita no encontrada.");
  if(Number(cita.cliente_id)!==Number(usuario.id))throw new Error("La cita no pertenece al usuario autenticado.");
  if(cita.estado!=="Completada")throw new Error("Solo puedes calificar citas completadas.");
  if(Number(cita.barbero_id)!==Number(barbero_id))throw new Error("El barbero no corresponde a la cita.");
  const{data:existentes,error:ee}=await obtenerResenasPorBarbero(barbero_id);if(ee)throw new Error(ee.message);const yaCalifico=(existentes||[]).some(r=>Number(r.cliente_id)===Number(usuario.id));if(yaCalifico)throw new Error("Ya tienes una reseña publicada para este barbero.");
  const{data,error}=await crearResena({cliente_id:usuario.id,barbero_id,calificacion:Number(calificacion),comentario:comentario||null});if(error)throw new Error(error.message);return data;
};
export const editarResena=async(id,datos,usuario)=>{const actual=await obtenerUnaResena(id);if(Number(actual.cliente_id)!==Number(usuario.id)&&usuario.rol!=="Administrador")throw new Error("No tienes permiso para editar esta reseña.");const cambios={};if(datos.calificacion!==undefined)cambios.calificacion=Number(datos.calificacion);if(datos.comentario!==undefined)cambios.comentario=datos.comentario;if(cambios.calificacion<1||cambios.calificacion>5)throw new Error("La calificación debe estar entre 1 y 5.");const{data,error}=await actualizarResena(id,cambios);if(error)throw new Error(error.message);return data;};
export const borrarResena=async(id,usuario)=>{const actual=await obtenerUnaResena(id);if(Number(actual.cliente_id)!==Number(usuario.id)&&usuario.rol!=="Administrador")throw new Error("No tienes permiso para eliminar esta reseña.");const{error}=await eliminarResena(id);if(error)throw new Error(error.message);return true;};
