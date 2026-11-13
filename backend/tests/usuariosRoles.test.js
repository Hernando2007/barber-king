import { test } from "node:test";
import assert from "node:assert/strict";

import {
    ROL_ADMINISTRADOR,
    ROL_BARBERO,
    ROL_CLIENTE,
    ROLES_VALIDOS,
    rolPorId,
    validarAdmin,
} from "../utils/usuariosRoles.js";

test("los tres roles del negocio siguen siendo 1, 2 y 3", () => {
    assert.equal(ROL_ADMINISTRADOR, 1);
    assert.equal(ROL_BARBERO, 2);
    assert.equal(ROL_CLIENTE, 3);
    assert.deepEqual(ROLES_VALIDOS, [1, 2, 3]);
});

test("rolPorId traduce el identificador a texto legible", () => {
    assert.equal(rolPorId(1), "Administrador");
    assert.equal(rolPorId("2"), "Barbero");
    assert.equal(rolPorId(3), "Cliente");
    assert.equal(rolPorId(99), null);
});

test("validarAdmin rechaza sin sesión con 401", () => {
    assert.throws(
        () => validarAdmin(null),
        (error) => error.statusCode === 401
    );
});

test("validarAdmin rechaza a un cliente con 403", () => {
    assert.throws(
        () => validarAdmin({ rol_id: ROL_CLIENTE, rol: "Cliente" }),
        (error) => error.statusCode === 403
    );
});

test("validarAdmin deja pasar al administrador", () => {
    assert.doesNotThrow(() =>
        validarAdmin({ rol_id: ROL_ADMINISTRADOR, rol: "Cliente" })
    );
    assert.doesNotThrow(() =>
        validarAdmin({ rol_id: ROL_CLIENTE, rol: "Administrador" })
    );
});
