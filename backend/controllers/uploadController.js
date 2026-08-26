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

        const urlImagen =

            `${req.protocol}://${req.get("host")}/uploads/${req.file.filename}`;

        return res.status(200).json({

            success: true,

            message:
                "Imagen subida correctamente.",

            data: {

                nombre:
                    req.file.filename,

                original:
                    req.file.originalname,

                tipo:
                    req.file.mimetype,

                peso:
                    req.file.size,

                ruta:
                    `/uploads/${req.file.filename}`,

                url:
                    urlImagen

            }

        });

    } catch (error) {

        next(error);

    }

};