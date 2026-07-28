import express from "express";

import {
    consultarDisponibilidad
} from "../controllers/disponibilidadController.js";

const router = express.Router();

router.get("/", consultarDisponibilidad);

export default router;