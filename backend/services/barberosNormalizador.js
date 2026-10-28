import { httpError } from "../utils/httpError.js";

export const normalizarBarbero = (datos, { parcial = true } = {}) => {
    const entrada = datos || {};
    const campos = {};

    if (!parcial || entrada.especialidad !== undefined) {
        const especialidad = String(
            entrada.especialidad || ""
        ).trim();

        if (!especialidad) {
            throw httpError(
                400,
                "La especialidad es obligatoria."
            );
        }

        campos.especialidad = especialidad;
    }

    if (entrada.experiencia !== undefined) {
        const experiencia = Number(entrada.experiencia);

        if (
            !Number.isFinite(experiencia) ||
            experiencia < 0 ||
            experiencia > 70
        ) {
            throw httpError(
                400,
                "La experiencia debe ser un número entre 0 y 70."
            );
        }

        campos.experiencia = Math.round(experiencia);
    }

    for (const campo of [
        "descripcion",
        "direccion",
        "foto_trabajo",
        "ciudad",
        "zona",
    ]) {
        if (entrada[campo] !== undefined) {
            const valor = String(entrada[campo] ?? "").trim();
            campos[campo] = valor.length ? valor.slice(0, 120) : null;
        }
    }

    if (entrada.disponible !== undefined) {
        campos.disponible = Boolean(entrada.disponible);
    }

    if (entrada.portafolio !== undefined) {
        if (!Array.isArray(entrada.portafolio)) {
            throw httpError(
                400,
                "El portafolio debe ser una lista."
            );
        }

        campos.portafolio = entrada.portafolio;
    }

    return campos;
};
