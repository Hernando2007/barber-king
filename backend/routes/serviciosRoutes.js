import express from "express";

import {
    obtenerTodos,
    obtenerPorId,
    crear,
    actualizar,
    eliminar
} from "../controllers/serviciosController.js";

import { verificarToken } from "../middlewares/authMiddleware.js";
import { verificarRol } from "../middlewares/roleMiddleware.js";

const router = express.Router();



router.get("/", obtenerTodos);

router.get("/:id", obtenerPorId);


router.post(
    "/",
    verificarToken,
    verificarRol("Administrador"),
    crear
);

router.put(
    "/:id",
    verificarToken,
    verificarRol("Administrador"),
    actualizar
);

router.delete(
    "/:id",
    verificarToken,
    verificarRol("Administrador"),
    eliminar
);

export default router;