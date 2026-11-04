import supabase from "../config/supabase.js";

// Los servicios que presta cada barbero, con el precio y la duración
// propios cuando el barbero decide cobrar distinto del catálogo.
// Las columnas Null significan "usa la del catálogo".

export const obtenerServiciosDelBarbero = async (barberoId) => {
    return await supabase
        .from("vista_servicios_barbero")
        .select("*")
        .eq("barbero_id", barberoId)
        .order("nombre", { ascending: true });
};

export const obtenerBarberosQuePrestan = async (servicioId) => {
    return await supabase
        .from("barbero_servicios")
        .select("barbero_id, servicio_id, precio, duracion")
        .eq("servicio_id", servicioId);
};

export const obtenerPar = async (barberoId, servicioId) => {
    return await supabase
        .from("vista_servicios_barbero")
        .select("*")
        .eq("barbero_id", barberoId)
        .eq("servicio_id", servicioId)
        .maybeSingle();
};

// El barbero manda la lista completa de lo que atiende: lo que no
// esté se borra, lo que esté se crea o se actualiza con su precio.
export const reemplazarServiciosDelBarbero = async (barberoId, lista) => {
    const vigentes = await supabase
        .from("barbero_servicios")
        .select("servicio_id")
        .eq("barbero_id", barberoId);

    if (vigentes.error) {
        return vigentes;
    }

    const queridos = new Set(lista.map((s) => Number(s.servicio_id)));
    const aBorrar = (vigentes.data || [])
        .map((s) => Number(s.servicio_id))
        .filter((id) => !queridos.has(id));

    if (aBorrar.length) {
        const borrado = await supabase
            .from("barbero_servicios")
            .delete()
            .eq("barbero_id", barberoId)
            .in("servicio_id", aBorrar);

        if (borrado.error) {
            return borrado;
        }
    }

    if (!lista.length) {
        return { error: null, data: [] };
    }

    const filas = lista.map((servicio) => ({
        barbero_id: Number(barberoId),
        servicio_id: Number(servicio.servicio_id),
        precio: precioOrNull(servicio.precio),
        duracion: duracionOrNull(servicio.duracion),
        updated_at: new Date().toISOString(),
    }));

    return await supabase
        .from("barbero_servicios")
        .upsert(filas, { onConflict: "barbero_id,servicio_id" })
        .select();
};

const precioOrNull = (valor) => {
    const numero = Number(valor);
    return Number.isFinite(numero) && numero > 0 ? numero : null;
};

const duracionOrNull = (valor) => {
    const numero = Number(valor);
    return Number.isInteger(numero) && numero > 0 ? numero : null;
};
