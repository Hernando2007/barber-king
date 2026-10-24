import {
    obtenerBarberos,
    obtenerBarberoPorId,
    obtenerBarberoPorUsuario,
    crearBarbero,
    actualizarBarbero,
    eliminarBarbero,
} from "../models/barberosModel.js";
import { obtenerUsuarioPorId } from "../models/usuariosModel.js";
import { httpError } from "../utils/httpError.js";

export const asegurarPerfilBarbero = async (usuarioId) => {
    const { data: existente, error } =
        await obtenerBarberoPorUsuario(usuarioId);

    if (error) {
        throw new Error(error.message);
    }

    if (existente) {
        return existente;
    }

    const { data: usuario, error: errorUsuario } =
        await obtenerUsuarioPorId(usuarioId);

    if (errorUsuario) {
        throw new Error(errorUsuario.message);
    }

    if (!usuario) {
        throw httpError(404, "Usuario no encontrado.");
    }

    if (Number(usuario.rol_id) !== 2) {
        throw httpError(
            403,
            "El usuario no tiene rol de barbero."
        );
    }

    const { data, error: errorCrear } = await crearBarbero({
        usuario_id: Number(usuarioId),
        especialidad: "Barbero profesional",
        experiencia: 0,
        descripcion: null,
        disponible: true,
        portafolio: [],
    });

    if (errorCrear) {
        throw new Error(errorCrear.message);
    }

    return data;
};

const normalizar = (datos, { parcial = true } = {}) => {
    const entrada = datos || {};
    const campos = {};

    if (!parcial || entrada.especialidad !== undefined) {
        const especialidad = String(
            entrada.especialidad || ""
        ).trim();

        if (!especialidad) {
            throw httpError(
                400,
                "La especialidad es obligatoria."
            );
        }

        campos.especialidad = especialidad;
    }

    if (entrada.experiencia !== undefined) {
        const experiencia = Number(entrada.experiencia);

        if (
            !Number.isFinite(experiencia) ||
            experiencia < 0 ||
            experiencia > 70
        ) {
            throw httpError(
                400,
                "La experiencia debe ser un número entre 0 y 70."
            );
        }

        campos.experiencia = Math.round(experiencia);
    }

    for (const campo of ["descripcion", "direccion", "foto_trabajo"]) {
        if (entrada[campo] !== undefined) {
            const valor = String(entrada[campo] ?? "").trim();
            campos[campo] = valor.length ? valor : null;
        }
    }

    if (entrada.disponible !== undefined) {
        campos.disponible = Boolean(entrada.disponible);
    }

    if (entrada.portafolio !== undefined) {
        if (!Array.isArray(entrada.portafolio)) {
            throw httpError(
                400,
                "El portafolio debe ser una lista."
            );
        }

        campos.portafolio = entrada.portafolio;
    }

    return campos;
};

export const listarBarberos = async () => {
    const { data, error } = await obtenerBarberos();

    if (error) {
        throw new Error(error.message);
    }

    return data || [];
};

export const obtenerUno = async (id) => {
    if (!id) {
        throw httpError(400, "El ID es obligatorio.");
    }

    const { data, error } = await obtenerBarberoPorId(id);

    if (error) {
        throw new Error(error.message);
    }

    if (!data) {
        throw httpError(404, "Barbero no encontrado.");
    }

    return data;
};

export const registrarBarbero = async (datos) => {
    const usuarioId = Number(datos?.usuario_id);

    if (!usuarioId) {
        throw httpError(400, "El usuario es obligatorio.");
    }

    const { data: existe } = await obtenerBarberoPorUsuario(usuarioId);

    if (existe) {
        throw httpError(
            409,
            "Este usuario ya está registrado como barbero."
        );
    }

    const campos = normalizar(datos, { parcial: false });

    const { data, error } = await crearBarbero({
        ...campos,
        usuario_id: usuarioId,
        disponible: campos.disponible !== false,
        portafolio: campos.portafolio || [],
    });

    if (error) {
        throw new Error(error.message);
    }

    return data;
};

export const editarBarbero = async (id, datos) => {
    if (!id) {
        throw httpError(
            400,
            "El ID del barbero es obligatorio."
        );
    }

    const { data: existe } = await obtenerBarberoPorId(id);

    if (!existe) {
        throw httpError(404, "Barbero no encontrado.");
    }

    const campos = normalizar(datos);

    if (!Object.keys(campos).length) {
        throw httpError(
            400,
            "No hay datos válidos para actualizar."
        );
    }

    const { data, error } = await actualizarBarbero(id, campos);

    if (error) {
        throw new Error(error.message);
    }

    return data;
};

export const editarPerfilBarbero = async (usuarioId, datos) => {
    const { data: barbero } = await obtenerBarberoPorUsuario(usuarioId);

    if (!barbero) {
        throw httpError(404, "Perfil de barbero no encontrado.");
    }

    const campos = normalizar(datos);

    if (!Object.keys(campos).length) {
        throw httpError(
            400,
            "No hay datos válidos para actualizar."
        );
    }

    const { data, error } = await actualizarBarbero(
        barbero.id,
        campos
    );

    if (error) {
        throw new Error(error.message);
    }

    return data;
};

export const borrarBarbero = async (id) => {
    if (!id) {
        throw httpError(
            400,
            "El ID del barbero es obligatorio."
        );
    }

    const { data: existe } = await obtenerBarberoPorId(id);

    if (!existe) {
        throw httpError(404, "Barbero no encontrado.");
    }

    const { error } = await eliminarBarbero(id);

    if (error) {
        throw new Error(error.message);
    }

    return true;
};
