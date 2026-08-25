import express from "express";

import {
    obtenerTodos,
    obtenerPorId,
    crear,
    actualizar,
    eliminar
} from "../controllers/serviciosController.js";

import { verificarToken } from "../middlewares/authMiddleware.js";
import { verificarRol } from "../middlewares/rolMiddleware.js"

const router = express.Router();

// Obtener todos los servicios
router.get(
    "/obtener",
    obtenerTodos
);

// Obtener un servicio por ID
router.get(
    "/obtener/:id",
    obtenerPorId
);

// Crear servicio
// Solo administradores
router.post(
    "/crear",
    verificarToken,
    verificarRol("Administrador"),
    crear
);

// Actualizar servicio
// Solo administradores
router.put(
    "/actualizar/:id",
    verificarToken,
    verificarRol("Administrador"),
    actualizar
);

// Eliminar servicio
// Solo administradores
router.delete(
    "/eliminar/:id",
    verificarToken,
    verificarRol("Administrador"),
    eliminar
);

export default router;