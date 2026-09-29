import express from "express";
import {
    getUsuarios,
    getUsuario,
    getPerfilActual
} from "../controllers/usuariosController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
 
const router = express.Router();
 
router.get("/me", verificarToken, getPerfilActual);
router.get("/obtener", verificarToken, getUsuarios);
router.get("/:id", verificarToken, getUsuario);
 
export default router;
