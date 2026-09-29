import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import {
    buscarPorCorreo,
    crearUsuario,
    guardarTokenRecuperacion,
    actualizarPassword,
    limpiarToken,
    actualizarUltimoLogin
} from "../models/authModel.js";
import { crearBarbero } from "../models/barberosModel.js";
import { enviarCodigoRecuperacion } from "./emailService.js";
 
export const registrarUsuario = async (usuario) => {
    const {
        rol_id,
        nombres,
        apellidos,
        correo,
        telefono,
        fecha_nacimiento,
        password,
        especialidad,
        diploma_url,
        diploma_nombre
    } = usuario;
 
    if (
        !rol_id ||
        !nombres ||
        !apellidos ||
        !correo ||
        !password
    ) {
        throw new Error(
            "Todos los campos obligatorios deben ser enviados."
        );
    }
 
    if (![2, 3].includes(Number(rol_id))) {
        throw new Error(
            "El tipo de cuenta seleccionado no es válido."
        );
    }
 
    if (Number(rol_id) === 2 && !especialidad?.trim()) {
        throw new Error(
            "La especialidad es obligatoria para registrarse como barbero."
        );
    }
 
    const { data: existe } = await buscarPorCorreo(
        correo.trim().toLowerCase()
    );
 
    if (existe) {
        throw new Error("El correo ya está registrado.");
    }
 
    const passwordHash = await bcrypt.hash(password, 10);
 
    const { data, error } = await crearUsuario({
        rol_id: Number(rol_id),
        nombres: nombres.trim(),
        apellidos: apellidos.trim(),
        correo: correo.trim().toLowerCase(),
        telefono: telefono?.trim() || null,
        fecha_nacimiento: fecha_nacimiento || null,
        password: passwordHash
    });
 
    if (error) {
        throw new Error(error.message);
    }
 
    if (Number(rol_id) === 2) {
        const { error: barberoError } = await crearBarbero({
            usuario_id: data.id,
            especialidad: especialidad.trim(),
            diploma_url: diploma_url || null,
            diploma_nombre: diploma_nombre || null,
            activo: true,
            verificacion_estado: diploma_url
                ? "pendiente"
                : "pendiente"
        });
 
        if (barberoError) {
            throw new Error(
                `Usuario creado, pero no fue posible crear el perfil de barbero: ${barberoError.message}`
            );
        }
    }
 
    const {
        password: _password,
        token_recuperacion: _tokenRecuperacion,
        token_expiracion: _tokenExpiracion,
        ...usuarioSeguro
    } = data;
 
    return usuarioSeguro;
};
 
export const iniciarSesion = async ({ correo, password }) => {
    if (!correo || !password) {
        throw new Error(
            "Correo y contraseña son obligatorios."
        );
    }
 
    const { data: usuario } = await buscarPorCorreo(
        correo.trim().toLowerCase()
    );
 
    if (!usuario) {
        throw new Error(
            "Correo o contraseña incorrectos."
        );
    }
 
    const coincide = await bcrypt.compare(
        password,
        usuario.password
    );
 
    if (!coincide) {
        throw new Error(
            "Correo o contraseña incorrectos."
        );
    }
 
    await actualizarUltimoLogin(usuario.id);
 
    const rol_nombre =
        Number(usuario.rol_id) === 1
            ? "Administrador"
            : Number(usuario.rol_id) === 2
                ? "Barbero"
                : "Cliente";
 
    const token = jwt.sign(
        {
            id: usuario.id,
            rol_id: usuario.rol_id,
            rol: rol_nombre
        },
        process.env.JWT_SECRET,
        { expiresIn: "8h" }
    );
 
    const {
        password: _password,
        token_recuperacion: _tokenRecuperacion,
        token_expiracion: _tokenExpiracion,
        ...usuarioSeguro
    } = usuario;
 
    return {
        token,
        usuario: {
            ...usuarioSeguro,
            rol_nombre
        }
    };
};
 
export const solicitarRecuperacion = async (correo) => {
    const { data: usuario } = await buscarPorCorreo(correo);
 
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
        correo,
        codigo,
        expiracion
    );
 
    if (error) {
        throw new Error(error.message);
    }
 
    await enviarCodigoRecuperacion(correo, codigo);
    return true;
};
 
export const cambiarPassword = async (
    correo,
    codigo,
    password
) => {
    if (!correo || !codigo || !password) {
        throw new Error(
            "Todos los campos son obligatorios."
        );
    }
 
    const { data: usuario } = await buscarPorCorreo(correo);
 
    if (!usuario) {
        throw new Error("Código inválido.");
    }
 
    if (usuario.token_recuperacion !== codigo) {
        throw new Error("Código inválido.");
    }
 
    if (
        !usuario.token_expiracion ||
        new Date(usuario.token_expiracion) < new Date()
    ) {
        throw new Error("El código ha expirado.");
    }
 
    const passwordHash = await bcrypt.hash(password, 10);
 
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
