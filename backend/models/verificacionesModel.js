import supabase from "../config/supabase.js";

const TABLA = "verificaciones_barberos";

const esTablaInexistente = (error) =>
    error?.code === "42P01" || error?.message?.includes(TABLA);

export const crearVerificacion = async (datos) => {
    const { data, error } = await supabase
        .from(TABLA)
        .insert([
            {
                barbero_id: datos.barberoId || null,
                usuario_id: datos.usuarioId || null,
                documento_url: datos.documentoUrl || null,
                documento_nombre: datos.documentoNombre || null,
                origen: datos.origen || "registro",
                proveedor: "groq",
                modelo: datos.modelo || null,
                es_valido: datos.esValido === true,
                confianza: Number.isFinite(datos.confianza)
                    ? Math.round(datos.confianza)
                    : null,
                tipo_documento: datos.tipoDocumento || null,
                titular: datos.titular || null,
                institucion: datos.institucion || null,
                motivo: datos.motivo || null,
                estado: datos.esValido === true ? "aprobado" : "rechazado",
            },
        ])
        .select()
        .single();

    if (error) {
        if (esTablaInexistente(error)) {
            console.warn(
                `⚠️ Tabla ${TABLA} no existe. Ejecuta database/10_verificacion_barberos.sql en Supabase.`
            );
            return { data: null, error: null };
        }

        console.warn("⚠️ No se pudo guardar la verificación:", error.message);
        return { data: null, error: null };
    }

    return { data, error: null };
};

export const listarVerificaciones = async ({ limite = 50, desde = 0 } = {}) => {
    const { data, error } = await supabase
        .from(TABLA)
        .select(
            `
            *,
            usuarios (nombres, apellidos, correo),
            barberos (especialidad)
        `
        )
        .order("created_at", { ascending: false })
        .range(Number(desde), Number(desde) + Number(limite) - 1);

    if (error) {
        if (esTablaInexistente(error)) {
            return { data: [], error: null };
        }

        return { data: null, error };
    }

    return { data: data || [], error: null };
};
