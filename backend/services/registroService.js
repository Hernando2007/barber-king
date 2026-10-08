import bcrypt from "bcrypt";
import supabase from "../config/supabase.js";
import { buscarPorCorreo, crearUsuario } from "../models/authModel.js";
import { crearBarbero } from "../models/barberosModel.js";

// 2 = Barbero, 3 = Cliente. El administrador NO se puede crear desde la app.
const ROLES_PERMITIDOS = [2, 3];
const REGEX_CORREO = /^[^@\s]+@[^@\s]+\.[^@\s]{2,}$/;

const texto = (valor) => String(valor ?? "").trim();

export const registrarUsuario = async (body, files = {}) => {
    const rol_id = Number(body.rol_id);
    const nombres = texto(body.nombres);
    const apellidos = texto(body.apellidos);
    const correo = texto(body.correo).toLowerCase();
    const password = String(body.password ?? "");

    if (!rol_id || !nombres || !apellidos || !correo || !password) {
        throw new Error("Todos los campos obligatorios deben ser enviados.");
    }

    if (!ROLES_PERMITIDOS.includes(rol_id)) {
        throw new Error("Tipo de cuenta no permitido.");
    }

    if (!REGEX_CORREO.test(correo)) {
        throw new Error("El correo electrónico no es válido.");
    }

    if (password.length < 6) {
        throw new Error("La contraseña debe tener mínimo 6 caracteres.");
    }

    const { data: existe } = await buscarPorCorreo(correo);

    if (existe) {
        throw new Error("El correo ya está registrado.");
    }

    const { data: usuario, error } = await crearUsuario({
        rol_id,
        nombres,
        apellidos,
        correo,
        telefono: texto(body.telefono) || null,
        fecha_nacimiento: texto(body.fecha_nacimiento) || null,
        password: await bcrypt.hash(password, 10)
    });

    if (error) {
        throw new Error(error.message);
    }

    if (rol_id === 2) {
        const diploma = Array.isArray(files.diploma) ? files.diploma[0] : null;
        const fotos = Array.isArray(files.portafolio) ? files.portafolio : [];
        const experiencia = Math.min(Math.max(parseInt(body.experiencia, 10) || 0, 0), 60);

        const { error: errorBarbero } = await crearBarbero({
            usuario_id: usuario.id,
            especialidad: texto(body.especialidad) || "Barbería general",
            experiencia,
            direccion: texto(body.direccion) || null,
            portafolio: fotos.map((foto) => foto.path || foto.secure_url),
            diploma_url: diploma?.path || diploma?.secure_url || null,
            diploma_nombre: diploma?.originalname || null,
            verificacion_estado: diploma ? "pendiente" : "sin_documento",
            activo: true
        });

        if (errorBarbero) {
            // Evita dejar un usuario huérfano que bloquee el correo.
            await supabase.from("usuarios").delete().eq("id", usuario.id);
            throw new Error(errorBarbero.message);
        }
    }

    // Nunca devolver el hash de la contraseña al cliente.
    return {
        id: usuario.id,
        rol_id: usuario.rol_id,
        nombres: usuario.nombres,
        apellidos: usuario.apellidos,
        correo: usuario.correo
    };
};