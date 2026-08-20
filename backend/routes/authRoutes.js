import express from "express";
import { registrar, login } from "../controllers/authController.js";
import { forgotPassword, resetPassword } from "../controllers/recuperacionController.js"

const router =
    express.Router();

// REGISTRO
router.post(
    "/registro",
    registrar
);
// LOGIN
router.post(
    "/login",
    login
);
// SOLICITAR RECUPERACIÓN
router.post(
    "/forgot-password",
    forgotPassword
);
// MOSTRAR FORMULARIO DE RECUPERACIÓN
router.get(
    "/reset-password",
    resetPassword
);
// CAMBIAR CONTRASEÑA
router.post(
    "/reset-password",
    resetPassword
);

export default router;