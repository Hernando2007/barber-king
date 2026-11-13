import { test } from "node:test";
import assert from "node:assert/strict";

import { contieneProfanidad, normalizarTexto } from "../utils/profanidad.js";

test("normalizarTexto quita acentos, mayúsculas y signos", () => {
    assert.equal(normalizarTexto("  ¡CÓMO estás?  "), "como estas");
});

test("normalizarTexto reemplaza los caracteres tipo leetspeak", () => {
    assert.equal(normalizarTexto("put0"), "puto");
    assert.equal(normalizarTexto("m13rd4"), "mierda");
});

test("detecta una palabra prohibida aunque venga escrita con trucos", () => {
    assert.equal(contieneProfanidad("eres un pendejo"), true);
    assert.equal(contieneProfanidad("eres un P3NDEJ0"), true);
    assert.equal(contieneProfanidad("qué mierda de servicio"), true);
});

test("deja pasar un texto limpio o vacío", () => {
    assert.equal(contieneProfanidad("Excelente servicio, gracias"), false);
    assert.equal(contieneProfanidad(""), false);
    assert.equal(contieneProfanidad(null), false);
    assert.equal(contieneProfanidad(undefined), false);
});
