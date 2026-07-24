import express from "express";

import {
    getUsuarios,
    getUsuario
} from "../controllers/usuariosController.js";

const router = express.Router();

// Obtener todos
router.get("/", getUsuarios);

// Obtener uno
router.get("/:id", getUsuario);

export default router;