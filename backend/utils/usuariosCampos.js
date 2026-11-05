import { httpError } from "./httpError.js";
import { ROLES_VALIDOS } from "./usuariosRoles.js";
import { normalizarFecha, texto } from "./usuariosNormalizacion.js";

const CORREO_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export const normalizarCamposUsuario = (
    datos,
    { parcial = false } = {}
) => {
    const entrada = datos || {};
    const campos = {};

    if (!parcial || entrada.nombres !== undefined) {
        const nombres = texto(entrada.nombres);

        if (!nombres || nombres.length < 2) {
            throw httpError(
                400,
                "El nombre debe tener al menos 2 caracteres."
            );
        }

        campos.nombres = nombres;
    }

    if (!parcial || entrada.apellidos !== undefined) {
        const apellidos = texto(entrada.apellidos);

        if (!apellidos || apellidos.length < 2) {
            throw httpError(
                400,
                "Los apellidos deben tener al menos 2 caracteres."
            );
        }

        campos.apellidos = apellidos;
    }

    if (!parcial || entrada.correo !== undefined) {
        const correo = texto(entrada.correo)?.toLowerCase();

        if (!correo || !CORREO_REGEX.test(correo)) {
            throw httpError(
                400,
                "Ingresa un correo electrónico válido."
            );
        }

        campos.correo = correo;
    }

    if (entrada.telefono !== undefined) {
        const telefono = texto(entrada.telefono);

        if (telefono && (telefono.length < 7 || telefono.length > 20)) {
            throw httpError(
                400,
                "El teléfono debe tener entre 7 y 20 caracteres."
            );
        }

        campos.telefono = telefono;
    }

    if (entrada.fecha_nacimiento !== undefined) {
        campos.fecha_nacimiento = normalizarFecha(
            entrada.fecha_nacimiento
        );
    }

    if (entrada.rol_id !== undefined) {
        const rolId = Number(entrada.rol_id);

        if (!ROLES_VALIDOS.includes(rolId)) {
            throw httpError(
                400,
                "El rol seleccionado no es válido."
            );
        }

        campos.rol_id = rolId;
    }

    if (entrada.estado !== undefined) {
        campos.estado = Boolean(entrada.estado);
    }

    if (entrada.foto !== undefined) {
        campos.foto = texto(entrada.foto);
    }

    if (entrada.vip !== undefined) {
        campos.vip = Boolean(entrada.vip);
    }

    return campos;
};

/** Lo que el administrador o el propio barbero pueden cambiar del perfil. */
export const normalizarCamposBarbero = (
    datos,
    { requerirEspecialidad = false } = {}
) => {
    const entrada = datos || {};
    const campos = {};

    if (
        entrada.especialidad !== undefined ||
        requerirEspecialidad
    ) {
        const especialidad = texto(entrada.especialidad);

        if (!especialidad) {
            throw httpError(
                400,
                "La especialidad es obligatoria para un barbero."
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

    if (entrada.descripcion !== undefined) {
        campos.descripcion = texto(entrada.descripcion);
    }

    if (entrada.direccion !== undefined) {
        campos.direccion = texto(entrada.direccion);
    }

    if (entrada.foto_trabajo !== undefined) {
        campos.foto_trabajo = texto(entrada.foto_trabajo);
    }

    for (const campo of ["ciudad", "zona"]) {
        if (entrada[campo] !== undefined) {
            campos[campo] = texto(entrada[campo])?.slice(0, 120) || null;
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
