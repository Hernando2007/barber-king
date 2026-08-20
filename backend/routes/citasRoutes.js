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
router.post("/crear", crearCita);

// Listar
router.get("/obtenerTodas", obtenerTodas);

// Buscar por ID
router.get("/obtenerPorId/:id", obtenerPorId);

// Actualizar
router.put("/actualizar/:id", actualizar);

// Eliminar
router.delete("/delete/:id", eliminar);

export default router;