import express from "express";
import { registrar, login } from "../controllers/authController.js";
import { forgotPassword, resetPassword } from "../controllers/recuperacionController.js"

const router =
    express.Router();

// Registro
router.post(
    "/registro",
    registrar
);

// Inicio de sesión
router.post(
    "/login",
    login
);

// Solicitar recuperación de contraseña
router.post(
    "/forgot-password",
    forgotPassword
);

// Cambiar contraseña usando el token
router.post(
    "/reset-password",
    resetPassword
);

export default router;