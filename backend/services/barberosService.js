import { obtenerBarberos, obtenerBarberoPorId, obtenerBarberoPorUsuario, crearBarbero, actualizarBarbero, eliminarBarbero } from "../models/barberosModel.js";
import supabase from "../config/supabase.js";

export const listarBarberos = async () => {

    const {
        data,
        error
    } =
        await obtenerBarberos();

    if (error) {

        throw new Error(
            error.message
        );

    }

    const { data: resenas } = await supabase.from("resenas").select("barbero_id,calificacion");
    const promedio = new Map();
    for (const r of resenas || []) {
        const id = Number(r.barbero_id); const item = promedio.get(id) || { total: 0, suma: 0 };
        item.total += 1; item.suma += Number(r.calificacion || 0); promedio.set(id, item);
    }
    return (data || []).map((barbero) => {
        const item = promedio.get(Number(barbero.id));
        return { ...barbero, calificacion_promedio: item ? Number((item.suma / item.total).toFixed(1)) : 0, total_resenas: item?.total || 0 };
    });

};

export const obtenerUno = async (
    id
) => {

    if (!id) {

        throw new Error(
            "El ID es obligatorio."
        );

    }

    const {
        data,
        error
    } =
        await obtenerBarberoPorId(id);

    if (
        error ||
        !data
    ) {

        throw new Error(
            "Barbero no encontrado."
        );

    }

    return data;

};

export const registrarBarbero = async (
    datos
) => {

    if (!datos.usuario_id) {

        throw new Error(
            "El usuario es obligatorio."
        );

    }

    const {
        data: existe
    } =
        await obtenerBarberoPorUsuario(
            datos.usuario_id
        );

    if (existe) {

        throw new Error(
            "Este usuario ya está registrado como barbero."
        );

    }

    const {
        data,
        error
    } =
        await crearBarbero(
            datos
        );

    if (error) {

        throw new Error(
            error.message
        );

    }

    return data;

};

export const editarBarbero = async (
    id,
    datos
) => {

    if (!id) {

        throw new Error(
            "El ID del barbero es obligatorio."
        );

    }

    const {
        data: existe
    } =
        await obtenerBarberoPorId(id);

    if (!existe) {

        throw new Error(
            "Barbero no encontrado."
        );

    }

    const {
        data,
        error
    } =
        await actualizarBarbero(
            id,
            datos
        );

    if (error) {

        throw new Error(
            error.message
        );

    }

    return data;

};

export const borrarBarbero = async (
    id
) => {

    if (!id) {

        throw new Error(
            "El ID del barbero es obligatorio."
        );

    }

    const {
        data: existe
    } =
        await obtenerBarberoPorId(id);

    if (!existe) {

        throw new Error(
            "Barbero no encontrado."
        );

    }

    const {
        error
    } =
        await eliminarBarbero(id);

    if (error) {

        throw new Error(
            error.message
        );

    }

    return true;

};