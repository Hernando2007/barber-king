import express from "express";
import {
    chatearConBarberKing,
    recomendarCorteConIA,
    obtenerHistorialBarberKing,
} from "../controllers/chatController.js";
import {
    contactosDirectos,
    mensajesDirectos,
    enviarDirecto,
} from "../controllers/chatDirectoController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
import { subirImagen } from "../middlewares/uploadMiddleware.js";

const router = express.Router();

router.get(
    "/directo/contactos",
    verificarToken,
    contactosDirectos
);

router.get(
    "/directo/mensajes/:contactoId",
    verificarToken,
    mensajesDirectos
);

router.post(
    "/directo/mensajes",
    verificarToken,
    enviarDirecto
);

router.post("/chatear", verificarToken, chatearConBarberKing);

router.post(
    "/recomendar-corte",
    verificarToken,
    subirImagen,
    recomendarCorteConIA
);

router.get(
    "/historial/:sesionId",
    verificarToken,
    obtenerHistorialBarberKing
);

export default router;
