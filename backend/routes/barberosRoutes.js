import express from "express";

import {
    obtenerTodos,
    obtenerPorId,
    crear,
    actualizar,
    eliminar
} from "../controllers/barberosController.js";

const router = express.Router();


router.get("/", obtenerTodos);

router.get("/:id", obtenerPorId);

router.post("/", crear);

router.put("/:id", actualizar);

router.delete("/:id", eliminar);

export default router;