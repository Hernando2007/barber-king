import { subirImagenCloudinary } from "../services/cloudinaryService.js";

export const subirImagen = async (
    req,
    res,
    next
) => {
    try {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                message:
                    "Debe seleccionar una imagen."
            });
        }

        const imagen = await subirImagenCloudinary(
            req.file,
            "barber-king/chat"
        );

        return res.status(200).json({
            success: true,
            message:
                "Imagen subida correctamente.",
            data: {
                nombre:
                    req.file.originalname,
                tipo:
                    req.file.mimetype,
                peso:
                    req.file.size,
                publicId:
                    imagen.publicId,
                url:
                    imagen.url
            }
        });
    } catch (error) {
        next(error);
    }
};
