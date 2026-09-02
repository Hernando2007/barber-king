import express from "express";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";
import helmet from "helmet";
import morgan from "morgan";
import rateLimit from "express-rate-limit";

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
import resenasRoutes from "./routes/resenasRoutes.js";

const app = express();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);


app.use(cors());
        
// Seguridad HTTP
app.use(helmet());   

// Logs de las peticiones  
app.use(morgan("dev"));  
   
// Límite de peticiones
app.use(rateLimit({ 
    windowMs: 15 * 60 * 1000, // 15 minutos
    max: 100,
    message: {
        success: false,
        message: "Demasiadas peticiones. Inténtalo nuevamente en unos minutos."
    }
}));

// Lectura de JSON   
app.use(express.json());

// Lectura de formularios
app.use(express.urlencoded({ extended: true }));


app.get("/", (req, res) => {

    res.status(200).json({
        success: true,
        proyecto: "💈 Barber King API",
        version: "1.0.0",
        estado: "Activo"
    });

});


app.use(
    "/api-docs",
    swaggerUi.serve,
    swaggerUi.setup(swaggerSpec)
);


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

// Reseñas
app.use("/api/resenas", resenasRoutes);


// Swagger
app.use(
    "/api-docs",
    swaggerUi.serve,
    swaggerUi.setup(swaggerSpec)
);


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


app.use(errorHandler);

export default app;