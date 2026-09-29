import {
    crearNuevaCita,
    obtenerServicio,
    obtenerCitas,
    listarCitas,
    obtenerCitaPorId,
    actualizarCita,
    eliminarCita
} from "../models/citasModel.js";
import { obtenerBarberoPorUsuario } from "../models/barberosModel.js";
 
export const registrarCita = async (datos) => {
    const {
        cliente_id,
        barbero_id,
        servicio_id,
        fecha,
        hora,
        estado,
        observaciones
    } = datos;
 
    if (
        !cliente_id ||
        !barbero_id ||
        !servicio_id ||
        !fecha ||
        !hora
    ) {
        throw new Error(
            "Todos los campos obligatorios deben ser enviados."
        );
    }
 
    const fechaHoraNueva = new Date(`${fecha}T${hora}`);
 
    if (Number.isNaN(fechaHoraNueva.getTime())) {
        throw new Error("La fecha u hora no son válidas.");
    }
 
    if (fechaHoraNueva < new Date()) {
        throw new Error(
            "No se pueden registrar citas en fechas pasadas."
        );
    }
 
    const { data: servicio, error: errorServicio } =
        await obtenerServicio(servicio_id);
 
    if (errorServicio || !servicio) {
        throw new Error("Servicio no encontrado.");
    }
 
    const { data: citasExistentes, error: errorCitas } =
        await obtenerCitas(barbero_id, fecha);
 
    if (errorCitas) {
        throw new Error(errorCitas.message);
    }
 
    const inicioNueva = convertirMinutos(hora);
    const finNueva = inicioNueva + servicio.duracion;
 
    for (const cita of citasExistentes || []) {
        if (["Cancelada", "cancelada"].includes(cita.estado)) {
            continue;
        }
 
        const inicioExistente = convertirMinutos(cita.hora);
        const duracion =
            Number(cita.duracion_minutos) || Number(servicio.duracion);
        const finExistente = inicioExistente + duracion;
 
        if (
            inicioNueva < finExistente &&
            finNueva > inicioExistente
        ) {
            throw new Error(
                "El barbero ya tiene una cita en ese horario."
            );
        }
    }
 
    const { data, error: errorCrear } = await crearNuevaCita({
        cliente_id,
        barbero_id,
        servicio_id,
        fecha,
        hora,
        duracion_minutos: servicio.duracion,
        precio: servicio.precio,
        estado: estado || "Pendiente",
        observaciones: observaciones || null
    });
 
    if (errorCrear) {
        throw new Error(errorCrear.message);
    }
 
    return data;
};
 
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
 
export const obtenerCitasUsuario = async (usuario) => {
    const citas = await obtenerTodasLasCitas();
 
    if (usuario.rol === "Administrador") {
        return citas;
    }
 
    if (usuario.rol === "Barbero") {
        const { data: barbero } = await obtenerBarberoPorUsuario(
            usuario.id
        );
 
        if (!barbero) {
            return [];
        }
 
        return citas.filter(
            (cita) => Number(cita.barbero_id) === Number(barbero.id)
        );
    }
 
    return citas.filter(
        (cita) => Number(cita.cliente_id) === Number(usuario.id)
    );
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
 
const convertirMinutos = (hora) => {
    const [horas, minutos] = hora.split(":").map(Number);
    return horas * 60 + minutos;
};
