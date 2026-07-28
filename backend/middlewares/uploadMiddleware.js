import multer from "multer";
import path from "path";
import fs from "fs";

// Crear carpeta uploads si no existe
if (!fs.existsSync("uploads")) {
    fs.mkdirSync("uploads");
}

const storage = multer.diskStorage({

    destination(req, file, cb) {

        cb(null, "uploads");

    },

    filename(req, file, cb) {

        const nombre =
            Date.now() +
            "-" +
            Math.round(Math.random() * 1E9);

        cb(
            null,
            nombre +
            path.extname(file.originalname)
        );

    }

});

const fileFilter = (req, file, cb) => {

    const permitidos = /jpg|jpeg|png|webp/;

    const extension = permitidos.test(
        path.extname(file.originalname).toLowerCase()
    );

    const mime = permitidos.test(file.mimetype);

    if (extension && mime) {

        return cb(null, true);

    }

    cb(new Error("Solo se permiten imágenes."));

};

const upload = multer({

    storage,
    fileFilter,
    limits: {

        fileSize: 5 * 1024 * 1024

    }

});

export default upload;