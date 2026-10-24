import { uploadDocumento } from "../config/multer.js";

export const subirDiploma = uploadDocumento.single("diploma");
