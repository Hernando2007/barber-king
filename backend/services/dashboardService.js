import supabase from "../config/supabase.js";
import { obtenerDashboard } from "../models/dashboardModel.js";
import { obtenerBarberoPorUsuario } from "../models/barberosModel.js";
 
export const dashboardGeneral = async () => {
    return await obtenerDashboard();
};
 
export const dashboardBarbero = async (usuarioId) => {
    const { data: barbero, error: barberoError } =
        await obtenerBarberoPorUsuario(usuarioId);
 
    if (barberoError) {
        throw new Error(barberoError.message);
    }
 
    if (!barbero) {
        throw new Error("Perfil de barbero no encontrado.");
    }
 
    const [
        citas,
        pendientes,
        completadas,
        resenas,
        servicios
    ] = await Promise.all([
        supabase
            .from("citas")
            .select("*", { count: "exact", head: true })
            .eq("barbero_id", barbero.id),
        supabase
            .from("citas")
            .select("*", { count: "exact", head: true })
            .eq("barbero_id", barbero.id)
            .eq("estado", "Pendiente"),
        supabase
            .from("citas")
            .select("*", { count: "exact", head: true })
            .eq("barbero_id", barbero.id)
            .eq("estado", "Completada"),
        supabase
            .from("resenas")
            .select("calificacion")
            .eq("barbero_id", barbero.id),
        supabase
            .from("servicios")
            .select("*", { count: "exact", head: true })
            .eq("barbero_id", barbero.id)
    ]);
 
    const errores = [
        citas.error,
        pendientes.error,
        completadas.error,
        resenas.error,
        servicios.error
    ].filter(Boolean);
 
    if (errores.length) {
        throw new Error(errores[0].message);
    }
 
    const calificaciones = (resenas.data || [])
        .map((item) => Number(item.calificacion))
        .filter((value) => !Number.isNaN(value));
 
    const promedio = calificaciones.length
        ? calificaciones.reduce((sum, value) => sum + value, 0) /
          calificaciones.length
        : 0;
 
    return {
        barbero,
        resumen: {
            totalCitas: citas.count || 0,
            pendientes: pendientes.count || 0,
            completadas: completadas.count || 0,
            totalResenas: calificaciones.length,
            promedioCalificacion: Number(promedio.toFixed(2)),
            totalServicios: servicios.count || 0
        }
    };
};
