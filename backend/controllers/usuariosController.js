import { listarUsuarios, buscarUsuario, editarPerfil } from "../services/usuariosService.js";

export const getUsuarios = async (req, res, next) => {
  try {
    const data = await listarUsuarios();
    res.status(200).json({ success: true, total: data.length, data });
  } catch (error) { next(error); }
};

export const getUsuario = async (req, res, next) => {
  try {
    const data = await buscarUsuario(req.params.id);
    res.status(200).json({ success: true, data });
  } catch (error) { next(error); }
};

export const getPerfil = async (req, res, next) => {
  try {
    const data = await buscarUsuario(req.usuario.id);
    res.status(200).json({ success: true, data });
  } catch (error) { next(error); }
};

export const updatePerfil = async (req, res, next) => {
  try {
    const data = await editarPerfil(req.usuario.id, req.body);
    res.status(200).json({ success: true, message: "Perfil actualizado correctamente.", data });
  } catch (error) { next(error); }
};
