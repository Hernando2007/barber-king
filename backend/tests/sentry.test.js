import { test } from "node:test";
import assert from "node:assert/strict";

import {
    capturarError,
    cerrarSentry,
    iniciarSentry,
    sentryActivo,
} from "../config/sentry.js";

test("sentryActivo refleja exactamente si hay SENTRY_DSN", () => {
    // La invariante es la consistencia, no exigir el DSN vacío: cuando se
    // pegue uno, el backend empezará a enviar errores a propósito.
    // Debe ser función y no const, porque en ESM las importaciones corren
    // antes que dotenv.config() (ver el comentario de config/sentry.js).
    assert.equal(typeof sentryActivo, "function");
    assert.equal(sentryActivo(), Boolean(process.env.SENTRY_DSN));
});

test("iniciarSentry con el DSN vacío no rompe ni pide red", () => {
    // No debe lanzar: el backend tiene que arrancar igual con o sin Sentry.
    assert.doesNotThrow(() => iniciarSentry());
});

test("capturarError con Sentry apagado no hace nada", () => {
    // capturarError es síncrono: debe resolver sin lanzar, porque los call
    // sites no envuelven cada captura en un try/catch.
    assert.doesNotThrow(() =>
        capturarError(new Error("fallo simulado"), { ruta: "/health" })
    );
});

test("cerrarSentry con Sentry apagado no hace nada", async () => {
    await assert.doesNotReject(() => cerrarSentry());
});
