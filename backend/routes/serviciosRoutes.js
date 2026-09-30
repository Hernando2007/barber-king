import express from "express";
import { obtenerTodos, obtenerPorId, misServicios, crear, actualizar, eliminar } from "../controllers/serviciosController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
import { verificarRol } from "../middlewares/rolMiddleware.js";

const router = express.Router();

router.get("/obtener", obtenerTodos);
router.get("/obtener/:id", obtenerPorId);
router.get("/mis", verificarToken, verificarRol("Barbero"), misServicios);
router.post("/crear", verificarToken, verificarRol("Barbero", "Administrador"), crear);
router.put("/actualizar/:id", verificarToken, verificarRol("Barbero", "Administrador"), actualizar);
router.delete("/eliminar/:id", verificarToken, verificarRol("Barbero", "Administrador"), eliminar);

export default router;
