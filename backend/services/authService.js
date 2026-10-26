import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import {
    buscarPorCorreo,
    crearUsuario,
    guardarTokenRecuperacion,
    actualizarPassword,
    limpiarToken,
    actualizarUltimoLogin,
} from "../models/authModel.js";
import { crearBarbero } from "../models/barberosModel.js";
import { eliminarUsuario } from "../models/usuariosModel.js";
import { enviarCodigoRecuperacion } from "./emailService.js";
import {
    verificarDiplomaBarbero,
    marcarBarberoVerificado,
    esColumnaEstadoFaltante,
} from "./verificacionBarberosService.js";
import { httpError } from "../utils/httpError.js";

const ROL_BARBERO = 2;
const ROL_CLIENTE = 3;

const CORREO_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const texto = (valor) => {
    if (valor === undefined || valor === null) {
        return null;
    }

    const limpio = String(valor).trim();
    return limpio.length ? limpio : null;
};

const nombreRol = (rolId) => {
    if (Number(rolId) === 1) {
        return "Administrador";
    }

    if (Number(rolId) === ROL_BARBERO) {
        return "Barbero";
    }

    return "Cliente";
};

const quitarDatosSensibles = (usuario) => {
    const {
        password: _password,
        token_recuperacion: _tokenRecuperacion,
        token_expiracion: _tokenExpiracion,
        ...seguro
    } = usuario;

    return seguro;
};

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
        const portafolio = [
            {
                tipo: "diploma",
                url: diploma_url,
                nombre: diploma_nombre || "diploma",
            },
        ];

        let datosBarbero = {
            usuario_id: data.id,
            especialidad: texto(especialidad),
            experiencia: Math.round(experienciaNumero),
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
            await eliminarUsuario(data.id);

            throw new Error(
                `No fue posible crear el perfil de barbero: ${barberoError.message}`
            );
        }

        if (barberoCreado?.id) {
            await marcarBarberoVerificado(barberoCreado.id);
        }
    }

    return {
        ...quitarDatosSensibles(data),
        rol_nombre: nombreRol(rolId),
    };
};

export const iniciarSesion = async ({ correo, password }) => {
    if (!correo || !password) {
        throw httpError(
            400,
            "Correo y contraseña son obligatorios."
        );
    }

    const email = String(correo).trim().toLowerCase();

    const { data: usuario } = await buscarPorCorreo(email);

    if (!usuario) {
        throw httpError(
            401,
            "Correo o contraseña incorrectos."
        );
    }

    if (usuario.estado === false) {
        throw httpError(
            403,
            "Tu cuenta está desactivada. Contacta a un administrador."
        );
    }

    if (!usuario.password) {
        throw httpError(
            400,
            "Esta cuenta está vinculada a Google. Inicia sesión con Google."
        );
    }

    const coincide = await bcrypt.compare(
        String(password),
        usuario.password
    );

    if (!coincide) {
        throw httpError(
            401,
            "Correo o contraseña incorrectos."
        );
    }

    await actualizarUltimoLogin(usuario.id);

    const rol_nombre = nombreRol(usuario.rol_id);

    const token = jwt.sign(
        {
            id: usuario.id,
            rol_id: usuario.rol_id,
            rol: rol_nombre,
        },
        process.env.JWT_SECRET,
        { expiresIn: "8h" }
    );

    return {
        token,
        usuario: {
            ...quitarDatosSensibles(usuario),
            rol_nombre,
        },
    };
};

export const solicitarRecuperacion = async (correo) => {
    const email = texto(correo)?.toLowerCase();

    if (!email) {
        throw httpError(
            400,
            "El correo electrónico es obligatorio."
        );
    }

    const { data: usuario } = await buscarPorCorreo(email);

    if (!usuario) {
        return true;
    }

    const codigo = Math.floor(
        100000 + Math.random() * 900000
    ).toString();

    const expiracion = new Date(
        Date.now() + 15 * 60 * 1000
    );

    const { error } = await guardarTokenRecuperacion(
        email,
        codigo,
        expiracion
    );

    if (error) {
        throw new Error(error.message);
    }

    await enviarCodigoRecuperacion(email, codigo);

    return true;
};

export const cambiarPassword = async (
    correo,
    codigo,
    password
) => {
    if (!correo || !codigo || !password) {
        throw httpError(
            400,
            "Todos los campos son obligatorios."
        );
    }

    if (String(password).length < 6) {
        throw httpError(
            400,
            "La contraseña debe tener mínimo 6 caracteres."
        );
    }

    const email = String(correo).trim().toLowerCase();

    const { data: usuario } = await buscarPorCorreo(email);

    if (!usuario) {
        throw httpError(400, "Código inválido.");
    }

    if (String(usuario.token_recuperacion) !== String(codigo)) {
        throw httpError(400, "Código inválido.");
    }

    if (
        !usuario.token_expiracion ||
        new Date(usuario.token_expiracion) < new Date()
    ) {
        throw httpError(400, "El código ha expirado.");
    }

    const passwordHash = await bcrypt.hash(String(password), 10);

    const { error } = await actualizarPassword(
        usuario.id,
        passwordHash
    );

    if (error) {
        throw new Error(error.message);
    }

    await limpiarToken(usuario.id);

    return true;
};
