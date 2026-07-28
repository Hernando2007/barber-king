import express from "express";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";

// Swagger
import swaggerUi from "swagger-ui-express";
import swaggerSpec from "./docs/swagger.js";

// Middlewares
import { errorHandler } from "./middlewares/errorMiddleware.js";

// Rutas
import authRoutes from "./routes/authRoutes.js";
import usuariosRoutes from "./routes/usuariosRoutes.js";
import disponibilidadRoutes from "./routes/disponibilidadRoutes.js";
import citasRoutes from "./routes/citasRoutes.js";
import barberosRoutes from "./routes/barberosRoutes.js";
import serviciosRoutes from "./routes/serviciosRoutes.js";
import uploadRoutes from "./routes/uploadRoutes.js";

const app = express();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

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
   SWAGGER
=========================================== */

app.use(
    "/api-docs",
    swaggerUi.serve,
    swaggerUi.setup(swaggerSpec)
);

/* ===========================================
   RUTAS
=========================================== */

// Auth
app.use("/api/auth", authRoutes);

// Usuarios
app.use("/api/usuarios", usuariosRoutes);

// Disponibilidad
app.use("/api/disponibilidad", disponibilidadRoutes);

// Citas
app.use("/api/citas", citasRoutes);

// Barberos
app.use("/api/barberos", barberosRoutes);

// Servicios
app.use("/api/servicios", serviciosRoutes);

// Uploads

app.use("/api/uploads", uploadRoutes);

/* ===========================================
   RUTA NO ENCONTRADA
=========================================== */

app.use(
    "/uploads",
    express.static(path.join(__dirname, "uploads"))
);

app.use((req, res) => {

    res.status(404).json({
        success: false,
        message: "Ruta no encontrada."
    });

});

/* ===========================================
   MANEJO DE ERRORES
=========================================== */

app.use(errorHandler);

export default app;