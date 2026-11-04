import { obtenerCitasUsuario } from "./citasGestionService.js";
import { obtenerBarberoPorId } from "../models/barberosModel.js";
import { instanteLocal, yaPasó } from "../utils/horaBarberia.js";

const ESTADOS_AVISABLES = ["Pendiente", "Confirmada"];
const DIAS_DE_VENTANA = 3;

const sumarDias = (fecha, dias) => {
    const base = new Date(`${fecha}T00:00:00Z`);

    base.setUTCDate(base.getUTCDate() + dias);

    return base.toISOString().slice(0, 10);
};

const nombreCompleto = (usuario) =>
    `${usuario?.nombres ?? ""} ${usuario?.apellidos ?? ""}`.trim();

const nombreBarbero = async (cache, barberoId) => {
    const clave = Number(barberoId);

    if (cache.has(clave)) {
        return cache.get(clave);
    }

    const { data } = await obtenerBarberoPorId(barberoId);
    const nombre = nombreCompleto(data?.usuarios) ||
        (data?.especialidad ? `Barbero ${data.especialidad}` : "tu barbero");

    cache.set(clave, nombre);

    return nombre;
};

/**
 * Citas que aún pueden recibir aviso. Se compara contra la hora de la
 * barbería, no contra UTC: el cliente decide la ventana exacta en su teléfono.
 */
export const obtenerCitasProximas = async (usuario) => {
    if (usuario.rol === "Administrador") {
        return [];
    }

    const citas = await obtenerCitasUsuario(usuario);
    const hoy = instanteLocal().fecha;
    const limite = sumarDias(hoy, DIAS_DE_VENTANA);
    const nombres = new Map();
    const proximas = [];

    for (const cita of citas) {
        const fecha = String(cita.fecha ?? "").slice(0, 10);

        const avisable =
            ESTADOS_AVISABLES.includes(cita.estado) &&
            fecha >= hoy &&
            fecha <= limite &&
            !yaPasó(fecha, cita.hora);

        if (!avisable) {
            continue;
        }

        const esCliente =
            Number(cita.cliente_id) === Number(usuario.id);

        proximas.push({
            id: cita.id,
            fecha,
            hora: String(cita.hora ?? "").slice(0, 5),
            estado: cita.estado,
            servicio: cita.servicios?.nombre ?? null,
            para: esCliente ? "cliente" : "barbero",
            contraparte: esCliente
                ? await nombreBarbero(nombres, cita.barbero_id)
                : nombreCompleto(cita.usuarios) || "tu cliente",
        });
    }

    return proximas;
};
