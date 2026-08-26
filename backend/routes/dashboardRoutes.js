import { Router } from "express";

import {
    verificarToken
} from "../middlewares/authMiddleware.js";

import {
    verificarRol
} from "../middlewares/rolMiddleware.js";

import {
    obtenerDashboardAdmin
} from "../controllers/dashboardController.js";

const router = Router();

router.get(
    "/",
    verificarToken,
    verificarRol("Administrador"),
    obtenerDashboardAdmin
);

export default router;