import {
    listarCitas,
    obtenerCitaPorId,
    actualizarCita,
    eliminarCita
} from "../models/citasModel.js";
import { obtenerBarberoPorUsuario } from "../models/barberosModel.js";

export const obtenerTodasLasCitas = async () => {
    const { data, error } = await listarCitas();

    if (error) {
        throw new Error(error.message);
    }

    return data || [];
};

export const obtenerUnaCita = async (id) => {
    const { data, error } = await obtenerCitaPorId(id);

    if (error || !data) {
        throw new Error("Cita no encontrada.");
    }

    return data;
};

const citasDelBarbero = async (usuario, citas) => {
    const { data: barbero } = await obtenerBarberoPorUsuario(usuario.id);

    if (!barbero) {
        return [];
    }

    return citas.filter(
        (cita) => Number(cita.barbero_id) === Number(barbero.id)
    );
};

export const obtenerCitasUsuario = async (usuario) => {
    const citas = await obtenerTodasLasCitas();

    if (usuario.rol === "Administrador") {
        return citas;
    }

    if (usuario.rol === "Barbero") {
        return citasDelBarbero(usuario, citas);
    }

    return citas.filter(
        (cita) => Number(cita.cliente_id) === Number(usuario.id)
    );
};

const validarAccesoCita = async (cita, usuario) => {
    if (usuario.rol === "Administrador") {
        return;
    }

    if (usuario.rol === "Cliente") {
        if (Number(cita.cliente_id) !== Number(usuario.id)) {
            throw new Error("No tienes acceso a esta cita.");
        }
        return;
    }

    if (usuario.rol === "Barbero") {
        const { data: barbero } = await obtenerBarberoPorUsuario(
            usuario.id
        );

        if (!barbero || Number(cita.barbero_id) !== Number(barbero.id)) {
            throw new Error("No tienes acceso a esta cita.");
        }
        return;
    }

    throw new Error("Rol no autorizado.");
};

export const editarCita = async (id, datos, usuario) => {
    const cita = await obtenerUnaCita(id);

    await validarAccesoCita(cita, usuario);

    const permitidos = {};

    if (usuario.rol === "Barbero" && datos.estado) {
        permitidos.estado = datos.estado;
    }

    if (usuario.rol === "Cliente") {
        if (datos.observaciones !== undefined) {
            permitidos.observaciones = datos.observaciones;
        }

        if (datos.estado === "Cancelada") {
            permitidos.estado = "Cancelada";
        }
    }

    if (usuario.rol === "Administrador") {
        Object.assign(permitidos, datos);
    }

    if (Object.keys(permitidos).length === 0) {
        throw new Error(
            "No tienes campos permitidos para modificar esta cita."
        );
    }

    const { data, error } = await actualizarCita(id, permitidos);

    if (error) {
        throw new Error(error.message);
    }

    return data;
};

export const borrarCita = async (id, usuario) => {
    const cita = await obtenerUnaCita(id);

    await validarAccesoCita(cita, usuario);

    if (usuario.rol === "Cliente") {
        const { error } = await actualizarCita(id, {
            estado: "Cancelada"
        });

        if (error) {
            throw new Error(error.message);
        }

        return true;
    }

    if (usuario.rol !== "Administrador") {
        throw new Error(
            "El barbero debe gestionar la cita mediante su estado."
        );
    }

    const { error } = await eliminarCita(id);

    if (error) {
        throw new Error(error.message);
    }

    return true;
};
