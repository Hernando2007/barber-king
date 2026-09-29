import express from "express";
import {
    obtenerTodos,
    obtenerMisServicios,
    obtenerPorId,
    crear,
    actualizar,
    eliminar
} from "../controllers/serviciosController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
import { verificarRol } from "../middlewares/rolMiddleware.js";
 
const router = express.Router();
 
router.get("/obtener", obtenerTodos);
router.get("/obtener/:id", obtenerPorId);
 
router.get(
    "/mis",
    verificarToken,
    verificarRol("Barbero"),
    obtenerMisServicios
);
 
router.post(
    "/crear",
    verificarToken,
    verificarRol("Administrador", "Barbero"),
    crear
);
 
router.put(
    "/actualizar/:id",
    verificarToken,
    verificarRol("Administrador", "Barbero"),
    actualizar
);
 
router.delete(
    "/eliminar/:id",
    verificarToken,
    verificarRol("Administrador", "Barbero"),
    eliminar
);
 
export default router;
