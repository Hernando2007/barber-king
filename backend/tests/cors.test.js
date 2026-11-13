import { test } from "node:test";
import assert from "node:assert/strict";

import { esOrigenLocal } from "../config/corsConfig.js";

test("deja pasar las peticiones sin cabecera Origin (app móvil, curl, health)", () => {
    assert.equal(esOrigenLocal(undefined), true);
    assert.equal(esOrigenLocal(null), true);
    assert.equal(esOrigenLocal(""), true);
});

test("acepta los orígenes locales de desarrollo", () => {
    assert.equal(esOrigenLocal("http://localhost:3000"), true);
    assert.equal(esOrigenLocal("http://127.0.0.1:3000"), true);
});

test("acepta las redes privadas que usa la app en el celular", () => {
    assert.equal(esOrigenLocal("http://192.168.1.100:3000"), true);
    assert.equal(esOrigenLocal("http://10.0.2.2:3000"), true);
    assert.equal(esOrigenLocal("http://172.20.5.5:3000"), true);
});

test("rechaza los orígenes públicos que no estén configurados", () => {
    assert.equal(esOrigenLocal("https://ejemplo.com"), false);
    assert.equal(esOrigenLocal("https://otro-dominio.io:8080"), false);
});
