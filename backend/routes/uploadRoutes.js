import express from "express";
import upload from "../middlewares/uploadMiddleware.js";
import { subirImagen } from "../controllers/uploadController.js";

const router = express.Router();

router.post(
    "/subirImagen",
    upload.single("imagen"),
    subirImagen
);

export default router;