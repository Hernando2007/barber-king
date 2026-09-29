import { v2 as cloudinary } from "cloudinary";
import { CloudinaryStorage } from "multer-storage-cloudinary";
import multer from "multer";
import dotenv from "dotenv";
 
dotenv.config();
 
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});
 
const imageStorage = new CloudinaryStorage({
    cloudinary,
    params: {
        folder: "barber-king/images",
        allowed_formats: ["jpg", "jpeg", "png", "webp"]
    }
});
 
const documentStorage = new CloudinaryStorage({
    cloudinary,
    params: {
        folder: "barber-king/documents",
        resource_type: "auto",
        allowed_formats: [
            "jpg",
            "jpeg",
            "png",
            "webp",
            "pdf"
        ]
    }
});
 
export const upload = multer({
    storage: imageStorage,
    limits: {
        fileSize: 8 * 1024 * 1024
    }
});
 
export const uploadDocumento = multer({
    storage: documentStorage,
    limits: {
        fileSize: 10 * 1024 * 1024
    },
    fileFilter: (_req, file, cb) => {
        const permitidos = [
            "image/jpeg",
            "image/png",
            "image/webp",
            "application/pdf"
        ];
 
        if (!permitidos.includes(file.mimetype)) {
            return cb(
                new Error(
                    "El diploma debe ser una imagen JPG, PNG, WEBP o un PDF."
                )
            );
        }
 
        cb(null, true);
    }
});
 
export default cloudinary;
