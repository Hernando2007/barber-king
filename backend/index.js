import usuariosRoutes from "./routes/usuariosRoutes.js";
import express from "express";
import cors from "cors";
import dotenv from "dotenv";

// Cargar las variables del archivo .env
dotenv.config();

// Crear la aplicación de Express
const app = express();

// Configuración de middlewares
app.use(cors());
app.use(express.json());

app.use("/api/usuarios", usuariosRoutes);

// Ruta principal
app.get("/", (req, res) => {
    res.status(200).json({
        success: true,
        message: "🚀 Bienvenido a la API de Barber King",
        version: "1.0.0"
    });
});

// Puerto del servidor
const PORT = process.env.PORT || 3000;

// Iniciar servidor
app.listen(PORT, () => {
    console.log("=================================");
    console.log("💈 BARBER KING API");
    console.log("=================================");
    console.log(`🚀 Servidor: http://localhost:${PORT}`);
    console.log(`📅 Fecha: ${new Date().toLocaleString()}`);
    console.log("=================================");
});