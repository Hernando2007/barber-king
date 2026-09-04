import express from "express";

import { chatearConBarberKing, obtenerHistorialBarberKing } from "../controllers/chatController.js";

const router = express.Router();

router.post(
    "/chatear",
    chatearConBarberKing
);

router.get(
    "/historial/:sesionId",
    obtenerHistorialBarberKing
);

export default router;