import express from "express";

import {
    obtenerTodos,
    obtenerPorId,
    crear,
    actualizar,
    eliminar
} from "../controllers/barberosController.js";

import { verificarToken } from "../middlewares/authMiddleware.js";
import { verificarRol } from "../middlewares/rolMiddleware.js";

const router = express.Router();

// Obtener todos los barberos
router.get(
    "/obtener",
    obtenerTodos
);

// Obtener un barbero por ID
router.get(
    "/obtener/:id",
    obtenerPorId
);

// Crear barbero
router.post(
    "/crear",
    verificarToken,
    verificarRol("Administrador"),
    crear
);

// Actualizar barbero
router.put(
    "/actualizar/:id",
    verificarToken,
    verificarRol("Administrador"),
    actualizar
);

// Eliminar barbero
router.delete(
    "/eliminar/:id",
    verificarToken,
    verificarRol("Administrador"),
    eliminar
);

export default router;