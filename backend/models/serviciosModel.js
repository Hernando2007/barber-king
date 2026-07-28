import supabase from "../config/supabase.js";

/* ===========================================
   LISTAR SERVICIOS
=========================================== */

export const obtenerServicios = async () => {

    return await supabase
        .from("servicios")
        .select("*")
        .order("id");

};

/* ===========================================
   OBTENER POR ID
=========================================== */

export const obtenerServicioPorId = async (id) => {

    return await supabase
        .from("servicios")
        .select("*")
        .eq("id", id)
        .single();

};

/* ===========================================
   CREAR
=========================================== */

export const crearServicio = async (datos) => {

    return await supabase
        .from("servicios")
        .insert(datos)
        .select()
        .single();

};

/* ===========================================
   ACTUALIZAR
=========================================== */

export const actualizarServicio = async (id, datos) => {

    return await supabase
        .from("servicios")
        .update(datos)
        .eq("id", id)
        .select()
        .single();

};

/* ===========================================
   ELIMINAR
=========================================== */

export const eliminarServicio = async (id) => {

    return await supabase
        .from("servicios")
        .delete()
        .eq("id", id);

};