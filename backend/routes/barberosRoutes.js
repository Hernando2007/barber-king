import express from "express";

import {
    obtenerTodos,
    obtenerPorId,
    crear,
    actualizar,
    eliminar
} from "../controllers/barberosController.js";

import {
    verificarToken
} from "../middlewares/authMiddleware.js";

import {
    verificarRol
} from "../middlewares/rolMiddleware.js";

const router = express.Router();

router.get(
    "/obtener",
    obtenerTodos
);

router.get(
    "/obtener/:id",
    obtenerPorId
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