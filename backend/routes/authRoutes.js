import express from "express";
import { autenticarConGoogle } from "../controllers/googleauth.controller.js";
import { registrar, login, forgotPassword, resetPassword, googleConfig } from "../controllers/authController.js";
import { subirDiploma } from "../middlewares/documentUploadMiddleware.js";
 
const router = express.Router();
 
router.post("/registro", subirDiploma, registrar);
router.post("/login", login);
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", resetPassword);
router.get("/google/config", googleConfig);
router.post("/google", autenticarConGoogle);
 
export default router;
