import express from "express";
import { autenticarConGoogle } from "../controllers/googleauth.controller.js";
import { registrar, login, forgotPassword, resetPassword } from "../controllers/authController.js";
import { subirDiploma } from "../middlewares/documentUploadMiddleware.js";
 
const router = express.Router();
 
router.post("/registro", subirDiploma, registrar);
router.post("/login", login);
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", resetPassword);
router.post("/google", autenticarConGoogle);
 
export default router;
