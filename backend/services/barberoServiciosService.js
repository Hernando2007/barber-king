import {
    obtenerBarberoPorUsuario,
} from "../models/barberosModel.js";
import { obtenerServicioPorId } from "../models/serviciosModel.js";
import {
    obtenerPar,
    obtenerServiciosDelBarbero,
    reemplazarServiciosDelBarbero,
} from "../models/barberoServiciosModel.js";
import { httpError } from "../utils/httpError.js";
import { asegurarPerfilBarbero } from "./barberosService.js";

const MAX_PRECIO = 10_000_000;
const MAX_DURACION = 600;

// El barbero nace con su perfil al registrarse; si falta, se crea.
const perfilDelUsuario = async (usuarioId) => {
    const { data, error } = await obtenerBarberoPorUsuario(usuarioId);

    if (error) {
        throw httpError(500, error.message);
    }

    return data || asegurarPerfilBarbero(usuarioId);
};

export const serviciosDelBarbero = async (usuario) => {
    const barbero = await perfilDelUsuario(usuario.id);
    const { data, error } = await obtenerServiciosDelBarbero(barbero.id);

    if (error) {
        throw httpError(500, error.message);
    }

    return data || [];
};

export const guardarServiciosDelBarbero = async (usuario, servicios) => {
    const barbero = await perfilDelUsuario(usuario.id);
    const normalizados = await validarServicios(servicios);

    const { data, error } = await reemplazarServiciosDelBarbero(
        barbero.id,
        normalizados
    );

    if (error) {
        throw httpError(500, error.message);
    }

    return data || [];
};

// Lo que cobra y tarda un servicio concreto para un barbero dado.
// Falla si el par no existe: es la validación de la reserva.
export const condicionesDelServicio = async (barberoId, servicioId) => {
    const { data, error } = await obtenerPar(barberoId, servicioId);

    if (error) {
        throw httpError(500, error.message);
    }

    if (!data) {
        throw httpError(
            400,
            "Ese barbero no presta ese servicio. Elige otro barbero o otro servicio."
        );
    }

    if (!data.servicio_activo) {
        throw httpError(400, "Ese servicio ya no está disponible.");
    }

    return {
        nombre: data.nombre,
        precio: Number(data.precio),
        duracion: Number(data.duracion),
    };
};

const validarServicios = async (servicios) => {
    if (!Array.isArray(servicios) || !servicios.length) {
        throw httpError(400, "Marca al menos un servicio que atiendas.");
    }

    const vistos = new Set();
    const normalizados = [];

    for (const item of servicios) {
        const servicioId = Number(item?.servicio_id);

        if (!Number.isInteger(servicioId) || servicioId <= 0) {
            throw httpError(400, "Servicio no válido.");
        }

        if (vistos.has(servicioId)) {
            continue;
        }

        vistos.add(servicioId);
        normalizados.push({
            servicio_id: servicioId,
            precio: validarNumero(
                item.precio,
                MAX_PRECIO,
                "El precio debe ser mayor que cero."
            ),
            duracion: validarNumero(
                item.duracion,
                MAX_DURACION,
                "La duración debe ser un número de minutos entre 1 y 600.",
                true
            ),
        });
    }

    for (const servicio of normalizados) {
        const { data, error } = await obtenerServicioPorId(
            servicio.servicio_id
        );

        if (error) {
            throw httpError(500, error.message);
        }

        if (!data || data.estado !== true) {
            throw httpError(400, "Un servicio marcado ya no existe o está inactivo.");
        }
    }

    return normalizados;
};

const validarNumero = (valor, maximo, mensaje, esEntero = false) => {
    if (valor === null || valor === undefined || valor === "") {
        return null;
    }

    const numero = Number(valor);

    if (
        !Number.isFinite(numero) ||
        numero <= 0 ||
        numero > maximo ||
        (esEntero && !Number.isInteger(numero))
    ) {
        throw httpError(400, mensaje);
    }

    return numero;
};
