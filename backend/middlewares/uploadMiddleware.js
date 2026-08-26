import multer from "multer";
import path from "path";
import fs from "fs";

// Crear carpeta uploads si no existe
if (!fs.existsSync("uploads")) {

    fs.mkdirSync(
        "uploads",
        {
            recursive: true
        }
    );

}

const storage = multer.diskStorage({

    destination(
        req,
        file,
        cb
    ) {

        cb(
            null,
            "uploads"
        );

    },

    filename(
        req,
        file,
        cb
    ) {

        const nombre =

            Date.now() +
            "-" +
            Math.round(
                Math.random() * 1e9
            );

        cb(
            null,
            nombre +
            path.extname(
                file.originalname
            )
        );

    }

});

const fileFilter = (
    req,
    file,
    cb
) => {

    const tiposPermitidos = [

        "image/jpeg",
        "image/jpg",
        "image/png",
        "image/webp"

    ];

    const extensionPermitida = [

        ".jpg",
        ".jpeg",
        ".png",
        ".webp"

    ];

    const extension =
        path.extname(
            file.originalname
        ).toLowerCase();

    if (

        tiposPermitidos.includes(
            file.mimetype
        ) &&

        extensionPermitida.includes(
            extension
        )

    ) {

        return cb(
            null,
            true
        );

    }

    cb(
        new Error(
            "Solo se permiten imágenes JPG, JPEG, PNG o WEBP."
        )
    );

};

const upload = multer({

    storage,

    fileFilter,

    limits: {

        fileSize:
            5 * 1024 * 1024

    }

});

export default upload;