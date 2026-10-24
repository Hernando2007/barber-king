import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import multer from "multer";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const uploadsDir = path.join(__dirname, "..", "uploads");
export const documentsDir = path.join(uploadsDir, "documents");

for (const dir of [uploadsDir, documentsDir]) {
    fs.mkdirSync(dir, { recursive: true });
}

const EXTENSIONES = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
    "application/pdf": ".pdf"
};

const crearStorage = (destino) =>
    multer.diskStorage({
        destination: (_req, _file, cb) => cb(null, destino),
        filename: (_req, file, cb) => {
            const extension =
                EXTENSIONES[file.mimetype] ||
                path.extname(file.originalname || "").toLowerCase() ||
                ".bin";

            cb(
                null,
                `bk_${Date.now()}_${Math.random()
                    .toString(36)
                    .slice(2, 9)}${extension}`
            );
        }
    });

const errorFormato = (mensaje) => {
    const error = new Error(mensaje);
    error.statusCode = 400;
    return error;
};

export const uploadImagen = multer({
    storage: crearStorage(uploadsDir),
    limits: { fileSize: 8 * 1024 * 1024 },
    fileFilter: (_req, file, cb) => {
        const permitidos = ["image/jpeg", "image/png", "image/webp"];

        if (!permitidos.includes(file.mimetype)) {
            return cb(
                errorFormato("La imagen debe ser JPG, PNG o WEBP.")
            );
        }

        cb(null, true);
    }
});

export const uploadDocumento = multer({
    storage: crearStorage(documentsDir),
    limits: { fileSize: 10 * 1024 * 1024 },
    fileFilter: (_req, file, cb) => {
        const permitidos = [
            "image/jpeg",
            "image/png",
            "image/webp",
            "application/pdf"
        ];

        if (!permitidos.includes(file.mimetype)) {
            return cb(
                errorFormato(
                    "El documento debe ser JPG, PNG, WEBP o PDF."
                )
            );
        }

        cb(null, true);
    }
});
