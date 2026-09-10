import express from "express";
import { subirImagen } from "../middlewares/uploadMiddleware.js";

const router = express.Router();

router.post("/subir", subirImagen, (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: "No se ha subido ninguna imagen" });
  }

  res.json({
    message: "Imagen subida exitosamente",
    imageUrl: req.file.path
  });
});

export default router;