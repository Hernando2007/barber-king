import dotenv from "dotenv";
dotenv.config();

console.log("EMAIL_USER:", process.env.EMAIL_USER);
console.log("EMAIL_PASS:", process.env.EMAIL_PASS ? "CARGADA" : "VACÍA");

import { enviarCorreoRecuperacion } from "./services/emailService.js";

await enviarCorreoRecuperacion(
    "hernandobotellovargas2007@gmail.com",
    "https://barberking.com"
);

console.log("Correo enviado");