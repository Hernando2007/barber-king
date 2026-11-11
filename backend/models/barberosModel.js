import supabase from "../config/supabase.js";
import { asegurarHorariosPorDefecto } from "./horariosModel.js";
 
export const obtenerBarberos = async ({ servicioId = null } = {}) => {
    // Con servicioId solo salen los barberos que lo prestan. El !inner
    // es lo que descarta al resto en lugar de devolverlos con el dato vacío.
    const seleccion = servicioId
        ? `
            *,
            barbero_servicios!inner(
                servicio_id
            ),
            usuarios(
                id,
                nombres,
                apellidos,
                foto
            )
        `
        : `
            *,
            usuarios(
                id,
                nombres,
                apellidos,
                foto
            )
        `;

    let consulta = supabase
        .from("barberos")
        .select(seleccion)
        .order("id", { ascending: true });

    if (servicioId) {
        consulta = consulta.eq(
            "barbero_servicios.servicio_id",
            servicioId
        );
    }

    return await consulta;
};
 
export const obtenerBarberoPorId = async (id) => {
    return await supabase
        .from("barberos")
        .select(`
            *,
            usuarios(
                id,
                nombres,
                apellidos,
                foto
            )
        `)
        .eq("id", id)
        .maybeSingle();
};
 
export const obtenerBarberoPorUsuario = async (usuarioId) => {
    return await supabase
        .from("barberos")
        .select("*")
        .eq("usuario_id", usuarioId)
        .maybeSingle();
};
 
export const crearBarbero = async (datos) => {
    const resultado = await supabase
        .from("barberos")
        .insert(datos)
        .select()
        .single();

    if (!resultado.error && resultado.data?.id) {
        await asegurarHorariosPorDefecto(resultado.data.id);
    }

    return resultado;
};
 
export const actualizarBarbero = async (id, datos) => {
    return await supabase
        .from("barberos")
        .update(datos)
        .eq("id", id)
        .select()
        .single();
};
 
export const eliminarBarbero = async (id) => {
    return await supabase
        .from("barberos")
        .delete()
        .eq("id", id);
};
 
export const obtenerBarberoPorUsuarioCompleto = async (usuarioId) => {
    return await supabase
        .from("barberos")
        .select("*")
        .eq("usuario_id", usuarioId)
        .maybeSingle();
};

export const obtenerCalificacionesBarberos = async () => {
    return await supabase
        .from("resenas")
        .select("barbero_id, calificacion");
};

// La bandeja del administrador. El IS NULL va explícito porque en SQL
// "verificacion_estado <> 'aprobado'" tampoco incluye los nulos.
export const obtenerBarberosPendientesRevision = async ({ limite = 100 } = {}) => {
    return await supabase
        .from("barberos")
        .select(`
            *,
            usuarios(
                id,
                nombres,
                apellidos,
                correo,
                telefono,
                foto
            )
        `)
        .or("verificacion_estado.is.null,verificacion_estado.neq.aprobado")
        .order("id", { ascending: true })
        .limit(Number(limite));
};
