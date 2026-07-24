import swaggerJsdoc from "swagger-jsdoc";

const options = {
    definition: {
        openapi: "3.0.0",
        info: {
            title: "Barber King API",
            version: "1.0.0",
            description: "API REST para la gestión de una barbería."
        },
        servers: [
            {
                url: "http://localhost:3000"
            }
        ]
    },
    apis: [
        "./routes/*.js"
    ]
};

const swaggerSpec = swaggerJsdoc(options);

export default swaggerSpec;