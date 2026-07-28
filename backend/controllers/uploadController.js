export const subirImagen = async (req, res, next) => {

    try {

        if (!req.file) {

            return res.status(400).json({
                success: false,
                message: "Debe seleccionar una imagen."
            });

        }

        return res.status(200).json({

            success: true,
            message: "Imagen subida correctamente.",
            archivo: req.file.filename,
            ruta: `/uploads/${req.file.filename}`

        });

    } catch (error) {

        next(error);

    }

};