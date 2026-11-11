/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 20_usuarios_auth_compatibilidad.sql
=========================================================
El backend usa columnas de autenticación que el esquema
antiguo de usuarios no tenía: google_id, avatar,
email_verificado y los datos de recuperación de contraseña.
Además, las cuentas de Google se crean sin password, así
que la columna debe admitir NULL.

El esquema completo de 02 ya incluye todo esto; esta
migración lo agrega en bases creadas con una versión
anterior.

Es aditiva e idempotente: no borra datos.
=========================================================
*/

ALTER TABLE IF EXISTS usuarios
    ALTER COLUMN password DROP NOT NULL,

    ADD COLUMN IF NOT EXISTS avatar TEXT,

    ADD COLUMN IF NOT EXISTS email_verificado BOOLEAN
        NOT NULL DEFAULT FALSE,

    ADD COLUMN IF NOT EXISTS token_recuperacion VARCHAR(10),

    ADD COLUMN IF NOT EXISTS token_expiracion
        TIMESTAMP WITH TIME ZONE,

    ADD COLUMN IF NOT EXISTS ultimo_login
        TIMESTAMP WITH TIME ZONE,

    ADD COLUMN IF NOT EXISTS vip BOOLEAN
        NOT NULL DEFAULT FALSE;

DO $$
DECLARE
    columna text;
BEGIN
    -- Si la base antigua tiene "googleId" o googleid, se conserva
    -- el dato y se renombra a google_id.
    SELECT column_name INTO columna
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'usuarios'
      AND column_name IN ('googleId', 'googleid')
      AND NOT EXISTS (
          SELECT 1
          FROM information_schema.columns
          WHERE table_schema = 'public'
            AND table_name = 'usuarios'
            AND column_name = 'google_id'
      )
    LIMIT 1;

    IF columna IS NOT NULL THEN
        EXECUTE format(
            'ALTER TABLE public.usuarios RENAME COLUMN %I TO google_id',
            columna
        );
    END IF;

    ALTER TABLE public.usuarios
        ADD COLUMN IF NOT EXISTS google_id TEXT;
END $$;

-- El índice de 02 tiene el mismo nombre, así que en una base nueva
-- esta línea no hace nada.
CREATE UNIQUE INDEX IF NOT EXISTS uq_usuarios_google_id
    ON usuarios (google_id);
