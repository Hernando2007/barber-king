import supabase from "../config/supabase.js";

// Obtener todos los barberos
export const obtenerBarberos = async () => {

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
        .order("id", { ascending: true });

};

// Obtener un barbero por ID
export const obtenerBarberoPorId = async (id) => {

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
        .eq("id", id)
        .single();

};

// Crear un barbero
export const crearBarbero = async (datos) => {

    return await supabase
        .from("barberos")
        .insert(datos)
        .select()
        .single();

};

// Actualizar un barbero
export const actualizarBarbero = async (id, datos) => {

    return await supabase
        .from("barberos")
        .update(datos)
        .eq("id", id)
        .select()
        .single();

};

// Eliminar un barbero
export const eliminarBarbero = async (id) => {

    return await supabase
        .from("barberos")
        .delete()
        .eq("id", id);

};