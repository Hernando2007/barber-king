import express from "express";

import {
    getUsuarios,
    getUsuario
} from "../controllers/usuariosController.js";

import {
    verificarToken
} from "../middlewares/authMiddleware.js";

const router =
    express.Router();

router.get(
    "/obtener",
    verificarToken,
    getUsuarios
);

router.get(
    "/:id",
    verificarToken,
    getUsuario
);

export default router;