import supabase from "../config/supabase.js";

export const obtenerDashboard = async () => {

    const [
        usuarios,
        barberos,
        servicios,
        citas,
        resenas,
        citasPendientes,
        citasCompletadas,
        citasCanceladas,
        ultimasCitas,
        ultimosUsuarios
    ] = await Promise.all([

        supabase.from("usuarios").select("*", { count: "exact", head: true }),

        supabase.from("barberos").select("*", { count: "exact", head: true }),

        supabase.from("servicios").select("*", { count: "exact", head: true }),

        supabase.from("citas").select("*", { count: "exact", head: true }),

        supabase.from("resenas").select("*", { count: "exact", head: true }),

        supabase
            .from("citas")
            .select("*", { count: "exact", head: true })
            .eq("estado", "Pendiente"),

        supabase
            .from("citas")
            .select("*", { count: "exact", head: true })
            .eq("estado", "Completada"),

        supabase
            .from("citas")
            .select("*", { count: "exact", head: true })
            .eq("estado", "Cancelada"),

        supabase
            .from("citas")
            .select("*")
            .order("created_at", { ascending: false })
            .limit(5),

        supabase
            .from("usuarios")
            .select("id,nombre,correo,rol,created_at")
            .order("created_at", { ascending: false })
            .limit(5)

    ]);

    return {

        totalUsuarios: usuarios.count ?? 0,

        totalBarberos: barberos.count ?? 0,

        totalServicios: servicios.count ?? 0,

        totalCitas: citas.count ?? 0,

        totalResenas: resenas.count ?? 0,

        citasPendientes: citasPendientes.count ?? 0,

        citasCompletadas: citasCompletadas.count ?? 0,

        citasCanceladas: citasCanceladas.count ?? 0,

        ultimasCitas: ultimasCitas.data ?? [],

        ultimosUsuarios: ultimosUsuarios.data ?? []

    };

};