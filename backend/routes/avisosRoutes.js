import express from "express";
import { novedadesAvisos } from "../controllers/avisosController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";

const router = express.Router();

// Lo que pregunta la app en primer y segundo plano: qué avisos hay después
// del último id que ya leyó.
router.get("/novedades", verificarToken, novedadesAvisos);

export default router;
