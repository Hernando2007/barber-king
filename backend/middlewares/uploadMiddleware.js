import { upload } from "../config/cloudinary.js";

// Ya ejecuta .single("imagen") y lo exporta
export const subirImagen = upload.single("imagen");