import express from "express";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";
import helmet from "helmet";
import morgan from "morgan";
import rateLimit from "express-rate-limit";

import swaggerUi from "swagger-ui-express";
import swaggerSpec from "./docs/swagger.js";

import { errorHandler } from "./middlewares/errorMiddleware.js";

import authRoutes from "./routes/authRoutes.js";
import usuariosRoutes from "./routes/usuariosRoutes.js";
import disponibilidadRoutes from "./routes/disponibilidadRoutes.js";
import citasRoutes from "./routes/citasRoutes.js";
import barberosRoutes from "./routes/barberosRoutes.js";
import serviciosRoutes from "./routes/serviciosRoutes.js";
import uploadRoutes from "./routes/uploadRoutes.js";
import resenasRoutes from "./routes/resenasRoutes.js";
import dashboardRoutes from "./routes/dashboardRoutes.js";

import {
    verificarEmailService
} from "./services/emailService.js";

try {

    await verificarEmailService();

    console.log(
        "✅ Servicio de correo conectado."
    );

} catch (error) {

    console.error(
        "⚠️ Error SMTP:",
        error.message
    );

}

const app = express();

app.disable("x-powered-by");

const __filename =
    fileURLToPath(import.meta.url);

const __dirname =
    path.dirname(__filename);

const allowedOrigins = [
    process.env.FRONTEND_URL,
    "http://localhost:49783",
    "http://localhost:3000",
    "http://127.0.0.1:3000",
];

app.use(
    cors({
        origin: (origin, callback) => {

            console.log("Origin:", origin);

            if (!origin) {
                return callback(null, true);
            }

            if (allowedOrigins.includes(origin)) {
                return callback(null, true);
            }

            return callback(null, true);
        },

        credentials: true,
        methods: [
            "GET",
            "POST",
            "PUT",
            "DELETE",
            "PATCH",
            "OPTIONS"
        ],

        allowedHeaders: [
            "Content-Type",
            "Authorization"
        ]
    })
);

app.use(
    helmet({
        crossOriginEmbedderPolicy:
            false
    })
);

if (
    process.env.NODE_ENV !==
    "production"
) {

    app.use(morgan("dev"));

}

app.use(rateLimit({

    windowMs:
        15 * 60 * 1000,

    max:
        process.env.NODE_ENV ===
        "production"
            ? 300
            : 100,

    standardHeaders: true,

    legacyHeaders: false,

    message: {

        success: false,

        message:
            "Demasiadas peticiones."

    }

}));

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

if (
    process.env.NODE_ENV !==
    "production"
) {

    app.use(
        "/api-docs",
        swaggerUi.serve,
        swaggerUi.setup(swaggerSpec)
    );

}

app.use("/api/auth", authRoutes);
app.use("/api/usuarios", usuariosRoutes);
app.use("/api/disponibilidad", disponibilidadRoutes);
app.use("/api/citas", citasRoutes);
app.use("/api/barberos", barberosRoutes);
app.use("/api/servicios", serviciosRoutes);
app.use("/api/uploads", uploadRoutes);
app.use("/api/resenas", resenasRoutes);
app.use("/api/dashboard", dashboardRoutes);

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

app.use((req, res) => {

    res.status(404).json({

        success: false,

        message:
            "Ruta no encontrada."

    });

});

app.use(errorHandler);

export default app;