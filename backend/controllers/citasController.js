import { registrarCita, obtenerTodasLasCitas, obtenerUnaCita, editarCita, borrarCita } from "../services/citasService.js";
export const crearCita = async (req,res,next) => { try { const data=await registrarCita(req.body,req.usuario); res.status(201).json({success:true,message:"Cita creada correctamente.",data}); } catch(e){next(e);} };
export const obtenerTodas = async (req,res,next) => { try { const data=await obtenerTodasLasCitas(req.usuario); res.status(200).json({success:true,total:data.length,data}); } catch(e){next(e);} };
export const obtenerPorId = async (req,res,next) => { try { const data=await obtenerUnaCita(req.params.id,req.usuario); res.status(200).json({success:true,data}); } catch(e){next(e);} };
export const actualizar = async (req,res,next) => { try { const data=await editarCita(req.params.id,req.body,req.usuario); res.status(200).json({success:true,message:"Cita actualizada correctamente.",data}); } catch(e){next(e);} };
export const eliminar = async (req,res,next) => { try { await borrarCita(req.params.id,req.usuario); res.status(200).json({success:true,message:"Cita eliminada correctamente."}); } catch(e){next(e);} };
