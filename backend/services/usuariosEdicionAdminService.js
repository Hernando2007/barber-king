import bcrypt from "bcrypt";
import { httpError } from "../utils/httpError.js";
import {
    ROL_ADMINISTRADOR,
    ROL_BARBERO,
    validarAdmin,
} from "../utils/usuariosRoles.js";
import {
    normalizarCamposBarbero,
    normalizarCamposUsuario,
} from "../utils/usuariosCampos.js";
import { normalizarPassword } from "../utils/usuariosNormalizacion.js";
import {
    existeCorreo,
    actualizarUsuario,
    contarUsuariosPorRol,
} from "../models/usuariosModel.js";
import {
    crearBarbero,
    actualizarBarbero,
    eliminarBarbero,
} from "../models/barberosModel.js";
import { buscarUsuario } from "./usuariosLecturaService.js";
import {
    contarDependencias,
    eliminarDependencias,
} from "./usuariosDependenciasService.js";

/** Editar otro usuario desde el panel: incluye cambiar de rol y su perfil. */
export const actualizarUsuarioAdmin = async (admin, id, datos) => {
    validarAdmin(admin);

    const existente = await buscarUsuario(id);
    const campos = normalizarCamposUsuario(datos, { parcial: true });

    const esMismoUsuario = Number(admin.id) === Number(id);

    if (esMismoUsuario) {
        if (campos.estado === false) {
            throw httpError(
                400,
                "No puedes desactivar tu propia cuenta."
            );
        }

        if (
            campos.rol_id !== undefined &&
            Number(campos.rol_id) !== ROL_ADMINISTRADOR
        ) {
            throw httpError(
                400,
                "No puedes cambiar tu propio rol de administrador."
            );
        }
    }

    if (campos.correo) {
        if (await existeCorreo(campos.correo, id)) {
            throw httpError(409, "El correo ya está registrado.");
        }
    }

    const nuevoRol = Number(campos.rol_id ?? existente.rol_id);
    const rolAnterior = Number(existente.rol_id);

    if (
        rolAnterior === ROL_ADMINISTRADOR &&
        nuevoRol !== ROL_ADMINISTRADOR
    ) {
        const { count, error } = await contarUsuariosPorRol(
            ROL_ADMINISTRADOR
        );

        if (error) {
            throw new Error(error.message);
        }

        if ((count || 0) <= 1) {
            throw httpError(
                409,
                "Debe existir al menos un administrador activo."
            );
        }
    }

    const barberoExistente = existente.barbero;
    const esBarbero = nuevoRol === ROL_BARBERO;
    const perfilBarbero = normalizarCamposBarbero(datos);

    if (esBarbero && !barberoExistente && !perfilBarbero.especialidad) {
        throw httpError(
            400,
            "La especialidad es obligatoria para un barbero."
        );
    }

    if (!esBarbero && barberoExistente) {
        const resumen = await contarDependencias(
            existente.id,
            barberoExistente.id
        );

        if (resumen.total > 0 && !datos?.forzar) {
            throw httpError(
                409,
                "El barbero tiene citas, reseñas u horarios asociados. Confirma la operación para eliminarlos.",
                resumen
            );
        }

        if (resumen.total > 0) {
            await eliminarDependencias(
                existente.id,
                barberoExistente.id
            );
        } else {
            const { error: errorBarbero } = await eliminarBarbero(
                barberoExistente.id
            );

            if (errorBarbero) {
                throw new Error(errorBarbero.message);
            }
        }
    }

    const password = normalizarPassword(datos?.password, false);

    const cambios = { ...campos };

    if (password) {
        cambios.password = await bcrypt.hash(password, 10);
    }

    if (Object.keys(cambios).length) {
        const { error } = await actualizarUsuario(id, cambios);

        if (error) {
            if (error.code === "23505") {
                throw httpError(
                    409,
                    "El correo ya está registrado."
                );
            }

            throw new Error(error.message);
        }
    }

    if (esBarbero) {
        if (barberoExistente) {
            if (Object.keys(perfilBarbero).length) {
                const { error } = await actualizarBarbero(
                    barberoExistente.id,
                    perfilBarbero
                );

                if (error) {
                    throw new Error(error.message);
                }
            }
        } else {
            const { error } = await crearBarbero({
                ...perfilBarbero,
                usuario_id: existente.id,
                disponible: perfilBarbero.disponible !== false,
                portafolio: perfilBarbero.portafolio || [],
            });

            if (error) {
                throw new Error(error.message);
            }
        }
    }

    return await buscarUsuario(id);
};
