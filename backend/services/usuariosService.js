import bcrypt from "bcrypt";
import { httpError } from "../utils/httpError.js";
import {
    obtenerUsuarios,
    obtenerUsuarioPorId,
    obtenerUsuarioConPassword,
    existeCorreo,
    crearUsuario,
    actualizarUsuario,
    eliminarUsuario,
    contarUsuariosPorRol,
    contarCitasCliente,
    contarCitasBarbero,
    contarResenasCliente,
    contarResenasBarbero,
    contarMensajesUsuario,
    contarHorariosBarbero,
    obtenerIdsCitasDeUsuario,
    eliminarResenasDeUsuario,
    eliminarCitasDeUsuario,
    eliminarMensajesDeUsuario,
    eliminarHorariosDeBarbero,
} from "../models/usuariosModel.js";
import {
    obtenerBarberoPorUsuario,
    crearBarbero,
    actualizarBarbero,
    eliminarBarbero,
} from "../models/barberosModel.js";

const ROL_ADMINISTRADOR = 1;
const ROL_BARBERO = 2;
const ROL_CLIENTE = 3;

const ROLES_VALIDOS = [
    ROL_ADMINISTRADOR,
    ROL_BARBERO,
    ROL_CLIENTE,
];

const NOMBRE_ROL = {
    [ROL_ADMINISTRADOR]: "Administrador",
    [ROL_BARBERO]: "Barbero",
    [ROL_CLIENTE]: "Cliente",
};

const CORREO_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const esAdministrador = (usuario) => {
    const rol = String(usuario?.rol || "").toLowerCase();

    return (
        Number(usuario?.rol_id) === ROL_ADMINISTRADOR ||
        rol === "administrador"
    );
};

export const validarAdmin = (usuario) => {
    if (!usuario) {
        throw httpError(401, "Usuario no autenticado.");
    }

    if (!esAdministrador(usuario)) {
        throw httpError(
            403,
            "No tienes permisos para realizar esta acción."
        );
    }
};

const rolPorId = (rolId) =>
    NOMBRE_ROL[Number(rolId)] || null;

const serializarUsuario = (registro) => {
    if (!registro) {
        return null;
    }

    const { roles, barberos, ...resto } = registro;

    let barbero = null;

    if (Array.isArray(barberos)) {
        barbero = barberos[0] || null;
    } else if (barberos && typeof barberos === "object") {
        barbero = barberos;
    }

    if (barbero) {
        const portafolio = Array.isArray(barbero.portafolio)
            ? barbero.portafolio
            : [];

        const diploma = portafolio.find(
            (item) => item?.tipo === "diploma"
        );

        barbero = {
            ...barbero,
            portafolio,
            diploma_url: diploma?.url || null,
            diploma_nombre: diploma?.nombre || null,
        };
    }

    return {
        ...resto,
        rol:
            roles?.nombre ||
            rolPorId(resto.rol_id) ||
            null,
        barbero,
    };
};

const texto = (valor) => {
    if (valor === undefined || valor === null) {
        return null;
    }

    const limpio = String(valor).trim();
    return limpio.length ? limpio : null;
};

const normalizarFecha = (valor) => {
    if (valor === undefined) {
        return undefined;
    }

    if (valor === null || valor === "") {
        return null;
    }

    const fecha = new Date(valor);

    if (Number.isNaN(fecha.getTime())) {
        throw httpError(400, "La fecha de nacimiento no es válida.");
    }

    return fecha.toISOString().slice(0, 10);
};

const normalizarCamposUsuario = (datos, { parcial = false } = {}) => {
    const entrada = datos || {};
    const campos = {};

    if (!parcial || entrada.nombres !== undefined) {
        const nombres = texto(entrada.nombres);

        if (!nombres || nombres.length < 2) {
            throw httpError(
                400,
                "El nombre debe tener al menos 2 caracteres."
            );
        }

        campos.nombres = nombres;
    }

    if (!parcial || entrada.apellidos !== undefined) {
        const apellidos = texto(entrada.apellidos);

        if (!apellidos || apellidos.length < 2) {
            throw httpError(
                400,
                "Los apellidos deben tener al menos 2 caracteres."
            );
        }

        campos.apellidos = apellidos;
    }

    if (!parcial || entrada.correo !== undefined) {
        const correo = texto(entrada.correo)?.toLowerCase();

        if (!correo || !CORREO_REGEX.test(correo)) {
            throw httpError(
                400,
                "Ingresa un correo electrónico válido."
            );
        }

        campos.correo = correo;
    }

    if (entrada.telefono !== undefined) {
        const telefono = texto(entrada.telefono);

        if (telefono && (telefono.length < 7 || telefono.length > 20)) {
            throw httpError(
                400,
                "El teléfono debe tener entre 7 y 20 caracteres."
            );
        }

        campos.telefono = telefono;
    }

    if (entrada.fecha_nacimiento !== undefined) {
        campos.fecha_nacimiento = normalizarFecha(
            entrada.fecha_nacimiento
        );
    }

    if (entrada.rol_id !== undefined) {
        const rolId = Number(entrada.rol_id);

        if (!ROLES_VALIDOS.includes(rolId)) {
            throw httpError(
                400,
                "El rol seleccionado no es válido."
            );
        }

        campos.rol_id = rolId;
    }

    if (entrada.estado !== undefined) {
        campos.estado = Boolean(entrada.estado);
    }

    if (entrada.foto !== undefined) {
        campos.foto = texto(entrada.foto);
    }

    if (entrada.vip !== undefined) {
        campos.vip = Boolean(entrada.vip);
    }

    return campos;
};

const normalizarCamposBarbero = (
    datos,
    { requerirEspecialidad = false } = {}
) => {
    const entrada = datos || {};
    const campos = {};

    if (
        entrada.especialidad !== undefined ||
        requerirEspecialidad
    ) {
        const especialidad = texto(entrada.especialidad);

        if (!especialidad) {
            throw httpError(
                400,
                "La especialidad es obligatoria para un barbero."
            );
        }

        campos.especialidad = especialidad;
    }

    if (entrada.experiencia !== undefined) {
        const experiencia = Number(entrada.experiencia);

        if (
            !Number.isFinite(experiencia) ||
            experiencia < 0 ||
            experiencia > 70
        ) {
            throw httpError(
                400,
                "La experiencia debe ser un número entre 0 y 70."
            );
        }

        campos.experiencia = Math.round(experiencia);
    }

    if (entrada.descripcion !== undefined) {
        campos.descripcion = texto(entrada.descripcion);
    }

    if (entrada.direccion !== undefined) {
        campos.direccion = texto(entrada.direccion);
    }

    if (entrada.foto_trabajo !== undefined) {
        campos.foto_trabajo = texto(entrada.foto_trabajo);
    }

    if (entrada.disponible !== undefined) {
        campos.disponible = Boolean(entrada.disponible);
    }

    if (entrada.portafolio !== undefined) {
        if (!Array.isArray(entrada.portafolio)) {
            throw httpError(
                400,
                "El portafolio debe ser una lista."
            );
        }

        campos.portafolio = entrada.portafolio;
    }

    return campos;
};

const normalizarPassword = (password, obligatoria = false) => {
    if (password === undefined || password === null || password === "") {
        if (obligatoria) {
            throw httpError(
                400,
                "La contraseña es obligatoria."
            );
        }

        return null;
    }

    if (String(password).length < 6) {
        throw httpError(
            400,
            "La contraseña debe tener mínimo 6 caracteres."
        );
    }

    return String(password);
};

const contarDependencias = async (usuarioId, barberoId = null) => {
    const [
        citasCliente,
        citasBarbero,
        resenasCliente,
        resenasBarbero,
        mensajes,
        horarios,
    ] = await Promise.all([
        contarCitasCliente(usuarioId),
        barberoId
            ? contarCitasBarbero(barberoId)
            : Promise.resolve({ count: 0 }),
        contarResenasCliente(usuarioId),
        barberoId
            ? contarResenasBarbero(barberoId)
            : Promise.resolve({ count: 0 }),
        contarMensajesUsuario(usuarioId),
        barberoId
            ? contarHorariosBarbero(barberoId)
            : Promise.resolve({ count: 0 }),
    ]);

    const error = [
        citasCliente.error,
        citasBarbero.error,
        resenasCliente.error,
        resenasBarbero.error,
        mensajes.error,
        horarios.error,
    ].find(Boolean);

    if (error) {
        throw new Error(error.message);
    }

    const resumen = {
        citas:
            (citasCliente.count || 0) +
            (citasBarbero.count || 0),
        resenas:
            (resenasCliente.count || 0) +
            (resenasBarbero.count || 0),
        mensajes: mensajes.count || 0,
        horarios: horarios.count || 0,
    };

    return {
        ...resumen,
        total:
            resumen.citas +
            resumen.resenas +
            resumen.mensajes +
            resumen.horarios,
    };
};

const eliminarDependencias = async (usuarioId, barberoId = null) => {
    const { data: citas } = await obtenerIdsCitasDeUsuario(
        usuarioId,
        barberoId
    );

    const citaIds = (citas || []).map((cita) => cita.id);

    const { error: errorResenas } = await eliminarResenasDeUsuario({
        clienteId: usuarioId,
        barberoId,
        citaIds,
    });

    if (errorResenas) {
        throw new Error(errorResenas.message);
    }

    const { error: errorCitas } = await eliminarCitasDeUsuario(
        usuarioId,
        barberoId
    );

    if (errorCitas) {
        throw new Error(errorCitas.message);
    }

    if (barberoId) {
        const { error: errorHorarios } =
            await eliminarHorariosDeBarbero(barberoId);

        if (errorHorarios) {
            throw new Error(errorHorarios.message);
        }

        const { error: errorBarbero } = await eliminarBarbero(barberoId);

        if (errorBarbero) {
            throw new Error(errorBarbero.message);
        }
    }

    const { error: errorMensajes } = await eliminarMensajesDeUsuario(
        usuarioId
    );

    if (errorMensajes) {
        throw new Error(errorMensajes.message);
    }
};

export const listarUsuarios = async () => {
    const { data, error } = await obtenerUsuarios();

    if (error) {
        throw new Error(error.message);
    }

    return (data || []).map(serializarUsuario);
};

export const buscarUsuario = async (id) => {
    if (!id) {
        throw httpError(400, "El ID del usuario es obligatorio.");
    }

    const { data, error } = await obtenerUsuarioPorId(id);

    if (error) {
        throw new Error(error.message);
    }

    if (!data) {
        throw httpError(404, "Usuario no encontrado.");
    }

    return serializarUsuario(data);
};

export const obtenerPerfilCompleto = async (id) =>
    await buscarUsuario(id);

export const obtenerMiPerfil = async (id) => {
    const perfil = await obtenerPerfilCompleto(id);

    return perfil;
};

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

    const barbero = await obtenerBarberoPorUsuario(usuario.id);
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

    const foto = `/uploads/${archivo.filename}`;

    const { error } = await actualizarUsuario(usuario.id, { foto });

    if (error) {
        throw new Error(error.message);
    }

    return { foto };
};

export const guardarDiplomaBarbero = async (usuario, archivo) => {
    if (!usuario?.id) {
        throw httpError(401, "Usuario no autenticado.");
    }

    if (!archivo) {
        throw httpError(400, "Selecciona un archivo.");
    }

    const barbero = await obtenerBarberoPorUsuario(usuario.id);

    if (!barbero) {
        throw httpError(
            404,
            "Perfil de barbero no encontrado."
        );
    }

    const portafolio = Array.isArray(barbero.portafolio)
        ? barbero.portafolio.filter(
              (item) => item?.tipo !== "diploma"
          )
        : [];

    portafolio.push({
        tipo: "diploma",
        url: `/uploads/documents/${archivo.filename}`,
        nombre: archivo.originalname || archivo.filename,
    });

    const { error } = await actualizarBarbero(barbero.id, {
        portafolio,
    });

    if (error) {
        throw new Error(error.message);
    }

    return {
        diploma_url: `/uploads/documents/${archivo.filename}`,
        portafolio,
    };
};
