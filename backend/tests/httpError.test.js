import { test } from "node:test";
import assert from "node:assert/strict";

import { httpError } from "../utils/httpError.js";

test("httpError guarda el estado y el mensaje", () => {
    const error = httpError(403, "No tienes permisos.");

    assert.ok(error instanceof Error);
    assert.equal(error.statusCode, 403);
    assert.equal(error.message, "No tienes permisos.");
});

test("httpError solo agrega detalles cuando llegan", () => {
    const conDetalles = httpError(400, "Datos inválidos.", {
        campo: "precio",
    });
    const sinDetalles = httpError(400, "Datos inválidos.");

    assert.deepEqual(conDetalles.detalles, { campo: "precio" });
    assert.equal(sinDetalles.detalles, undefined);
});
