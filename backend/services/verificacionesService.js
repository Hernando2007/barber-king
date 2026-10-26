import { listarVerificaciones } from "../models/verificacionesModel.js";

export const obtenerVerificaciones = async ({ limite, desde }) => {
    const tope = Math.min(Math.max(Number(limite) || 50, 1), 200);
    const inicio = Math.max(Number(desde) || 0, 0);

    const { data, error } = await listarVerificaciones({
        limite: tope,
        desde: inicio,
    });

    if (error) {
        throw new Error(error.message);
    }

    return data;
};
