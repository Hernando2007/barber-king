import multer from "multer";

export const errorHandler = (err, req, res, _next) => {
    console.error(err);

    let statusCode = err.statusCode || 500;
    let message = err.message || "Error interno del servidor.";

    if (err instanceof multer.MulterError) {
        statusCode = 400;
        message =
            err.code === "LIMIT_FILE_SIZE"
                ? "El archivo supera el tamaño máximo permitido."
                : "No fue posible procesar el archivo.";
    }

    if (err.name === "TokenExpiredError") {
        statusCode = 401;
        message = "La sesión ha expirado.";
    }

    if (err.name === "JsonWebTokenError") {
        statusCode = 401;
        message = "Token inválido.";
    }

    if (
        !err.statusCode &&
        /duplicate key|already exists/i.test(String(err.message))
    ) {
        statusCode = 409;
        message = "Ya existe un registro con esos datos.";
    }

    if (
        !err.statusCode &&
        /foreign key constraint/i.test(String(err.message))
    ) {
        statusCode = 409;
        message =
            "No se puede completar la operación porque el registro tiene información relacionada.";
    }

    return res.status(statusCode).json({
        success: false,
        message,
        ...(err.detalles && { detalles: err.detalles }),
        ...(process.env.NODE_ENV === "development" && {
            stack: err.stack
        })
    });
};
