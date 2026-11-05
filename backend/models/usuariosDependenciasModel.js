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
