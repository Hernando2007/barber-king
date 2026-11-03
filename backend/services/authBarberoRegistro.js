import { crearBarbero } from "../models/barberosModel.js";
import { eliminarUsuario } from "../models/usuariosModel.js";
import {
    esColumnaEstadoFaltante,
    marcarBarberoVerificado,
} from "./verificacionBarberosService.js";
import { texto } from "./authComun.js";

export const crearPerfilBarbero = async ({
    usuarioId,
    especialidad,
    experiencia,
    descripcion,
    direccion,
    diplomaUrl,
    diplomaNombre,
}) => {
    const portafolio = [
        {
            tipo: "diploma",
            url: diplomaUrl,
            nombre: diplomaNombre || "diploma",
        },
    ];

    let datosBarbero = {
        usuario_id: usuarioId,
        especialidad: texto(especialidad),
        experiencia: Math.round(experiencia),
        descripcion: texto(descripcion),
        direccion: texto(direccion),
        disponible: true,
        portafolio,
        verificacion_estado: "aprobado",
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

    if (barberoCreado?.id) {
        await marcarBarberoVerificado(barberoCreado.id);
    }
};
