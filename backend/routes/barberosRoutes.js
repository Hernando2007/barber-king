import express from "express";
import {
    obtenerTodos,
    obtenerPorId,
    crear,
    actualizar,
    actualizarPerfil,
    actualizarUbicacion,
    cercanos,
    ubicacion,
    destacados,
    eliminar
} from "../controllers/barberosController.js";
import {
    obtenerDeBarbero,
    obtenerMis,
    guardarMis,
} from "../controllers/barberoServiciosController.js";
import {
    borrarMiFotoController,
    misFotosController,
    fotosDelBarbero,
    subirMisFotos,
} from "../controllers/portafolioController.js";
import { uploadPortafolio } from "../config/multer.js";
import {
    decidirPendiente,
    pendientesRevision,
} from "../controllers/revisionBarberosController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
import { verificarRol } from "../middlewares/rolMiddleware.js";
 
const router = express.Router();
 
router.get("/obtener", obtenerTodos);
router.get("/obtener/:id", obtenerPorId);
router.get("/cercanos", verificarToken, cercanos);
router.get("/ubicacion/:id", verificarToken, ubicacion);
router.get("/destacados", verificarToken, destacados);

// Los servicios que atiende cada barbero y lo que cobra por ellos.
router.get("/servicios/mis", verificarToken, obtenerMis);
router.put("/servicios/mis", verificarToken, verificarRol("Barbero"), guardarMis);
router.get("/servicios/barbero/:barberoId", obtenerDeBarbero);

// El portafolio de fotos vive en Cloudinary.
router.get("/portafolio/mis", verificarToken, verificarRol("Barbero"), misFotosController);
router.post(
    "/portafolio/mis",
    verificarToken,
    verificarRol("Barbero"),
    uploadPortafolio.array("fotos", 6),
    subirMisFotos
);
router.delete(
    "/portafolio/mis/:fotoId",
    verificarToken,
    verificarRol("Barbero"),
    borrarMiFotoController
);
router.get("/portafolio/barbero/:barberoId", fotosDelBarbero);

// Bandeja del administrador: los barberos que esperan el sello de verificado.
router.get(
    "/revision",
    verificarToken,
    verificarRol("Administrador"),
    pendientesRevision
);
router.post(
    "/revision/:id",
    verificarToken,
    verificarRol("Administrador"),
    decidirPendiente
);
 
router.put(
    "/perfil",
    verificarToken,
    verificarRol("Barbero"),
    actualizarPerfil
);
 
router.put(
    "/ubicacion",
    verificarToken,
    verificarRol("Barbero"),
    actualizarUbicacion
);
 
router.post(
    "/crear",
    verificarToken,
    verificarRol("Administrador"),
    crear
);
 
router.put(
    "/actualizar/:id",
    verificarToken,
    verificarRol("Administrador"),
    actualizar
);
 
router.delete(
    "/eliminar/:id",
    verificarToken,
    verificarRol("Administrador"),
    eliminar
);
 
export default router;
