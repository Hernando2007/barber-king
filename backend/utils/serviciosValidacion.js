export const CAMPOS_PERMITIDOS = [
    "nombre",
    "descripcion",
    "precio",
    "duracion",
    "tiempo_descanso",
    "imagen",
    "estado"
];

export const errorConEstado = (mensaje, statusCode = 400, detalle = null) => {
    const error = new Error(mensaje);
    error.statusCode = statusCode;

    if (detalle) {
        error.detalle = detalle;
    }

    return error;
};

export const validarAdmin = (usuario) => {
    if (usuario?.rol !== "Administrador") {
        throw errorConEstado(
            "Solo un administrador puede gestionar los servicios.",
            403
        );
    }
};

/** Deja solo los campos conocidos y verifica uno a uno antes de tocar la base. */
export const normalizarCampos = (datos = {}, { parcial = false } = {}) => {
    const campos = {};

    for (const campo of CAMPOS_PERMITIDOS) {
        if (datos[campo] !== undefined) {
            campos[campo] = datos[campo];
        }
    }

    if (!parcial || campos.nombre !== undefined) {
        const nombre = String(campos.nombre ?? "").trim();

        if (nombre.length < 2 || nombre.length > 100) {
            throw errorConEstado(
                "El nombre debe tener entre 2 y 100 caracteres."
            );
        }

        campos.nombre = nombre;
    }

    if (!parcial || campos.precio !== undefined) {
        const precio = Number(campos.precio);

        if (!Number.isFinite(precio) || precio <= 0) {
            throw errorConEstado(
                "El precio debe ser un número mayor que cero."
            );
        }

        campos.precio = precio;
    }

    if (!parcial || campos.duracion !== undefined) {
        const duracion = Number(campos.duracion);

        if (!Number.isInteger(duracion) || duracion <= 0) {
            throw errorConEstado(
                "La duración debe ser un número entero mayor que cero."
            );
        }

        campos.duracion = duracion;
    }

    if (campos.tiempo_descanso !== undefined) {
        const descanso = Number(campos.tiempo_descanso);

        if (!Number.isInteger(descanso) || descanso < 0) {
            throw errorConEstado(
                "El tiempo de descanso debe ser un entero mayor o igual a cero."
            );
        }

        campos.tiempo_descanso = descanso;
    }

    if (campos.estado !== undefined) {
        campos.estado = Boolean(campos.estado);
    }

    if (campos.descripcion !== undefined) {
        campos.descripcion = String(campos.descripcion || "").trim() || null;
    }

    if (campos.imagen !== undefined) {
        campos.imagen = String(campos.imagen || "").trim() || null;
    }

    return campos;
};
