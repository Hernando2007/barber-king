import { obtenerDashboard } from "../models/dashboardModel.js";
import supabase from "../config/supabase.js";

export const dashboardGeneral = async () => {

    return await obtenerDashboard();

};

export const dashboardBarbero = async (usuarioId) => {
    const { data: barbero, error: barberoError } = await supabase
        .from("barberos")
        .select("id,especialidad,verificacion_estado,activo")
        .eq("usuario_id", usuarioId)
        .maybeSingle();

    if (barberoError) throw new Error(barberoError.message);
    if (!barbero) throw new Error("Perfil de barbero no encontrado.");

    const [citas, pendientes, completadas, resenas] = await Promise.all([
        supabase.from("citas").select("*", { count: "exact", head: true }).eq("barbero_id", barbero.id),
        supabase.from("citas").select("*", { count: "exact", head: true }).eq("barbero_id", barbero.id).eq("estado", "Pendiente"),
        supabase.from("citas").select("*", { count: "exact", head: true }).eq("barbero_id", barbero.id).eq("estado", "Completada"),
        supabase.from("resenas").select("calificacion").eq("barbero_id", barbero.id)
    ]);

    const errors = [citas.error, pendientes.error, completadas.error, resenas.error].filter(Boolean);
    if (errors.length) throw new Error(errors[0].message);

    const valores = resenas.data || [];
    const promedio = valores.length
        ? valores.reduce((suma, r) => suma + Number(r.calificacion || 0), 0) / valores.length
        : 0;

    return {
        resumen: {
            totalCitas: citas.count || 0,
            pendientes: pendientes.count || 0,
            completadas: completadas.count || 0,
            promedioCalificacion: Number(promedio.toFixed(1)),
        },
        barbero,
    };
};
