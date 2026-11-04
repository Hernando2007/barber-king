/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 15_revision_verificaciones.sql
=========================================================
Cuando el diploma no convence a la IA, o el barbero se registra
sin documento, la bandeja del administrador decide. Estas columnas
guardan quién tomó la decisión, cuándo y con qué nota, para que la
auditoría de verificaciones_barberos no dependa solo del modelo.

Es aditivo e idempotente: no cambia datos existentes.
=========================================================
*/

ALTER TABLE verificaciones_barberos
    ADD COLUMN IF NOT EXISTS revisado_por BIGINT
        REFERENCES usuarios(id) ON DELETE SET NULL,

    ADD COLUMN IF NOT EXISTS revisado_at TIMESTAMP WITH TIME ZONE,

    ADD COLUMN IF NOT EXISTS nota_administrador TEXT;

-- El estado ya existía ('aprobado' / 'rechazado' según la IA). Ahora el
-- administrador lo puede corregir desde la bandeja y la consulta frecuente
-- es justamente por estado.
CREATE INDEX IF NOT EXISTS idx_verificaciones_estado
    ON verificaciones_barberos (estado, created_at DESC);

/*
-- Verificación después de ejecutar:
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'verificaciones_barberos'
ORDER BY ordinal_position;

-- Los barberos que esperan el sello (lo que lee la bandeja):
SELECT id, usuario_id, especialidad, verificacion_estado
FROM barberos
WHERE verificacion_estado IS NULL
   OR verificacion_estado <> 'aprobado'
ORDER BY id;
*/
