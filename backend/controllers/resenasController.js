import { listarResenas, obtenerUnaResena, listarResenasPorBarbero, registrarResena, editarResena, borrarResena } from "../services/resenasService.js";
export const obtenerTodas=async(req,res,next)=>{try{const data=await listarResenas();res.json({success:true,total:data.length,data});}catch(e){next(e);}};
export const obtenerPorId=async(req,res,next)=>{try{const data=await obtenerUnaResena(req.params.id);res.json({success:true,data});}catch(e){next(e);}};
export const obtenerPorBarbero=async(req,res,next)=>{try{const data=await listarResenasPorBarbero(req.params.barbero_id);res.json({success:true,total:data.length,data});}catch(e){next(e);}};
export const crear=async(req,res,next)=>{try{const data=await registrarResena(req.body,req.usuario);res.status(201).json({success:true,message:"Reseña creada correctamente.",data});}catch(e){next(e);}};
export const actualizar=async(req,res,next)=>{try{const data=await editarResena(req.params.id,req.body,req.usuario);res.json({success:true,message:"Reseña actualizada correctamente.",data});}catch(e){next(e);}};
export const eliminar=async(req,res,next)=>{try{await borrarResena(req.params.id,req.usuario);res.json({success:true,message:"Reseña eliminada correctamente."});}catch(e){next(e);}};
