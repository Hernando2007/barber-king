/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 15_revision_verificaciones.sql
=========================================================
Cuando el diplom no convence a la IA (o el barbero sube sin
documento) la bandeja de administrador decide. Estas columnas
guardan quin tom la decisin, cundo y con qu nota, para que
la auditora de verificaciones_barberos no dependa solo del modelo.

Es aditivo e idempotente: no cambia datos existentes.
=========================================================
*/

ALTER TABLE verificaciones_barberos
    ADD COLUMN IF NOT EXISTS revisado_por BIGINT
        REFERENCES usuarios(id) ON DELETE SET NULL,

    ADD COLUMN IF NOT EXISTS revisado_at TIMESTAMP WITH TIME ZONE,

    ADD COLUMN IF NOT EXISTS nota_administrador TEXT;

-- El estado ya exista ('aprobado' / 'rechazado' segn la IA). Ahora el
-- administrador lo puede corregir desde la bandeja.
CREATE INDEX IF NOT EXISTS idx_verificaciones_estado
    ON verificaciones_barberos (estado, created_at DESC);

/*
-- Verificacion despues de ejecutar:
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'verificaciones_barberos'
ORDER BY ordinal_position;

-- Las que esperan una decision:
SELECT id, barbero_id, es_valido, confianza, estado, motivo
FROM verificaciones_barberos
WHERE estado <> 'aprobado'
ORDER BY created_at DESC
LIMIT 20;
*/
