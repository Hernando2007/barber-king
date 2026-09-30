import { listarHorarios,crear,editar,borrar } from "../services/horariosService.js";
export const obtener=async(req,res,next)=>{try{const data=await listarHorarios(req.usuario);res.json({success:true,data});}catch(e){next(e);}};
export const crearHorario=async(req,res,next)=>{try{const data=await crear(req.usuario,req.body);res.status(201).json({success:true,message:"Horario creado correctamente.",data});}catch(e){next(e);}};
export const actualizarHorario=async(req,res,next)=>{try{const data=await editar(req.usuario,req.params.id,req.body);res.json({success:true,message:"Horario actualizado correctamente.",data});}catch(e){next(e);}};
export const eliminarHorario=async(req,res,next)=>{try{await borrar(req.usuario,req.params.id);res.json({success:true,message:"Horario eliminado correctamente."});}catch(e){next(e);}};
