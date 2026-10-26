import { Router } from "express";
import { verificarToken } from "../middlewares/authMiddleware.js";
import { verificarRol } from "../middlewares/rolMiddleware.js";
import { listarVerificacionesAdmin } from "../controllers/verificacionesController.js";

const router = Router();

router.get(
    "/",
    verificarToken,
    verificarRol("Administrador"),
    listarVerificacionesAdmin
);

export default router;
