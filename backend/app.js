import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import helmet from "helmet";
import morgan from "morgan";

import { errorHandler } from "./middlewares/errorMiddleware.js";
import dotenv from "dotenv";
dotenv.config();

import { middlewareCors } from "./config/corsConfig.js";
import {
    limiteAutenticacion,
    limiteGeneral,
    limiteSolicitudes,
} from "./config/limitePeticiones.js";

import authRoutes from "./routes/authRoutes.js";
import usuariosRoutes from "./routes/usuariosRoutes.js";
import disponibilidadRoutes from "./routes/disponibilidadRoutes.js";
import citasRoutes from "./routes/citasRoutes.js";
import barberosRoutes from "./routes/barberosRoutes.js";
import serviciosRoutes from "./routes/serviciosRoutes.js";
import uploadRoutes from "./routes/uploadRoutes.js";
import resenasRoutes from "./routes/resenasRoutes.js";
import dashboardRoutes from "./routes/dashboardRoutes.js";
import chatRoutes from "./routes/chatRoutes.js";
import horariosRoutes from "./routes/horariosRoutes.js";
import verificacionesRoutes from "./routes/verificacionesRoutes.js";
import solicitudesRoutes from "./routes/solicitudesRoutes.js";
import avisosRoutes from "./routes/avisosRoutes.js";
 
import {
    verificarEmailService
} from "./services/emailService.js";
 
verificarEmailService()
    .then(() => {
        console.log("📧 Verificación SMTP finalizada.");
    })
    .catch((error) => {
        console.error(
            "⚠️ Error SMTP:",
            error.message
        );
    });
 
const app = express();
 
app.disable("x-powered-by");
 
const __filename =
    fileURLToPath(import.meta.url);
 
const __dirname =
    path.dirname(__filename);
 
app.use(middlewareCors);
 
app.use(
    helmet({
        crossOriginEmbedderPolicy:
            false,
        crossOriginResourcePolicy: {
            policy: "cross-origin"
        }
    })
);
 
if (
    process.env.NODE_ENV !==
    "production"
) {
 
    app.use(morgan("dev"));
 
}

app.use(limiteGeneral);
app.use("/api/auth/login", limiteAutenticacion);
app.use("/api/auth/forgot-password", limiteAutenticacion);
app.use("/api/auth/reset-password", limiteAutenticacion);
app.use("/api/auth/google", limiteAutenticacion);
app.use("/api/auth/registro", limiteAutenticacion);
app.use("/api/solicitudes/crear", limiteSolicitudes);
 
app.use(express.json({
    limit: "10mb"
}));
 
app.use(express.urlencoded({
    extended: true,
    limit: "10mb"
}));
 
app.get("/health", (req, res) => {
 
    res.status(200).json({
 
        success: true,
 
        proyecto:
            "Barber King API",
 
        version:
            "1.0.0",
 
        estado:
            "Activo",
 
        uptime:
            process.uptime()
 
    });
 
});
 
app.use("/api/auth", authRoutes);
app.use("/api/usuarios", usuariosRoutes);
app.use("/api/disponibilidad", disponibilidadRoutes);
app.use("/api/citas", citasRoutes);
app.use("/api/barberos", barberosRoutes);
app.use("/api/servicios", serviciosRoutes);
app.use("/api/uploads", uploadRoutes);
app.use("/api/resenas", resenasRoutes);
app.use("/api/dashboard", dashboardRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/horarios", horariosRoutes);
app.use("/api/verificaciones", verificacionesRoutes);
app.use("/api/solicitudes", solicitudesRoutes);
app.use("/api/avisos", avisosRoutes);
 
app.use(
    "/uploads",
    express.static(
        path.join(
            __dirname,
            "uploads"
        ),
        {
            maxAge: "7d",
            etag: true
        }
    )
);
 
app.use(
    "/public",
    express.static(
        path.join(
            __dirname,
            "public"
        ),
        {
            maxAge: "30d",
            etag: true
        }
    )
);
 
app.use((req, res) => {
 
    res.status(404).json({
 
        success: false,
 
        message:
            "Ruta no encontrada."
 
    });
 
});
 
app.use(errorHandler);
 
export default app;
