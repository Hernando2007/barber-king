import express from "express";

import {
    crearCita,
    obtenerTodas,
    obtenerPorId,
    actualizar,
    eliminar
} from "../controllers/citasController.js";

import {
    verificarToken
} from "../middlewares/authMiddleware.js";

const router = express.Router();

// Crear cita
router.post(
    "/crear",
    verificarToken,
    crearCita
);

// Obtener todas
router.get(
    "/obtenerTodas",
    verificarToken,
    obtenerTodas
);

// Obtener una
router.get(
    "/obtenerPorId/:id",
    verificarToken,
    obtenerPorId
);

// Actualizar
router.put(
    "/actualizar/:id",
    verificarToken,
    actualizar
);

// Eliminar
router.delete(
    "/delete/:id",
    verificarToken,
    eliminar
);

export default router;