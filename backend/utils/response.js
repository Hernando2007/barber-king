export const success = (
    res,
    data,
    message = "Operación exitosa",
    status = 200
) => {

    return res.status(status).json({

        success: true,
        message,
        data

    });

};

export const error = (
    res,
    message = "Ha ocurrido un error",
    status = 500
) => {

    return res.status(status).json({

        success: false,
        message

    });

};