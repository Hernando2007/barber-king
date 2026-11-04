import express from "express";
import {
    obtenerTodos,
    obtenerPorId,
    crear,
    actualizar,
    actualizarPerfil,
    actualizarUbicacion,
    cercanos,
    ubicacion,
    destacados,
    eliminar
} from "../controllers/barberosController.js";
import {
    obtenerDeBarbero,
    obtenerMis,
    guardarMis,
} from "../controllers/barberoServiciosController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
import { verificarRol } from "../middlewares/rolMiddleware.js";
 
const router = express.Router();
 
router.get("/obtener", obtenerTodos);
router.get("/obtener/:id", obtenerPorId);
router.get("/cercanos", verificarToken, cercanos);
router.get("/ubicacion/:id", verificarToken, ubicacion);
router.get("/destacados", verificarToken, destacados);

// Los servicios que atiende cada barbero y lo que cobra por ellos.
router.get("/servicios/mis", verificarToken, obtenerMis);
router.put("/servicios/mis", verificarToken, verificarRol("Barbero"), guardarMis);
router.get("/servicios/barbero/:barberoId", obtenerDeBarbero);
 
router.put(
    "/perfil",
    verificarToken,
    verificarRol("Barbero"),
    actualizarPerfil
);
 
router.put(
    "/ubicacion",
    verificarToken,
    verificarRol("Barbero"),
    actualizarUbicacion
);
 
router.post(
    "/crear",
    verificarToken,
    verificarRol("Administrador"),
    crear
);
 
router.put(
    "/actualizar/:id",
    verificarToken,
    verificarRol("Administrador"),
    actualizar
);
 
router.delete(
    "/eliminar/:id",
    verificarToken,
    verificarRol("Administrador"),
    eliminar
);
 
export default router;
