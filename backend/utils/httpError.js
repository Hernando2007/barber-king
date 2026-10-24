export const httpError = (statusCode, message, detalles = null) => {
    const error = new Error(message);
    error.statusCode = statusCode;
    if (detalles) {
        error.detalles = detalles;
    }
    return error;
};
