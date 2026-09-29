import { uploadDocumento } from "../config/cloudinary.js";
 
export const subirDiploma = uploadDocumento.single("diploma");
