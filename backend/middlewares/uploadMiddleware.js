import { uploadImagen } from "../config/multer.js";

export const subirImagen = uploadImagen.single("imagen");
