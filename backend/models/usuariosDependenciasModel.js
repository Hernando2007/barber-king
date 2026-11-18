import supabase from "../config/supabase.js";

/* Dependencias para eliminación / cambio de rol */

export const contarCitasCliente = async (clienteId) => {
    return await supabase
        .from("citas")
        .select("*", { count: "exact", head: true })
        .eq("cliente_id", clienteId);
};

export const contarCitasBarbero = async (barberoId) => {
    return await supabase
        .from("citas")
        .select("*", { count: "exact", head: true })
        .eq("barbero_id", barberoId);
};

export const contarResenasCliente = async (clienteId) => {
    return await supabase
        .from("resenas")
        .select("*", { count: "exact", head: true })
        .eq("cliente_id", clienteId);
};

export const contarResenasBarbero = async (barberoId) => {
    return await supabase
        .from("resenas")
        .select("*", { count: "exact", head: true })
        .eq("barbero_id", barberoId);
};

export const contarMensajesUsuario = async (usuarioId) => {
    return await supabase
        .from("mensajes_chat")
        .select("*", { count: "exact", head: true })
        .eq("usuario_id", usuarioId);
};

export const contarHorariosBarbero = async (barberoId) => {
    return await supabase
        .from("horarios")
        .select("*", { count: "exact", head: true })
        .eq("barbero_id", barberoId);
};

export const obtenerIdsCitasDeUsuario = async (
    clienteId,
    barberoId = null
) => {
    const consulta = barberoId
        ? supabase
              .from("citas")
              .select("id")
              .or(`cliente_id.eq.${clienteId},barbero_id.eq.${barberoId}`)
        : supabase
              .from("citas")
              .select("id")
              .eq("cliente_id", clienteId);

    return await consulta;
};

export const eliminarResenasDeUsuario = async ({
    clienteId,
    barberoId = null,
    citaIds = []
}) => {
    const resultados = [];

    resultados.push(
        await supabase
            .from("resenas")
            .delete()
            .eq("cliente_id", clienteId)
    );

    if (barberoId) {
        resultados.push(
            await supabase
                .from("resenas")
                .delete()
                .eq("barbero_id", barberoId)
        );
    }

    if (citaIds.length) {
        resultados.push(
            await supabase
                .from("resenas")
                .delete()
                .in("cita_id", citaIds)
        );
    }

    const error = resultados.find((r) => r.error)?.error;

    return { error: error || null };
};

export const eliminarCitasDeUsuario = async (
    clienteId,
    barberoId = null
) => {
    if (barberoId) {
        const { error } = await supabase
            .from("citas")
            .delete()
            .or(`cliente_id.eq.${clienteId},barbero_id.eq.${barberoId}`);

        return { error };
    }

    return await supabase
        .from("citas")
        .delete()
        .eq("cliente_id", clienteId);
};

export const eliminarMensajesDeUsuario = async (usuarioId) => {
    return await supabase
        .from("mensajes_chat")
        .delete()
        .eq("usuario_id", usuarioId);
};

export const eliminarHorariosDeBarbero = async (barberoId) => {
    return await supabase
        .from("horarios")
        .delete()
        .eq("barbero_id", barberoId);
};

/* Dependencias adicionales que también bloquean el borrado */

// No todas las bases tienen estas tablas: la migración 16 las crea y la 17
// elimina solicitudes_cliente. Si faltan, el borrado debe continuar igual.
const TABLAS_OPCIONALES = new Set([
    "avisos_usuario",
    "solicitudes_cliente",
    "verificaciones_barberos",
    "portafolio_barbero",
    "barbero_servicios",
]);

const esTablaAusente = (error) =>
    Boolean(
        error &&
            (error.code === "42P01" ||
                error.code === "PGRST205" ||
                /does not exist|Could not find the table/i.test(
                    String(error.message)
                ))
    );

const revisarError = (tabla, error) => {
    if (!error) return;

    if (TABLAS_OPCIONALES.has(tabla) && esTablaAusente(error)) return;

    throw new Error(error.message);
};

export const eliminarAvisosDeUsuario = async (usuarioId) => {
    const { error } = await supabase
        .from("avisos_usuario")
        .delete()
        .eq("usuario_id", usuarioId);

    revisarError("avisos_usuario", error);
};

export const eliminarSolicitudesDeCliente = async (clienteId) => {
    const { error } = await supabase
        .from("solicitudes_cliente")
        .delete()
        .eq("cliente_id", clienteId);

    revisarError("solicitudes_cliente", error);
};

export const eliminarSolicitudesDeBarbero = async (barberoId) => {
    const { error } = await supabase
        .from("solicitudes_cliente")
        .delete()
        .eq("barbero_id", barberoId);

    revisarError("solicitudes_cliente", error);
};

export const eliminarVerificacionesDeCuenta = async (
    usuarioId,
    barberoId = null
) => {
    const { error: errorUsuario } = await supabase
        .from("verificaciones_barberos")
        .delete()
        .eq("usuario_id", usuarioId);

    revisarError("verificaciones_barberos", errorUsuario);

    if (!barberoId) return;

    const { error: errorBarbero } = await supabase
        .from("verificaciones_barberos")
        .delete()
        .eq("barbero_id", barberoId);

    revisarError("verificaciones_barberos", errorBarbero);
};

/** La auditoría se conserva, pero sin apuntar al administrador que se va. */
export const desvincularRevisorDeVerificaciones = async (usuarioId) => {
    const { error } = await supabase
        .from("verificaciones_barberos")
        .update({ revisado_por: null })
        .eq("revisado_por", usuarioId);

    revisarError("verificaciones_barberos", error);
};

export const eliminarPortafolioDeBarbero = async (barberoId) => {
    const { error } = await supabase
        .from("portafolio_barbero")
        .delete()
        .eq("barbero_id", barberoId);

    revisarError("portafolio_barbero", error);
};

export const eliminarServiciosDeBarbero = async (barberoId) => {
    const { error } = await supabase
        .from("barbero_servicios")
        .delete()
        .eq("barbero_id", barberoId);

    revisarError("barbero_servicios", error);
};
