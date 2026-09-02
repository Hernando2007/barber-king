import express from "express";

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

export default router;