import * as Sentry from "@sentry/node";

// Sentry está cableado pero apagado mientras SENTRY_DSN esté vacío: si no
// existe la variable (o está en blanco), el SDK no se inicializa y el backend
// se comporta exactamente como antes, sin dependencias de red ni de un
// servicio externo.
//
// Para encenderlo:
//   1. Crear el proyecto "barber-king-backend" (plataforma Node) en sentry.io.
//   2. Copiar el DSN y ponerlo como SENTRY_DSN en backend/.env y en Render.
//   3. Reiniciar el backend.
//
// OJO: la comprobación es una función y no un const. En ESM las importaciones
// se evalúan antes que el cuerpo del archivo que las importa, así que un
// `const sentryActivo = Boolean(process.env.SENTRY_DSN)` se calcularía antes
// de que dotenv cargue el .env y quedaría siempre en false. Se lee en el
// momento de usarlo.
export const sentryActivo = () => Boolean(process.env.SENTRY_DSN);

// Solo se envía si iniciarSentry() corrió: tener el DSN no basta, el SDK
// tiene que haberse inicializado antes de capturar nada.
let inicializado = false;

export const iniciarSentry = () => {
    if (!sentryActivo() || inicializado) {
        return;
    }

    Sentry.init({
        dsn: process.env.SENTRY_DSN,
        environment: process.env.NODE_ENV || "development",
        // Sin trazas: solo se quieren los errores, no el costo de cada
        // petición. Subir a 1.0 si algún día se quieren métricas.
        tracesSampleRate: 0,
        // Los errores 4xx son decisiones de la API (datos inválidos,
        // sesión vencida): ya se responden al cliente y solo ensuciarían
        // el panel. Lo que interesa es el 5xx y lo que se escape.
        ignoreErrors: [],
    });

    inicializado = true;

    console.log("🐛 Sentry activo en el backend.");
};

// Captura un error ya clasificado. Se llama desde el manejador central de
// errores, así que solo llegan los que se respondieron como 500.
export const capturarError = (error, contexto = {}) => {
    if (!inicializado) {
        return;
    }

    Sentry.withScope((scope) => {
        for (const [clave, valor] of Object.entries(contexto)) {
            scope.setExtra(clave, valor);
        }

        Sentry.captureException(error);
    });
};

// Vuelca lo que quede en cola antes de salir. Sin esto, los errores de
// cierre (uncaughtException) podrían perderse.
export const cerrarSentry = async () => {
    if (!inicializado) {
        return;
    }

    await Sentry.close(2000);
};
