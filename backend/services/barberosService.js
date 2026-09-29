import {
    obtenerBarberos,
    obtenerBarberoPorId,
    obtenerBarberoPorUsuario,
    crearBarbero,
    actualizarBarbero,
    eliminarBarbero
} from "../models/barberosModel.js";
 
export const listarBarberos = async () => {
    const { data, error } = await obtenerBarberos();
 
    if (error) {
        throw new Error(error.message);
    }
 
    return data || [];
};
 
export const obtenerUno = async (id) => {
    if (!id) {
        throw new Error("El ID es obligatorio.");
    }
 
    const { data, error } = await obtenerBarberoPorId(id);
 
    if (error || !data) {
        throw new Error("Barbero no encontrado.");
    }
 
    return data;
};
 
export const registrarBarbero = async (datos) => {
    if (!datos.usuario_id) {
        throw new Error("El usuario es obligatorio.");
    }
 
    if (!datos.especialidad?.trim()) {
        throw new Error("La especialidad es obligatoria.");
    }
 
    const { data: existe } = await obtenerBarberoPorUsuario(
        datos.usuario_id
    );
 
    if (existe) {
        throw new Error(
            "Este usuario ya está registrado como barbero."
        );
    }
 
    const { data, error } = await crearBarbero({
        ...datos,
        especialidad: datos.especialidad.trim()
    });
 
    if (error) {
        throw new Error(error.message);
    }
 
    return data;
};
 
export const editarBarbero = async (id, datos) => {
    if (!id) {
        throw new Error("El ID del barbero es obligatorio.");
    }
 
    const { data: existe } = await obtenerBarberoPorId(id);
 
    if (!existe) {
        throw new Error("Barbero no encontrado.");
    }
 
    const { data, error } = await actualizarBarbero(id, datos);
 
    if (error) {
        throw new Error(error.message);
    }
 
    return data;
};
 
export const editarPerfilBarbero = async (usuarioId, datos) => {
    const { data: barbero } = await obtenerBarberoPorUsuario(usuarioId);
 
    if (!barbero) {
        throw new Error("Perfil de barbero no encontrado.");
    }
 
    const permitidos = [
        "especialidad",
        "diploma_url",
        "diploma_nombre",
        "foto",
        "activo"
    ];
 
    const cambios = {};
 
    for (const campo of permitidos) {
        if (datos[campo] !== undefined) {
            cambios[campo] = datos[campo];
        }
    }
 
    if (
        cambios.especialidad !== undefined &&
        !String(cambios.especialidad).trim()
    ) {
        throw new Error("La especialidad no puede estar vacía.");
    }
 
    const { data, error } = await actualizarBarbero(
        barbero.id,
        cambios
    );
 
    if (error) {
        throw new Error(error.message);
    }
 
    return data;
};
 
export const borrarBarbero = async (id) => {
    if (!id) {
        throw new Error("El ID del barbero es obligatorio.");
    }
 
    const { data: existe } = await obtenerBarberoPorId(id);
 
    if (!existe) {
        throw new Error("Barbero no encontrado.");
    }
 
    const { error } = await eliminarBarbero(id);
 
    if (error) {
        throw new Error(error.message);
    }
 
    return true;
};
