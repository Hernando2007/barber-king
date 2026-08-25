import supabase from "../config/supabase.js";

// Obtener todos los servicios
export const obtenerServicios = async () => {

    return await supabase
        .from("servicios")
        .select("*")
        .order("id", { ascending: true });

};

// Obtener un servicio por ID
export const obtenerServicioPorId = async (id) => {

    return await supabase
        .from("servicios")
        .select("*")
        .eq("id", id)
        .single();

};

// Crear un servicio
export const crearServicio = async (datos) => {

    return await supabase
        .from("servicios")
        .insert(datos)
        .select()
        .single();

};

// Actualizar un servicio
export const actualizarServicio = async (id, datos) => {

    return await supabase
        .from("servicios")
        .update(datos)
        .eq("id", id)
        .select()
        .single();

};

// Eliminar un servicio
export const eliminarServicio = async (id) => {

    return await supabase
        .from("servicios")
        .delete()
        .eq("id", id);

};