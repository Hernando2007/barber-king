import { test } from "node:test";
import assert from "node:assert/strict";

import {
    CAMPOS_PERMITIDOS,
    normalizarCampos,
} from "../utils/serviciosValidacion.js";

test("normalizarCampos descarta los campos que no están permitidos", () => {
    const campos = normalizarCampos({
        nombre: "Corte clásico",
        precio: 20000,
        duracion: 30,
        password: "no-debería-pasar",
        rol_id: 1,
    });

    assert.deepEqual(Object.keys(campos).sort(), [
        "duracion",
        "nombre",
        "precio",
    ]);
    assert.equal(CAMPOS_PERMITIDOS.includes("password"), false);
});

test("normalizarCampos recorta el nombre y convierte precio y duración", () => {
    const campos = normalizarCampos({
        nombre: "   Barba   ",
        precio: "25000",
        duracion: "45",
    });

    assert.equal(campos.nombre, "Barba");
    assert.equal(campos.precio, 25000);
    assert.equal(campos.duracion, 45);
});

test("rechaza un nombre demasiado corto", () => {
    assert.throws(
        () => normalizarCampos({ nombre: "A", precio: 1000, duracion: 10 }),
        (error) => error.statusCode === 400
    );
});

test("rechaza un precio que no sea mayor que cero", () => {
    for (const precio of [0, -5, "gratis"]) {
        assert.throws(
            () => normalizarCampos({ nombre: "Corte", precio, duracion: 10 }),
            (error) => error.statusCode === 400,
            `el precio ${precio} debía ser rechazado`
        );
    }
});

test("rechaza una duración que no sea un entero positivo", () => {
    for (const duracion of [0, -10, 12.5, "treinta"]) {
        assert.throws(
            () =>
                normalizarCampos({ nombre: "Corte", precio: 1000, duracion }),
            (error) => error.statusCode === 400,
            `la duración ${duracion} debía ser rechazada`
        );
    }
});

test("en modo parcial no exige nombre ni precio", () => {
    const campos = normalizarCampos(
        { estado: false, descripcion: "  " },
        { parcial: true }
    );

    assert.equal(campos.estado, false);
    assert.equal(campos.descripcion, null);
    assert.equal(campos.nombre, undefined);
});
