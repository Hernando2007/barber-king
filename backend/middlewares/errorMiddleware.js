// Middleware global de errores (ES Modules). No necesita importaciones externas.

const inferirEstado = (mensaje = "") => {
    const t = mensaje.toLowerCase();

    if (/fetch failed|econn|timeout|connection/.test(t)) return 500;
    if (/no encontrad/.test(t)) return 404;
    if (/permiso|no autorizado|no pertenece|no corresponde/.test(t)) return 403;
    if (/credenciales|incorrect/.test(t)) return 401;
    if (/ya (existe|est[aá]|tiene)|duplic|registrad/.test(t)) return 409;

    return 400;
};

export const errorHandler = (err, req, res, next) => {
    console.error(err);

    let statusCode = err.statusCode || inferirEstado(err.message);
    let message = err.message || "Error interno del servidor.";

    if (err.name === "TokenExpiredError") {
        statusCode = 401;
        message = "La sesión ha expirado.";
    }

    if (err.name === "JsonWebTokenError") {
        statusCode = 401;
        message = "Token inválido.";
    }

    return res.status(statusCode).json({
        success: false,
        message,
        ...(process.env.NODE_ENV === "development" && {
            stack: err.stack
        })
    });
};