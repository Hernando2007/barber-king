import {
    actualizarBarbero,
    obtenerBarberos,
    obtenerBarberoPorUsuario,
    obtenerCalificacionesBarberos,
} from "../models/barberosModel.js";
import { httpError } from "../utils/httpError.js";

const RADIO_TIERRA_KM = 6371;
const VIGENCIA_MINUTOS = 30;

const distanciaKm = (lat1, lng1, lat2, lng2) => {
    const radianes = (grados) => (grados * Math.PI) / 180;
    const dLat = radianes(lat2 - lat1);
    const dLng = radianes(lng2 - lng1);

    const a =
        Math.sin(dLat / 2) ** 2 +
        Math.cos(radianes(lat1)) *
            Math.cos(radianes(lat2)) *
            Math.sin(dLng / 2) ** 2;

    return RADIO_TIERRA_KM * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
};

const coordenada = (valor, minimo, maximo, nombre) => {
    const numero = Number(valor);

    if (!Number.isFinite(numero) || numero < minimo || numero > maximo) {
        throw httpError(
            400,
            `${nombre} debe ser un número entre ${minimo} y ${maximo}.`
        );
    }

    return Number(numero.toFixed(6));
};

const textoOpcional = (valor) => {
    if (valor === undefined) return undefined;

    const limpio = String(valor ?? "").trim();
    return limpio.length ? limpio.slice(0, 120) : null;
};

const estaVigente = (fecha) => {
    const momento = fecha ? new Date(fecha).getTime() : NaN;
    if (Number.isNaN(momento)) return false;
    return Date.now() - momento <= VIGENCIA_MINUTOS * 60 * 1000;
};

const resumirCalificaciones = (resenas) => {
    const resumen = new Map();

    for (const resena of resenas || []) {
        const barberoId = Number(resena.barbero_id);
        const nota = Number(resena.calificacion);
        if (!Number.isFinite(barberoId) || !Number.isFinite(nota)) continue;
        const actual = resumen.get(barberoId) || { suma: 0, total: 0 };
        actual.suma += nota;
        actual.total += 1;
        resumen.set(barberoId, actual);
    }

    return resumen;
};

export const anotarCalificaciones = async (barberos = []) => {
    if (!barberos.length) return [];

    const { data, error } = await obtenerCalificacionesBarberos();

    if (error) {
        throw new Error(error.message);
    }

    const resumen = resumirCalificaciones(data);
    return barberos.map((barbero) => {
        const notas = resumen.get(Number(barbero.id));
        const total = notas?.total || 0;
        const {
            latitud: _latitud,
            longitud: _longitud,
            ...resto
        } = barbero;

        return {
            ...resto,
            calificacion_promedio: total
                ? Number((notas.suma / total).toFixed(2))
                : 0,
            total_resenas: total,
            tiene_ubicacion:
                barbero.latitud != null && barbero.longitud != null,
            ubicacion_vigente: estaVigente(barbero.ubicacion_actualizada),
        };
    });
};

export const listarBarberosDestacados = async (limite = 5) => {
    const { data, error } = await obtenerBarberos();

    if (error) {
        throw new Error(error.message);
    }

    const barberos = await anotarCalificaciones(data || []);

    return barberos
        .filter((barbero) => barbero.total_resenas > 0)
        .sort(
            (a, b) =>
                b.calificacion_promedio - a.calificacion_promedio ||
                b.total_resenas - a.total_resenas ||
                Number(b.experiencia || 0) - Number(a.experiencia || 0)
        )
        .slice(0, Math.min(Math.max(Number(limite) || 5, 1), 20));
};

export const listarBarberosCercanos = async ({
    latitud,
    longitud,
    radio_km: radioKm,
    limite,
} = {}) => {
    const lat = coordenada(latitud, -90, 90, "La latitud");
    const lng = coordenada(longitud, -180, 180, "La longitud");
    const radio = Number(radioKm) > 0
        ? Math.min(Number(radioKm), 100)
        : 15;
    const maximo = Math.min(Math.max(Number(limite) || 30, 1), 50);
    const { data, error } = await obtenerBarberos();

    if (error) {
        throw new Error(error.message);
    }
    const cercanos = (data || [])
        .filter(
            (barbero) =>
                barbero.latitud != null &&
                barbero.longitud != null &&
                Number.isFinite(Number(barbero.latitud)) &&
                Number.isFinite(Number(barbero.longitud)) &&
                estaVigente(barbero.ubicacion_actualizada)
        )
        .map((barbero) => ({
            ...barbero,
            distancia_km: Number(
                distanciaKm(
                    lat,
                    lng,
                    Number(barbero.latitud),
                    Number(barbero.longitud)
                ).toFixed(1)
            ),
        }))
        .filter((barbero) => barbero.distancia_km <= radio)
        .sort((a, b) => a.distancia_km - b.distancia_km)
        .slice(0, maximo);

    return await anotarCalificaciones(cercanos);
};

export const actualizarUbicacionBarbero = async (usuarioId, datos) => {
    const latitud = coordenada(datos?.latitud, -90, 90, "La latitud");
    const longitud = coordenada(datos?.longitud, -180, 180, "La longitud");

    const { data: barbero, error } = await obtenerBarberoPorUsuario(usuarioId);

    if (error) {
        throw new Error(error.message);
    }

    if (!barbero) {
        throw httpError(404, "Perfil de barbero no encontrado.");
    }

    const campos = {
        latitud,
        longitud,
        ubicacion_actualizada: new Date().toISOString(),
    };

    const ciudad = textoOpcional(datos?.ciudad);
    const zona = textoOpcional(datos?.zona);

    if (ciudad !== undefined) campos.ciudad = ciudad;
    if (zona !== undefined) campos.zona = zona;

    const { data, error: errorActualizar } = await actualizarBarbero(
        barbero.id,
        campos
    );

    if (errorActualizar) {
        throw new Error(errorActualizar.message);
    }

    return data;
};
