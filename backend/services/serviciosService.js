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
import {
    errorConEstado,
    normalizarCampos,
    validarAdmin
} from "../utils/serviciosValidacion.js";

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
