import multer from "multer";

// Todo viaja a Cloudinary en memoria: el disco de Render es efímero y se
// vacía en cada despliegue, así que una foto guardada ahí deja de existir.
const IMAGENES = ["image/jpeg", "image/png", "image/webp"];
const DOCUMENTOS = [...IMAGENES, "application/pdf"];

const errorFormato = (mensaje) => {
    const error = new Error(mensaje);
    error.statusCode = 400;
    return error;
};

const filtro = (permitidos, mensaje) => (_req, file, cb) => {
    if (!permitidos.includes(file.mimetype)) {
        return cb(errorFormato(mensaje));
    }

    cb(null, true);
};

export const uploadImagen = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 8 * 1024 * 1024 },
    fileFilter: filtro(IMAGENES, "La imagen debe ser JPG, PNG o WEBP.")
});

export const uploadDocumento = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024 },
    fileFilter: filtro(
        DOCUMENTOS,
        "El documento debe ser JPG, PNG, WEBP o PDF."
    )
});

export const uploadPortafolio = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 8 * 1024 * 1024, fileCount: 6 },
    fileFilter: filtro(IMAGENES, "Cada foto debe ser JPG, PNG o WEBP.")
});
