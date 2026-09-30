import express from "express";
import { getUsuarios, getUsuario, getPerfil, updatePerfil } from "../controllers/usuariosController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
import { verificarRol } from "../middlewares/rolMiddleware.js";

const router = express.Router();
router.get("/me", verificarToken, getPerfil);
router.put("/me", verificarToken, updatePerfil);
router.get("/obtener", verificarToken, verificarRol("Administrador"), getUsuarios);
router.get("/:id", verificarToken, getUsuario);
export default router;

