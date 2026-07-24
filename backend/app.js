import express from "express";
import cors from "cors";

// Swagger
import swaggerUi from "swagger-ui-express";
import swaggerSpec from "./docs/swagger.js";

// Rutas
import authRoutes from "./routes/authRoutes.js";
import usuariosRoutes from "./routes/usuariosRoutes.js";

const app = express();

/* ===========================================
   MIDDLEWARES
=========================================== */

app.use(cors());

app.use(express.json());

app.use(express.urlencoded({ extended: true }));

/* ===========================================
   RUTA PRINCIPAL
=========================================== */

app.get("/", (req, res) => {
    res.status(200).json({
        success: true,
        proyecto: "💈 Barber King API",
        version: "1.0.0",
        estado: "Activo"
    });
});

/* ===========================================
   DOCUMENTACIÓN
=========================================== */

app.use(
    "/api-docs",
    swaggerUi.serve,
    swaggerUi.setup(swaggerSpec)
);

/* ===========================================
   RUTAS
=========================================== */

app.use("/api/auth", authRoutes);

app.use("/api/usuarios", usuariosRoutes);

/* ===========================================
   RUTA NO ENCONTRADA
=========================================== */

app.use((req, res) => {

    res.status(404).json({
        success: false,
        message: "Ruta no encontrada."
    });

});

import { errorHandler } from "./middlewares/errorMiddleware.js";

export default app;

app.use(errorHandler);