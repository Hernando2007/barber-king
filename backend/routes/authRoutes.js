import express from "express";
import { autenticarConGoogle } from "../controllers/googleauth.controller.js";
import {
    registrar,
    login,
    forgotPassword,
    resetPassword
} from "../controllers/authController.js";
import { upload } from "../config/cloudinary.js";

const router = express.Router();

// POST /api/auth/registro (multipart: diploma opcional, portafolio hasta 9 fotos)
router.post(
    "/registro",
    upload.fields([
        { name: "diploma", maxCount: 1 },
        { name: "portafolio", maxCount: 9 }
    ]),
    registrar
);

router.post("/login", login);

router.post("/forgot-password", forgotPassword);

router.post("/reset-password", resetPassword);

// POST /api/auth/google
router.post("/google", autenticarConGoogle);

export default router;