import express from "express";
import { autenticarConGoogle } from "../controllers/googleauth.controller.js";

import {
    registrar,
    login,
    forgotPassword,
    resetPassword
} from "../controllers/authController.js";

const router = express.Router();

router.post("/registro", registrar);

router.post("/login", login);

router.post(
    "/forgot-password",
    forgotPassword
);

router.post(
    "/reset-password",
    resetPassword
);

// Endpoint: POST /api/auth/google
router.post("/google", autenticarConGoogle);

export default router;