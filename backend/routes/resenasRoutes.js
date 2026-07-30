import { Router } from "express";

import { verificarToken } from "../middlewares/authMiddleware.js";

import {

    obtenerTodas,
    obtenerPorId,
    obtenerPorBarbero,
    crear,
    actualizar,
    eliminar

} from "../controllers/resenasController.js";

const router = Router();

router.get(
    "/",
    verificarToken,
    obtenerTodas
);

router.get(
    "/:id",
    verificarToken,
    obtenerPorId
);

router.get(
    "/barbero/:barbero_id",
    verificarToken,
    obtenerPorBarbero
);

router.post(
    "/",
    verificarToken,
    crear
);

router.put(
    "/:id",
    verificarToken,
    actualizar
);

router.delete(
    "/:id",
    verificarToken,
    eliminar
);

export default router;