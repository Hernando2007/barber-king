import dotenv from "dotenv";
import app from "./app.js";

dotenv.config();

const PORT = process.env.PORT || 3000;

app.listen(PORT, "0.0.0.0", () => {

    console.clear();

    console.log("========================================");
    console.log("💈 BARBER KING API");
    console.log("========================================");
    console.log(`🚀 Servidor : http://localhost:${PORT}`);
    console.log(`📚 Swagger  : http://localhost:${PORT}/api-docs`);
    console.log(`📅 Fecha    : ${new Date().toLocaleString()}`);
    console.log("========================================");

});