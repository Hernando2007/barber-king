-- ============================================================
-- Barber King — Migración 11: limpieza de tablas sin uso
-- Elimina tablas legadas que el backend/frontend no consultan.
-- DROP sin CASCADE: si algo depende de ellas, falla sin borrar.
-- ============================================================

DO $$
DECLARE
    tabla text;
BEGIN
    FOREACH tabla IN ARRAY ARRAY[
        'barbero_servicios',
        'mensajes_directos',
        'codigos_vip',
        'estados_cita'
    ]
    LOOP
        IF EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_name = tabla
        ) THEN
            IF EXISTS (
                SELECT 1
                FROM pg_constraint
                WHERE confrelid = format('public.%I', tabla)::regclass
            ) THEN
                RAISE NOTICE '% tiene claves foráneas que la referencian: no se elimina.', tabla;
            ELSE
                EXECUTE format('DROP TABLE public.%I', tabla);
                RAISE NOTICE '% eliminada.', tabla;
            END IF;
        ELSE
            RAISE NOTICE '% no existe, nada que hacer.', tabla;
        END IF;
    END LOOP;
END $$;
