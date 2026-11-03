import { obtenerBarberoPorId } from "../models/barberosModel.js";
import { httpError } from "../utils/httpError.js";

const VIGENCIA_MINUTOS = 30;

const estaVigente = (fecha) => {
    const momento = fecha ? new Date(fecha).getTime() : NaN;
    if (Number.isNaN(momento)) return false;
    return Date.now() - momento <= VIGENCIA_MINUTOS * 60 * 1000;
};

const nombreCompleto = (usuario) => {
    const nombre = `${usuario?.nombres ?? ""} ${usuario?.apellidos ?? ""}`;
    return nombre.trim() || "Barbero profesional";
};

export const obtenerUbicacionBarbero = async (id) => {
    const barberoId = Number(id);

    if (!Number.isFinite(barberoId) || barberoId <= 0) {
        throw httpError(400, "El ID del barbero es obligatorio.");
    }

    const { data, error } = await obtenerBarberoPorId(barberoId);

    if (error) {
        throw new Error(error.message);
    }

    if (!data) {
        throw httpError(404, "Barbero no encontrado.");
    }

    const latitud = Number(data.latitud);
    const longitud = Number(data.longitud);

    const comparte =
        data.latitud != null &&
        data.longitud != null &&
        Number.isFinite(latitud) &&
        Number.isFinite(longitud) &&
        estaVigente(data.ubicacion_actualizada);

    if (!comparte) {
        throw httpError(
            404,
            "El barbero no está compartiendo su ubicación en este momento."
        );
    }

    return {
        barbero_id: data.id,
        usuario_id: data.usuario_id,
        nombre: nombreCompleto(data.usuarios),
        foto: data.usuarios?.foto ?? null,
        latitud,
        longitud,
        ciudad: data.ciudad ?? null,
        zona: data.zona ?? null,
        actualizada_en: data.ubicacion_actualizada,
        disponible: data.disponible !== false,
    };
};
