import bcrypt from "bcrypt";
import { httpError } from "../utils/httpError.js";
import { ROL_ADMINISTRADOR } from "../utils/usuariosRoles.js";
import {
    obtenerUsuarioConPassword,
    eliminarUsuario,
    contarUsuariosPorRol,
} from "../models/usuariosModel.js";
import { eliminarBarbero } from "../models/barberosModel.js";
import { buscarUsuario } from "./usuariosLecturaService.js";
import {
    contarDependencias,
    eliminarDependencias,
} from "./usuariosDependenciasService.js";

const CONFIRMACION_TEXTO = "ELIMINAR";

/**
 * Elimina la cuenta del usuario autenticado y todo su historial.
 *
 * Google Play exige que el usuario pueda borrar su cuenta desde la app. Las
 * cuentas con contraseña local la confirman escribiéndola; las cuentas de
 * Google, que no tienen contraseña, confirman escribiendo ELIMINAR.
 */
export const eliminarMiCuenta = async (
    usuario,
    { password, confirmacion } = {}
) => {
    if (!usuario?.id) {
        throw httpError(401, "Usuario no autenticado.");
    }

    const actual = await obtenerUsuarioConPassword(usuario.id);

    if (!actual) {
        throw httpError(404, "Usuario no encontrado.");
    }

    if (actual.password) {
        if (!password) {
            throw httpError(
                400,
                "Debes ingresar tu contraseña para eliminar la cuenta."
            );
        }

        const coincide = await bcrypt.compare(
            String(password),
            actual.password
        );

        if (!coincide) {
            throw httpError(
                400,
                "La contraseña no es correcta."
            );
        }
    } else if (
        String(confirmacion || "")
            .trim()
            .toUpperCase() !== CONFIRMACION_TEXTO
    ) {
        throw httpError(
            400,
            `Escribe ${CONFIRMACION_TEXTO} para confirmar la eliminación.`
        );
    }

    const existente = await buscarUsuario(usuario.id);

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
                "No puedes eliminar tu cuenta porque eres el último administrador."
            );
        }
    }

    const barberoId = existente.barbero?.id || null;
    const resumen = await contarDependencias(usuario.id, barberoId);

    if (resumen.total > 0) {
        await eliminarDependencias(usuario.id, barberoId);
    } else if (barberoId) {
        const { error } = await eliminarBarbero(barberoId);

        if (error) {
            throw new Error(error.message);
        }
    }

    const { error } = await eliminarUsuario(usuario.id);

    if (error) {
        throw new Error(error.message);
    }

    return {
        eliminado: true,
        resumen,
    };
};
