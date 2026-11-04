import { crearBarbero } from "../models/barberosModel.js";
import { eliminarUsuario } from "../models/usuariosModel.js";
import {
    esColumnaEstadoFaltante,
    marcarBarberoVerificado,
    verificarDiplomaBarbero,
} from "./verificacionBarberosService.js";
import { texto } from "./authComun.js";

/// Ningún diploma bloquea un registro: la IA rechaza -> "rechazado", el
/// servicio falla o no hay documento -> "pendiente", y un administrador
/// puede corregirlo desde la bandeja de verificaciones.
export const resolverVerificacion = async ({
    diplomaUrl,
    diplomaNombre,
    diplomaMimetype,
    usuarioId = null,
}) => {
    if (!diplomaUrl) {
        return "pendiente";
    }

    try {
        await verificarDiplomaBarbero({
            urlPublica: diplomaUrl,
            mimetype: diplomaMimetype,
            nombreOriginal: diplomaNombre,
            origen: "registro",
            usuarioId,
        });

        return "aprobado";
    } catch (error) {
        if (error?.statusCode === 422) {
            return "rechazado";
        }

        console.warn("⚠️ Diploma sin verificar:", error?.message);

        return "pendiente";
    }
};

export const crearPerfilBarbero = async ({
    usuarioId,
    especialidad,
    experiencia,
    descripcion,
    direccion,
    diplomaUrl,
    diplomaNombre,
    verificacionEstado = "pendiente",
}) => {
    const portafolio = diplomaUrl
        ? [
            {
                tipo: "diploma",
                url: diplomaUrl,
                nombre: diplomaNombre || "diploma",
            },
        ]
        : [];

    let datosBarbero = {
        usuario_id: usuarioId,
        especialidad: texto(especialidad),
        experiencia: Math.round(experiencia),
        descripcion: texto(descripcion),
        direccion: texto(direccion),
        disponible: true,
        portafolio,
        verificacion_estado: verificacionEstado,
    };

    let { data: barberoCreado, error: barberoError } =
        await crearBarbero(datosBarbero);

    if (esColumnaEstadoFaltante(barberoError)) {
        const { verificacion_estado: _estado, ...compatibles } =
            datosBarbero;
        datosBarbero = compatibles;

        ({ data: barberoCreado, error: barberoError } =
            await crearBarbero(datosBarbero));
    }

    if (barberoError) {
        await eliminarUsuario(usuarioId);

        throw new Error(
            `No fue posible crear el perfil de barbero: ${barberoError.message}`
        );
    }

    if (barberoCreado?.id && verificacionEstado === "aprobado") {
        await marcarBarberoVerificado(barberoCreado.id);
    }
};
