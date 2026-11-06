import rateLimit from "express-rate-limit";

const VENTANA = 15 * 60 * 1000;

export const limiteGeneral = rateLimit({
    windowMs: VENTANA,

    max: process.env.NODE_ENV === "production" ? 2000 : 5000,

    standardHeaders: true,

    legacyHeaders: false,

    message: {
        success: false,

        message: "Demasiadas peticiones. Espera un momento."
    }
});

export const limiteAutenticacion = rateLimit({
    windowMs: VENTANA,
    max: 50,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
        success: false,
        message: "Demasiados intentos. Espera unos minutos."
    }
});
