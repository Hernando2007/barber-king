-- 21_rls.sql
-- Activa Row Level Security (RLS) en todas las tablas del esquema public.
--
-- QUÉ HACE
--   * Activa RLS en cada tabla de public. Sin políticas, la regla por
--     defecto es DENEGAR: cualquier clave que no sea la secreta (rol
--     service_role) no lee ni escribe una fila.
--   * Pone vista_servicios_barbero en security_invoker, porque una vista se
--     ejecuta con los permisos de quien la creó y por sí sola saltaría el
--     RLS: era la forma más fácil de seguir exponiendo datos.
--
-- PREREQUISITO: CAMBIAR LA CLAVE DEL BACKEND ANTES DE CORRER ESTE SCRIPT
--   El backend hoy usa la clave PUBLICABLE (prefijo sb_publishable_), que en
--   Postgres es el rol anon. Al activar RLS sin políticas esa clave queda sin
--   acceso y la app deja de responder: los SELECT devuelven vacío y los
--   INSERT fallan con 42501.
--
--   Antes de ejecutar este archivo:
--     1. Supabase → Project Settings → API keys → copiar la SECRET KEY.
--     2. Ponerla como SUPABASE_KEY en backend/.env (local) y en Render.
--     3. Reiniciar el backend y comprobar que /health y el login responden.
--     4. Recién entonces correr este script.
--
--   La clave secreta pertenece al rol service_role, que tiene BYPASSRLS, así
--   que la app sigue funcionando igual mientras la publicable queda sin nada.
--   El editor SQL de Supabase se conecta como postgres (dueño de las tablas)
--   y el dueño no sufre el RLS, por eso seguirá pudiendo consultar y migrar.
--
-- CÓMO SE REVIERTE
--   ALTER TABLE public.<tabla> DISABLE ROW LEVEL SECURITY;
--
-- Es idempotente: se puede volver a correr sin dañar datos. Ejecútala otra vez
-- cada vez que agregues una tabla nueva, porque Postgres no activa el RLS de
-- forma automática.

DO $$
DECLARE
    tabla TEXT;
    total INTEGER := 0;
BEGIN
    FOR tabla IN
        SELECT c.relname
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public'
          AND c.relkind IN ('r', 'p')
        ORDER BY c.relname
    LOOP
        EXECUTE format(
            'ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY',
            tabla
        );
        total := total + 1;
    END LOOP;

    RAISE NOTICE 'RLS activado en % tabla(s) de public.', total;
END $$;

-- La vista pasa a respetar los permisos del que la consulta. Sin esto, quien
-- tenga SELECT en la vista (el rol anon incluido) ve barbero_servicios y
-- servicios aunque las tablas estén cerradas.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_views
        WHERE schemaname = 'public'
          AND viewname = 'vista_servicios_barbero'
    ) THEN
        RAISE NOTICE 'vista_servicios_barbero no existe; nada que ajustar.';
        RETURN;
    END IF;

    IF current_setting('server_version_num')::int < 150000 THEN
        RAISE WARNING
            'Postgres anterior a 15: no se puede fijar security_invoker. '
            'Revisa la vista a mano.';
        RETURN;
    END IF;

    EXECUTE
        'ALTER VIEW public.vista_servicios_barbero '
        'SET (security_invoker = true)';

    RAISE NOTICE 'vista_servicios_barbero ahora respeta el RLS del consultante.';
END $$;

-- Comprobación: debe salir rls_activado = true en todas las filas.
SELECT
    c.relname AS tabla,
    CASE WHEN c.relrowsecurity THEN 'si' ELSE 'NO' END AS rls_activado
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relkind IN ('r', 'p')
ORDER BY c.relname;
