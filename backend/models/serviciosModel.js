import supabase from "../config/supabase.js";

export const obtenerServicios = async ({ soloActivos = false } = {}) => {
    let consulta = supabase
        .from("servicios")
        .select("*")
        .order("id", { ascending: true });

    if (soloActivos) {
        consulta = consulta.eq("estado", true);
    }

    return await consulta;
};

export const obtenerServicioPorId = async (id) => {
    return await supabase
        .from("servicios")
        .select("*")
        .eq("id", id)
        .maybeSingle();
};

export const crearServicio = async (datos) => {
    return await supabase
        .from("servicios")
        .insert(datos)
        .select()
        .single();
};

export const actualizarServicio = async (id, datos) => {
    return await supabase
        .from("servicios")
        .update(datos)
        .eq("id", id)
        .select()
        .single();
};

export const eliminarServicio = async (id) => {
    return await supabase.from("servicios").delete().eq("id", id);
};

export const contarCitasPorServicio = async (servicioId) => {
    return await supabase
        .from("citas")
        .select("id", { count: "exact", head: true })
        .eq("servicio_id", servicioId);
};

export const eliminarCitasPorServicio = async (servicioId) => {
    return await supabase
        .from("citas")
        .delete()
        .eq("servicio_id", servicioId);
};

export const obtenerIdsCitasPorServicio = async (servicioId) => {
    return await supabase
        .from("citas")
        .select("id")
        .eq("servicio_id", servicioId);
};

export const eliminarResenasPorCitas = async (citaIds) => {
    if (!citaIds?.length) {
        return { error: null };
    }

    return await supabase.from("resenas").delete().in("cita_id", citaIds);
};
