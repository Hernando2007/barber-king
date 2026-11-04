import express from "express";
import {
    crearCita,
    obtenerTodas,
    obtenerProximas,
    obtenerPorId,
    actualizar,
    eliminar
} from "../controllers/citasController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
 
const router = express.Router();
 
router.post("/crear", verificarToken, crearCita);
router.get("/obtenerTodas", verificarToken, obtenerTodas);
router.get("/proximas", verificarToken, obtenerProximas);
router.get("/obtenerPorId/:id", verificarToken, obtenerPorId);
router.put("/actualizar/:id", verificarToken, actualizar);
router.delete("/delete/:id", verificarToken, eliminar);
 
export default router;
