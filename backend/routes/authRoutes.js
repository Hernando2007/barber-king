import express from "express";

import {
    registrar,
    login,
    forgotPassword,
    resetPassword,
    mostrarResetPassword
} from "../controllers/authController.js";

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
    mostrarResetPassword
);


 
// CAMBIAR CONTRASEÑA
 

router.post(
    "/reset-password",
    resetPassword
);


export default router;