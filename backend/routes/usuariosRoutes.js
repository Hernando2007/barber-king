import express from "express";
import {
    getUsuarios,
    getUsuario,
    getPerfilActual,
    putPerfilActual,
    putFotoPerfil,
    putDiploma,
    crearUsuario,
    actualizarUsuario,
    eliminarUsuario,
} from "../controllers/usuariosController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
import { verificarRol } from "../middlewares/rolMiddleware.js";
import { subirImagen } from "../middlewares/uploadMiddleware.js";
import { subirDiploma } from "../middlewares/documentUploadMiddleware.js";

const router = express.Router();

router.get("/me", verificarToken, getPerfilActual);
router.put("/me", verificarToken, putPerfilActual);
router.put(
    "/me/foto",
    verificarToken,
    subirImagen,
    putFotoPerfil
);
router.put(
    "/me/diploma",
    verificarToken,
    verificarRol("Barbero"),
    subirDiploma,
    putDiploma
);

router.get(
    "/obtener",
    verificarToken,
    verificarRol("Administrador"),
    getUsuarios
);

router.post(
    "/crear",
    verificarToken,
    verificarRol("Administrador"),
    crearUsuario
);

router.put(
    "/:id",
    verificarToken,
    verificarRol("Administrador"),
    actualizarUsuario
);

router.delete(
    "/:id",
    verificarToken,
    verificarRol("Administrador"),
    eliminarUsuario
);

router.get(
    "/:id",
    verificarToken,
    verificarRol("Administrador"),
    getUsuario
);

export default router;
