import express from "express";
import { subirImagen } from "../controllers/uploadController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
import { subirImagen as recibirImagen } from "../middlewares/uploadMiddleware.js";

const router = express.Router();

router.post(
    "/subir",
    verificarToken,
    recibirImagen,
    subirImagen
);

export default router;
