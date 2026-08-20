import express from "express";

import {
    obtenerTodos,
    obtenerPorId,
    crear,
    actualizar,
    eliminar
} from "../controllers/barberosController.js";

const router = express.Router();

router.get("/obtenerTodos", obtenerTodos);

router.get("/barberos/:id", obtenerPorId);

router.post("/crear", crear);

router.put("/actualizar/:id", actualizar);

router.delete("/delete/:id", eliminar);

export default router;