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

        supabase
            .from("usuarios")
            .select("*", {
                count: "exact",
                head: true
            }),

        supabase
            .from("barberos")
            .select("*", {
                count: "exact",
                head: true
            }),

        supabase
            .from("servicios")
            .select("*", {
                count: "exact",
                head: true
            }),

        supabase
            .from("citas")
            .select("*", {
                count: "exact",
                head: true
            }),

        supabase
            .from("resenas")
            .select("*", {
                count: "exact",
                head: true
            }),

        supabase
            .from("citas")
            .select("*", {
                count: "exact",
                head: true
            })
            .eq(
                "estado",
                "Pendiente"
            ),

        supabase
            .from("citas")
            .select("*", {
                count: "exact",
                head: true
            })
            .eq(
                "estado",
                "Completada"
            ),

        supabase
            .from("citas")
            .select("*", {
                count: "exact",
                head: true
            })
            .eq(
                "estado",
                "Cancelada"
            ),

        supabase
            .from("citas")
            .select(`
                *,
                usuarios!cliente_id(
                    id,
                    nombres,
                    apellidos
                ),
                servicios(
                    id,
                    nombre
                )
            `)
            .order(
                "created_at",
                {
                    ascending: false
                }
            )
            .limit(5),

        supabase
            .from("usuarios")
            .select(`
                id,
                nombres,
                apellidos,
                correo,
                created_at
            `)
            .order(
                "created_at",
                {
                    ascending: false
                }
            )
            .limit(5)

    ]);

    const errores = [

        usuarios.error,
        barberos.error,
        servicios.error,
        citas.error,
        resenas.error,
        citasPendientes.error,
        citasCompletadas.error,
        citasCanceladas.error,
        ultimasCitas.error,
        ultimosUsuarios.error

    ].filter(Boolean);

    if (errores.length > 0) {

        throw new Error(
            errores[0].message
        );

    }

    return {

        resumen: {

            totalUsuarios:
                usuarios.count || 0,

            totalBarberos:
                barberos.count || 0,

            totalServicios:
                servicios.count || 0,

            totalCitas:
                citas.count || 0,

            totalResenas:
                resenas.count || 0

        },

        citas: {

            pendientes:
                citasPendientes.count || 0,

            completadas:
                citasCompletadas.count || 0,

            canceladas:
                citasCanceladas.count || 0

        },

        ultimasCitas:
            ultimasCitas.data || [],

        ultimosUsuarios:
            ultimosUsuarios.data || []

    };

};