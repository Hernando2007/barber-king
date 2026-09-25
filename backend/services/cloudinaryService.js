import cloudinary from "../config/cloudinary.js";

export const subirImagenCloudinary = (
    archivo,
    carpeta = "barber-king"
) => {
    return new Promise((resolve, reject) => {

        if (!archivo || !archivo.buffer) {
            return reject(
                new Error("No se recibió ninguna imagen.")
            );
        }

        const stream = cloudinary.uploader.upload_stream(
            {
                folder: carpeta,
                resource_type: "image"
            },
            (error, resultado) => {

                if (error) {
                    console.error(
                        "Error subiendo imagen a Cloudinary:",
                        error
                    );

                    return reject(error);
                }

                resolve({
                    url: resultado.secure_url,
                    publicId: resultado.public_id,
                    formato: resultado.format,
                    ancho: resultado.width,
                    alto: resultado.height
                });
            }
        );

        stream.end(archivo.buffer);
    });
};

export const eliminarImagenCloudinary = async (
    publicId
) => {
    if (!publicId) {
        return;
    }

    return await cloudinary.uploader.destroy(
        publicId,
        {
            resource_type: "image"
        }
    );
};