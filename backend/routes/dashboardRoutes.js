import { Router } from "express";

import { verificarToken } from "../middlewares/authMiddleware.js";
import { obtenerDashboardAdmin } from "../controllers/dashboardController.js";

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Dashboard
 *   description: Estadísticas del administrador
 */

/**
 * @swagger
 * /api/dashboard:
 *   get:
 *     summary: Obtener dashboard administrativo
 *     tags: [Dashboard]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Dashboard obtenido correctamente.
 *       401:
 *         description: Token inválido.
 *       500:
 *         description: Error interno del servidor.
 */

router.get(
    "/",
    verificarToken,
    obtenerDashboardAdmin
);

export default router;