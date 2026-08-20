import express from "express";

import {
    getUsuarios,
    getUsuario
} from "../controllers/usuariosController.js";

const router = express.Router();

// Obtener todos
router.get("/obtenerTodos", getUsuarios);

// Obtener uno
router.get("/obtenerUno/:id", getUsuario);

export default router;