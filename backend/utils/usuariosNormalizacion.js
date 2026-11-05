import { httpError } from "./httpError.js";
import { rolPorId } from "./usuariosRoles.js";

export const texto = (valor) => {
    if (valor === undefined || valor === null) {
        return null;
    }

    const limpio = String(valor).trim();
    return limpio.length ? limpio : null;
};

export const normalizarFecha = (valor) => {
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

export const normalizarPassword = (password, obligatoria = false) => {
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

/** Quita los anidados de Supabase y deja el usuario como lo espera la app. */
export const serializarUsuario = (registro) => {
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
