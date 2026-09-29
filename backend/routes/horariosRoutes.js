import express from "express";
import {
    obtenerHorarios,
    crear,
    actualizar,
    eliminar
} from "../controllers/horariosController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
import { verificarRol } from "../middlewares/rolMiddleware.js";
 
const router = express.Router();
 
router.get(
    "/barbero/:barbero_id",
    verificarToken,
    obtenerHorarios
);
 
router.post(
    "/crear",
    verificarToken,
    verificarRol("Barbero"),
    crear
);
 
router.put(
    "/actualizar/:id",
    verificarToken,
    verificarRol("Barbero"),
    actualizar
);
 
router.delete(
    "/eliminar/:id",
    verificarToken,
    verificarRol("Barbero"),
    eliminar
);
 
export default router;
