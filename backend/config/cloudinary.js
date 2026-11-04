import { v2 as cloudinary } from "cloudinary";
import dotenv from "dotenv";

dotenv.config();

// Las credenciales viven en Render (CLOUDINARY_CLOUD_NAME, _API_KEY,
// _API_SECRET). Sin ellas, los uploaders fallan y el servicio de
// portafolio responde 503 en lugar de romper el arranque.
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

export default cloudinary;
