import express from "express";

import {
    crearCita,
    obtenerTodas,
    obtenerPorId,
    actualizar,
    eliminar
} from "../controllers/citasController.js";

const router = express.Router();


// Crear
router.post("/", crearCita);

// Listar
router.get("/", obtenerTodas);

// Buscar por ID
router.get("/:id", obtenerPorId);

// Actualizar
router.put("/:id", actualizar);

// Eliminar
router.delete("/:id", eliminar);

export default router;