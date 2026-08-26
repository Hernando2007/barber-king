import swaggerJsdoc from "swagger-jsdoc";

const options = {

    definition: {

        openapi: "3.0.3",

        info: {

            title: "Barber King API",

            version: "1.0.0",

            description: `
API REST desarrollada con Node.js, Express y Supabase para la gestión integral de una barbería.

## Funcionalidades

- Autenticación JWT
- Gestión de usuarios
- Gestión de barberos
- Gestión de servicios
- Gestión de citas
- Gestión de disponibilidad
- Gestión de reseñas
- Dashboard administrativo
- Subida de imágenes

Todos los endpoints protegidos requieren Bearer Token.
            `,

            contact: {

                name: "Fernando Hernández",
                email: "fernando@gmail.com"

            }

        },

        servers: [

            {
                url:
                    process.env.API_URL ||
                    "http://localhost:3000",

                description:
                    "Servidor principal"
            }

        ],

        components: {

            securitySchemes: {

                bearerAuth: {

                    type: "http",

                    scheme: "bearer",

                    bearerFormat: "JWT"

                }

            },

            schemas: {

                ErrorResponse: {

                    type: "object",

                    properties: {

                        success: {
                            type: "boolean",
                            example: false
                        },

                        message: {
                            type: "string",
                            example: "Ha ocurrido un error."
                        }

                    }

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

const swaggerSpec =
    swaggerJsdoc(options);

export default swaggerSpec;