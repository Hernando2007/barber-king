import {
    obtenerServicios,
    obtenerServicioPorId,
    crearServicio,
    actualizarServicio,
    eliminarServicio,
    contarCitasPorServicio,
    eliminarCitasPorServicio,
    obtenerIdsCitasPorServicio,
    eliminarResenasPorCitas
} from "../models/serviciosModel.js";

const CAMPOS_PERMITIDOS = [
    "nombre",
    "descripcion",
    "precio",
    "duracion",
    "tiempo_descanso",
    "imagen",
    "estado"
];

const errorConEstado = (mensaje, statusCode = 400, detalle = null) => {
    const error = new Error(mensaje);
    error.statusCode = statusCode;

    if (detalle) {
        error.detalle = detalle;
    }

    return error;
};

const validarAdmin = (usuario) => {
    if (usuario?.rol !== "Administrador") {
        throw errorConEstado(
            "Solo un administrador puede gestionar los servicios.",
            403
        );
    }
};

const normalizarCampos = (datos = {}, { parcial = false } = {}) => {
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

export const listarServicios = async ({ soloActivos = false } = {}) => {
    const { data, error } = await obtenerServicios({ soloActivos });

    if (error) {
        throw new Error(error.message);
    }

    return data || [];
};

export const listarMisServicios = async (_usuario) => {
    // El catálogo es global: los barberos consultan los servicios activos
    // y el administrador es quien los administra.
    return await listarServicios();
};

export const obtenerUno = async (id) => {
    const { data, error } = await obtenerServicioPorId(id);

    if (error) {
        throw new Error(error.message);
    }

    if (!data) {
        throw errorConEstado("Servicio no encontrado.", 404);
    }

    return data;
};

export const registrarServicio = async (usuario, datos) => {
    validarAdmin(usuario);
    const campos = normalizarCampos(datos);

    const { data, error } = await crearServicio(campos);

    if (error) {
        throw new Error(error.message);
    }

    return data;
};

export const editarServicio = async (usuario, id, datos) => {
    validarAdmin(usuario);
    await obtenerUno(id);

    const campos = normalizarCampos(datos, { parcial: true });

    if (!Object.keys(campos).length) {
        throw errorConEstado("No hay datos válidos para actualizar.");
    }

    const { data, error } = await actualizarServicio(id, campos);

    if (error) {
        throw new Error(error.message);
    }

    return data;
};

export const borrarServicio = async (usuario, id, { forzar = false } = {}) => {
    validarAdmin(usuario);
    await obtenerUno(id);

    const { count, error: errorConteo } =
        await contarCitasPorServicio(id);

    if (errorConteo) {
        throw new Error(errorConteo.message);
    }

    const totalCitas = count || 0;

    if (totalCitas > 0 && !forzar) {
        throw errorConEstado(
            `Este servicio tiene ${totalCitas} cita(s) asociada(s). Puedes desactivarlo o eliminar también su historial.`,
            409,
            { citas: totalCitas, sugerencia: "desactivar" }
        );
    }

    if (totalCitas > 0 && forzar) {
        const { data: citas } = await obtenerIdsCitasPorServicio(id);
        const ids = (citas || []).map((cita) => cita.id);

        await eliminarResenasPorCitas(ids);

        const { error: errorCitas } = await eliminarCitasPorServicio(id);

        if (errorCitas) {
            throw new Error(errorCitas.message);
        }
    }

    const { error } = await eliminarServicio(id);

    if (error) {
        throw new Error(error.message);
    }

    return { eliminado: true, citasEliminadas: totalCitas };
};
