import bcrypt from "bcrypt";
import { buscarPorCorreo, crearUsuario } from "../models/authModel.js";
import { enviarBienvenida } from "./emailService.js";
import { verificarDiplomaBarbero } from "./verificacionBarberosService.js";
import { httpError } from "../utils/httpError.js";
import {
    CORREO_REGEX,
    ROL_BARBERO,
    ROL_CLIENTE,
    nombreRol,
    quitarDatosSensibles,
    texto,
} from "./authComun.js";
import { crearPerfilBarbero } from "./authBarberoRegistro.js";

export const registrarUsuario = async (datos) => {
    const {
        rol_id,
        nombres,
        apellidos,
        correo,
        telefono,
        fecha_nacimiento,
        password,
        especialidad,
        experiencia,
        descripcion,
        direccion,
        diploma_url,
        diploma_nombre,
        diploma_mimetype,
    } = datos || {};

    const rolId = Number(rol_id);
    const nombre = texto(nombres);
    const apellido = texto(apellidos);
    const email = texto(correo)?.toLowerCase();

    if (!nombre || !apellido || !email || !password) {
        throw httpError(
            400,
            "Todos los campos obligatorios deben ser enviados."
        );
    }

    if (![ROL_BARBERO, ROL_CLIENTE].includes(rolId)) {
        throw httpError(
            400,
            "El tipo de cuenta seleccionado no es válido."
        );
    }

    if (nombre.length < 2 || apellido.length < 2) {
        throw httpError(
            400,
            "Nombres y apellidos deben tener al menos 2 caracteres."
        );
    }

    if (!CORREO_REGEX.test(email)) {
        throw httpError(
            400,
            "Ingresa un correo electrónico válido."
        );
    }

    if (String(password).length < 6) {
        throw httpError(
            400,
            "La contraseña debe tener mínimo 6 caracteres."
        );
    }

    if (rolId === ROL_BARBERO && !texto(especialidad)) {
        throw httpError(
            400,
            "La especialidad es obligatoria para registrarse como barbero."
        );
    }

    const telefonoLimpio = texto(telefono);

    if (
        telefonoLimpio &&
        (telefonoLimpio.length < 7 || telefonoLimpio.length > 20)
    ) {
        throw httpError(
            400,
            "El teléfono debe tener entre 7 y 20 caracteres."
        );
    }

    const { data: existe } = await buscarPorCorreo(email);

    if (existe) {
        throw httpError(409, "El correo ya está registrado.");
    }

    let experienciaNumero = 0;

    if (experiencia !== undefined && experiencia !== null && experiencia !== "") {
        experienciaNumero = Number(experiencia);

        if (
            !Number.isFinite(experienciaNumero) ||
            experienciaNumero < 0 ||
            experienciaNumero > 70
        ) {
            throw httpError(
                400,
                "La experiencia debe ser un número entre 0 y 70."
            );
        }
    }

    if (rolId === ROL_BARBERO && !diploma_url) {
        throw httpError(
            400,
            "Adjunta tu diploma o certificado de barbería para crear la cuenta."
        );
    }

    if (rolId === ROL_BARBERO) {
        await verificarDiplomaBarbero({
            urlPublica: diploma_url,
            mimetype: diploma_mimetype,
            nombreOriginal: diploma_nombre,
            origen: "registro",
        });
    }

    const passwordHash = await bcrypt.hash(String(password), 10);

    const { data, error } = await crearUsuario({
        rol_id: rolId,
        nombres: nombre,
        apellidos: apellido,
        correo: email,
        telefono: telefonoLimpio,
        fecha_nacimiento: fecha_nacimiento || null,
        password: passwordHash,
        estado: true,
    });

    if (error) {
        if (error.code === "23505") {
            throw httpError(409, "El correo ya está registrado.");
        }

        throw new Error(error.message);
    }

    if (rolId === ROL_BARBERO) {
        await crearPerfilBarbero({
            usuarioId: data.id,
            especialidad,
            experiencia: experienciaNumero,
            descripcion,
            direccion,
            diplomaUrl: diploma_url,
            diplomaNombre: diploma_nombre,
        });
    }

    try {
        await enviarBienvenida(email, nombre);
    } catch (error) {
        console.error(
            "No fue posible enviar el correo de bienvenida:",
            error.message
        );
    }

    return {
        ...quitarDatosSensibles(data),
        rol_nombre: nombreRol(rolId),
    };
};
