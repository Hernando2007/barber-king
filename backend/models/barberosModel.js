import supabase from "../config/supabase.js";

/* ===========================================
   LISTAR BARBEROS
=========================================== */

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
        .order("id");

};

/* ===========================================
   OBTENER POR ID
=========================================== */

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

/* ===========================================
   CREAR
=========================================== */

export const crearBarbero = async (datos) => {

    return await supabase
        .from("barberos")
        .insert(datos)
        .select()
        .single();

};

/* ===========================================
   ACTUALIZAR
=========================================== */

export const actualizarBarbero = async (id, datos) => {

    return await supabase
        .from("barberos")
        .update(datos)
        .eq("id", id)
        .select()
        .single();

};

/* ===========================================
   ELIMINAR
=========================================== */

export const eliminarBarbero = async (id) => {

    return await supabase
        .from("barberos")
        .delete()
        .eq("id", id);

};