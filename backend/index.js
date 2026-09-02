import dotenv from "dotenv";

dotenv.config();

import app from "./app.js";

const PORT = process.env.PORT || 3000;

const server = app.listen(
    PORT,
    "0.0.0.0",
    () => {

        console.clear();

        console.log("========================================");
        console.log("💈 BARBER KING API");
        console.log("========================================");
        console.log(`🚀 Servidor : http://localhost:${PORT}`);

        if (
            process.env.NODE_ENV !==
            "production"
        ) {

            console.log(
                `📚 Swagger  : http://localhost:${PORT}/api-docs`
            );

        }

        console.log(
            `📅 Fecha    : ${new Date().toLocaleString()}`
        );

        console.log("========================================");

    }
);

server.on(
    "error",
    (error) => {

        console.error(
            "❌ Error al iniciar el servidor:"
        );

        console.error(error);

        process.exit(1);

    }
);

process.on(
    "unhandledRejection",
    (error) => {

        console.error(
            "❌ Promesa rechazada no controlada:"
        );

        console.error(error);

    }
);

process.on(
    "uncaughtException",
    (error) => {

        console.error(
            "❌ Excepción no controlada:"
        );

        console.error(error);

        process.exit(1);

    }
);