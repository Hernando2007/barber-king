import supabase from "../config/supabase.js";


export const obtenerHorarioBarbero = async (barberoId, diaSemana) => {

    return await supabase
        .from("horarios")
        .select("*")
        .eq("barbero_id", barberoId)
        .eq("dia_semana", diaSemana)
        .single();

};


export const obtenerServicio = async (servicioId) => {

    return await supabase
        .from("servicios")
        .select("*")
        .eq("id", servicioId)
        .single();

};


export const obtenerCitas = async (barberoId, fecha) => {

    return await supabase
        .from("citas")
        .select("*")
        .eq("barbero_id", barberoId)
        .eq("fecha", fecha);

};

export const crearNuevaCita = async (datos) => {

    return await supabase
        .from("citas")
        .insert(datos)
        .select()
        .single();

};

export const buscarCitaExistente = async (
    barberoId,
    fecha,
    hora
) => {

    return await supabase
        .from("citas")
        .select("id")
        .eq("barbero_id", barberoId)
        .eq("fecha", fecha)
        .eq("hora", hora)
        .single();

};


export const listarCitas = async () => {

    return await supabase
        .from("citas")
        .select(`
            *,
            usuarios!cliente_id(
                id,
                nombres,
                apellidos,
                correo
            ),
            barberos(
                id,
                usuario_id,
                especialidad
            ),
            servicios(
                id,
                nombre,
                precio,
                duracion
            )
        `)
        .order("fecha", { ascending: true })
        .order("hora", { ascending: true });

};

export const obtenerCitaPorId = async (id) => {

    return await supabase
        .from("citas")
        .select(`
            *,
            usuarios!cliente_id(
                id,
                nombres,
                apellidos,
                correo
            ),
            barberos(
                id,
                usuario_id,
                especialidad
            ),
            servicios(
                id,
                nombre,
                precio,
                duracion
            )
        `)
        .eq("id", id)
        .single();

};

export const actualizarCita = async (id, datos) => {

    const { data, error } = await supabase
        .from("citas")
        .update(datos)
        .eq("id", id)
        .select();

    if (error) {
        return { data: null, error };
    }

    if (data.length === 0) {
        return {
            data: null,
            error: {
                message: "No existe una cita con ese ID."
            }
        };
    }

    return {
        data: data[0],
        error: null
    };

};

export const eliminarCita = async (id) => {

    return await supabase
        .from("citas")
        .delete()
        .eq("id", id);

}; 