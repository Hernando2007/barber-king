import { httpError } from "./httpError.js";

export const ROL_ADMINISTRADOR = 1;
export const ROL_BARBERO = 2;
export const ROL_CLIENTE = 3;

export const ROLES_VALIDOS = [
    ROL_ADMINISTRADOR,
    ROL_BARBERO,
    ROL_CLIENTE,
];

const NOMBRE_ROL = {
    [ROL_ADMINISTRADOR]: "Administrador",
    [ROL_BARBERO]: "Barbero",
    [ROL_CLIENTE]: "Cliente",
};

const esAdministrador = (usuario) => {
    const rol = String(usuario?.rol || "").toLowerCase();

    return (
        Number(usuario?.rol_id) === ROL_ADMINISTRADOR ||
        rol === "administrador"
    );
};

export const validarAdmin = (usuario) => {
    if (!usuario) {
        throw httpError(401, "Usuario no autenticado.");
    }

    if (!esAdministrador(usuario)) {
        throw httpError(
            403,
            "No tienes permisos para realizar esta acción."
        );
    }
};

export const rolPorId = (rolId) =>
    NOMBRE_ROL[Number(rolId)] || null;
