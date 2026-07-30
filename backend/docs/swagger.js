import swaggerJsdoc from "swagger-jsdoc";

const options = {
    definition: {
        openapi: "3.0.3",
        info: {
            title: "Barber King API",
            version: "1.0.0",
            description: `
API REST desarrollada con Node.js, Express y Supabase para la gestión de una barbería.

## Funcionalidades

- Autenticación con JWT
- Gestión de usuarios
- Gestión de roles
- Gestión de barberos
- Gestión de servicios
- Gestión de citas
- Gestión de reseñas
- Dashboard administrativo

Todos los endpoints protegidos requieren un token Bearer.
            `,
            contact: {
                name: "Fernando Hernández",
                email: "fernando@gmail.com"
            }
        },

        servers: [
            {
                url: "http://localhost:3000",
                description: "Servidor Local"
            }
        ],

        components: {

            securitySchemes: {

                bearerAuth: {

                    type: "http",
                    scheme: "bearer",
                    bearerFormat: "JWT"

                }

            }

        },

        security: [

            {
                bearerAuth: []
            }

        ]

    },

    apis: [
        "./routes/*.js"
    ]

};

const swaggerSpec = swaggerJsdoc(options);

export default swaggerSpec;