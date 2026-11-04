import express from "express";
import {
    crearSolicitudController,
    misSolicitudes,
    motivosSolicitud,
    responderSolicitudController,
    resumen,
} from "../controllers/solicitudesController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
import { verificarRol } from "../middlewares/rolMiddleware.js";

const router = express.Router();

router.get("/motivos", verificarToken, motivosSolicitud);

// La misma ruta sirve para la bandeja del barbero y para "Mis solicitudes"
// del cliente: el servicio ramifica por rol.
router.get(
    "/mis",
    verificarToken,
    verificarRol("Barbero", "Cliente"),
    misSolicitudes
);

router.get(
    "/resumen",
    verificarToken,
    verificarRol("Barbero", "Cliente"),
    resumen
);

router.post(
    "/crear",
    verificarToken,
    verificarRol("Cliente"),
    crearSolicitudController
);

router.post(
    "/responder/:id",
    verificarToken,
    verificarRol("Barbero"),
    responderSolicitudController
);

export default router;
