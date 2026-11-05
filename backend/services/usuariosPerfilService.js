import bcrypt from "bcrypt";
import { httpError } from "../utils/httpError.js";
import {
    normalizarCamposBarbero,
    normalizarCamposUsuario,
} from "../utils/usuariosCampos.js";
import { normalizarPassword } from "../utils/usuariosNormalizacion.js";
import {
    obtenerUsuarioConPassword,
    actualizarUsuario,
} from "../models/usuariosModel.js";
import {
    obtenerBarberoPorUsuario,
    actualizarBarbero,
} from "../models/barberosModel.js";
import { subirImagenCloudinary } from "./cloudinaryService.js";
import { obtenerPerfilCompleto } from "./usuariosLecturaService.js";

/** Lo que cada usuario puede cambiar desde su propio perfil. */
export const actualizarMiPerfil = async (usuario, datos) => {
    if (!usuario?.id) {
        throw httpError(401, "Usuario no autenticado.");
    }

    const actual = await obtenerUsuarioConPassword(usuario.id);

    if (!actual) {
        throw httpError(404, "Usuario no encontrado.");
    }

    const campos = normalizarCamposUsuario(
        {
            nombres: datos?.nombres,
            apellidos: datos?.apellidos,
            telefono: datos?.telefono,
            fecha_nacimiento: datos?.fecha_nacimiento,
        },
        { parcial: true }
    );

    const passwordNueva = normalizarPassword(
        datos?.password_nueva,
        false
    );

    if (passwordNueva) {
        if (!datos?.password_actual) {
            throw httpError(
                400,
                "Debes ingresar tu contraseña actual."
            );
        }

        if (!actual.password) {
            throw httpError(
                400,
                "Tu cuenta no tiene contraseña local. Inicia sesión con Google."
            );
        }

        const coincide = await bcrypt.compare(
            String(datos.password_actual),
            actual.password
        );

        if (!coincide) {
            throw httpError(
                400,
                "La contraseña actual no es correcta."
            );
        }

        campos.password = await bcrypt.hash(passwordNueva, 10);
    }

    const { data: barbero } = await obtenerBarberoPorUsuario(usuario.id);
    const perfilBarbero = barbero
        ? normalizarCamposBarbero(datos)
        : {};

    if (
        !Object.keys(campos).length &&
        !Object.keys(perfilBarbero).length
    ) {
        throw httpError(
            400,
            "No hay datos válidos para actualizar."
        );
    }

    if (Object.keys(campos).length) {
        const { error } = await actualizarUsuario(
            usuario.id,
            campos
        );

        if (error) {
            throw new Error(error.message);
        }
    }

    if (Object.keys(perfilBarbero).length) {
        const { error } = await actualizarBarbero(
            barbero.id,
            perfilBarbero
        );

        if (error) {
            throw new Error(error.message);
        }
    }

    return await obtenerPerfilCompleto(usuario.id);
};

export const guardarFotoPerfil = async (usuario, archivo) => {
    if (!usuario?.id) {
        throw httpError(401, "Usuario no autenticado.");
    }

    if (!archivo) {
        throw httpError(400, "Selecciona una imagen.");
    }

    const { url: foto } = await subirImagenCloudinary(
        archivo,
        "barber-king/perfil"
    );

    const { error } = await actualizarUsuario(usuario.id, { foto });

    if (error) {
        throw new Error(error.message);
    }

    return { foto };
};
