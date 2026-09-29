import {
    obtenerServicios,
    obtenerServiciosPorBarbero,
    obtenerServicioPorId,
    crearServicio,
    actualizarServicio,
    eliminarServicio,
} from "../models/serviciosModel.js";

import {
    obtenerBarberoPorUsuario,
} from "../models/barberosModel.js";

const obtenerBarberoId = async (usuario) => {
    if (!usuario?.id) {
        throw new Error(
            "No se encontró el usuario autenticado."
        );
    }

    const {
        data,
        error,
    } = await obtenerBarberoPorUsuario(
        usuario.id
    );

    if (error || !data) {
        throw new Error(
            "Perfil de barbero no encontrado."
        );
    }

    return data.id;
};

export const listarServicios = async () => {
    const {
        data,
        error,
    } = await obtenerServicios();

    if (error) {
        throw new Error(error.message);
    }

    return data || [];
};

export const listarMisServicios = async (
    usuario
) => {
    const barberoId =
        await obtenerBarberoId(usuario);

    const {
        data,
        error,
    } = await obtenerServiciosPorBarbero(
        barberoId
    );

    if (error) {
        throw new Error(error.message);
    }

    return data || [];
};

export const obtenerUno = async (id) => {
    if (!id) {
        throw new Error(
            "El ID del servicio es obligatorio."
        );
    }

    const {
        data,
        error,
    } = await obtenerServicioPorId(id);

    if (error) {
        throw new Error(error.message);
    }

    if (!data) {
        throw new Error(
            "Servicio no encontrado."
        );
    }

    return data;
};

export const registrarServicio = async (
    usuario,
    datos
) => {
    const {
        nombre,
        descripcion,
        precio,
        duracion,
        tiempo_descanso,
        imagen,
        estado,
    } = datos || {};

    if (
        !nombre ||
        precio === undefined ||
        !duracion
    ) {
        throw new Error(
            "Nombre, precio y duración son obligatorios."
        );
    }

    if (Number(precio) <= 0) {
        throw new Error(
            "El precio debe ser mayor que cero."
        );
    }

    if (Number(duracion) <= 0) {
        throw new Error(
            "La duración debe ser mayor que cero."
        );
    }

    let barbero_id =
        datos?.barbero_id || null;

    if (
        usuario?.rol === "Barbero" ||
        usuario?.rol === "barbero"
    ) {
        barbero_id =
            await obtenerBarberoId(usuario);
    }

    const {
        data,
        error,
    } = await crearServicio({
        nombre,
        descripcion: descripcion || null,
        precio: Number(precio),
        duracion: Number(duracion),
        tiempo_descanso:
            tiempo_descanso
                ? Number(tiempo_descanso)
                : 0,
        imagen: imagen || null,
        estado:
            estado !== undefined
                ? estado
                : true,
        barbero_id,
    });

    if (error) {
        throw new Error(error.message);
    }

    return data;
};

export const editarServicio = async (
    usuario,
    id,
    datos
) => {
    const existente =
        await obtenerUno(id);

    if (
        usuario?.rol === "Barbero" ||
        usuario?.rol === "barbero"
    ) {
        const barberoId =
            await obtenerBarberoId(usuario);

        if (
            Number(existente.barbero_id) !==
            Number(barberoId)
        ) {
            throw new Error(
                "No tienes permiso para modificar este servicio."
            );
        }
    }

    const campos = {
        ...datos,
    };

    delete campos.barbero_id;
    delete campos.id;

    if (campos.precio !== undefined) {
        campos.precio =
            Number(campos.precio);
    }

    if (campos.duracion !== undefined) {
        campos.duracion =
            Number(campos.duracion);
    }

    if (
        campos.tiempo_descanso !==
        undefined
    ) {
        campos.tiempo_descanso =
            Number(
                campos.tiempo_descanso
            );
    }

    const {
        data,
        error,
    } = await actualizarServicio(
        id,
        campos
    );

    if (error) {
        throw new Error(error.message);
    }

    return data;
};

export const borrarServicio = async (
    usuario,
    id
) => {
    const existente =
        await obtenerUno(id);

    if (
        usuario?.rol === "Barbero" ||
        usuario?.rol === "barbero"
    ) {
        const barberoId =
            await obtenerBarberoId(usuario);

        if (
            Number(existente.barbero_id) !==
            Number(barberoId)
        ) {
            throw new Error(
                "No tienes permiso para eliminar este servicio."
            );
        }
    }

    const {
        error,
    } = await eliminarServicio(id);

    if (error) {
        throw new Error(error.message);
    }

    return true;
};