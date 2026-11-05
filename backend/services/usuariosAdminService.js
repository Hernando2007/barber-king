import bcrypt from "bcrypt";
import { httpError } from "../utils/httpError.js";
import { ROL_ADMINISTRADOR, ROL_BARBERO, validarAdmin } from "../utils/usuariosRoles.js";
import {
    normalizarCamposBarbero,
    normalizarCamposUsuario,
} from "../utils/usuariosCampos.js";
import { normalizarPassword } from "../utils/usuariosNormalizacion.js";
import {
    existeCorreo,
    crearUsuario,
    eliminarUsuario,
    contarUsuariosPorRol,
} from "../models/usuariosModel.js";
import {
    crearBarbero,
    eliminarBarbero,
} from "../models/barberosModel.js";
import { buscarUsuario } from "./usuariosLecturaService.js";
import {
    contarDependencias,
    eliminarDependencias,
} from "./usuariosDependenciasService.js";

export const crearUsuarioAdmin = async (admin, datos) => {
    validarAdmin(admin);

    const campos = normalizarCamposUsuario(datos);
    const password = normalizarPassword(datos?.password, true);

    const esBarbero = Number(campos.rol_id) === ROL_BARBERO;
    const perfilBarbero = normalizarCamposBarbero(datos, {
        requerirEspecialidad: esBarbero,
    });

    if (await existeCorreo(campos.correo)) {
        throw httpError(409, "El correo ya está registrado.");
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const { data, error } = await crearUsuario({
        ...campos,
        password: passwordHash,
        estado: campos.estado !== false,
        email_verificado: true,
    });

    if (error) {
        if (error.code === "23505") {
            throw httpError(409, "El correo ya está registrado.");
        }

        throw new Error(error.message);
    }

    if (esBarbero) {
        const { error: errorBarbero } = await crearBarbero({
            ...perfilBarbero,
            usuario_id: data.id,
            disponible: perfilBarbero.disponible !== false,
            portafolio: perfilBarbero.portafolio || [],
        });

        if (errorBarbero) {
            await eliminarUsuario(data.id);
            throw new Error(
                `No fue posible crear el perfil de barbero: ${errorBarbero.message}`
            );
        }
    }

    return await buscarUsuario(data.id);
};

export const eliminarUsuarioAdmin = async (admin, id, { forzar = false } = {}) => {
    validarAdmin(admin);

    if (Number(admin.id) === Number(id)) {
        throw httpError(
            400,
            "No puedes eliminar tu propia cuenta."
        );
    }

    const existente = await buscarUsuario(id);

    if (Number(existente.rol_id) === ROL_ADMINISTRADOR) {
        const { count, error } = await contarUsuariosPorRol(
            ROL_ADMINISTRADOR
        );

        if (error) {
            throw new Error(error.message);
        }

        if ((count || 0) <= 1) {
            throw httpError(
                409,
                "No puedes eliminar al último administrador."
            );
        }
    }

    const barberoId = existente.barbero?.id || null;
    const resumen = await contarDependencias(id, barberoId);

    if (resumen.total > 0 && !forzar) {
        throw httpError(
            409,
            "El usuario tiene citas, reseñas, horarios o mensajes asociados. Confirma la operación para eliminarlos junto con la cuenta.",
            resumen
        );
    }

    if (resumen.total > 0) {
        await eliminarDependencias(id, barberoId);
    } else if (barberoId) {
        const { error } = await eliminarBarbero(barberoId);

        if (error) {
            throw new Error(error.message);
        }
    }

    const { error } = await eliminarUsuario(id);

    if (error) {
        throw new Error(error.message);
    }

    return {
        eliminado: true,
        resumen,
    };
};
