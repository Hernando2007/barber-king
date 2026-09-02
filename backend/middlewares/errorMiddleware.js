export const errorHandler = (
    err,
    req,
    res,
    next
) => {

    console.error(err);

    let statusCode =
        err.statusCode || 500;

    let message =
        err.message ||
        "Error interno del servidor.";

    if (
        err.name ===
        "TokenExpiredError"
    ) {

        statusCode = 401;

        message =
            "La sesión ha expirado.";

    }

    if (
        err.name ===
        "JsonWebTokenError"
    ) {

        statusCode = 401;

        message =
            "Token inválido.";

    }

    return res.status(
        statusCode
    ).json({

        success: false,

        message,

        ...(process.env.NODE_ENV === "development" && {
            stack: err.stack
        })

    });

};