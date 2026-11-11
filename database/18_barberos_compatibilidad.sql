/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 18_barberos_compatibilidad.sql
=========================================================
Migración de compatibilidad para bases creadas con una
versión anterior del esquema. El esquema completo de 03 ya
incluye estas columnas; aquí se repiten por si la base es
antigua.

Es aditiva e idempotente: no borra datos ni falla si las
columnas ya existen.
=========================================================
*/

ALTER TABLE IF EXISTS barberos
    ADD COLUMN IF NOT EXISTS foto_trabajo TEXT,

    ADD COLUMN IF NOT EXISTS direccion TEXT,

    ADD COLUMN IF NOT EXISTS portafolio JSONB
        NOT NULL DEFAULT '[]'::JSONB,

    ADD COLUMN IF NOT EXISTS disponible BOOLEAN
        NOT NULL DEFAULT TRUE,

    ADD COLUMN IF NOT EXISTS ciudad TEXT,

    ADD COLUMN IF NOT EXISTS zona TEXT,

    ADD COLUMN IF NOT EXISTS latitud DOUBLE PRECISION,

    ADD COLUMN IF NOT EXISTS longitud DOUBLE PRECISION,

    ADD COLUMN IF NOT EXISTS ubicacion_actualizada
        TIMESTAMP WITH TIME ZONE;

CREATE INDEX IF NOT EXISTS idx_barberos_especialidad
    ON barberos(especialidad);

CREATE INDEX IF NOT EXISTS idx_barberos_disponible
    ON barberos(disponible);

CREATE INDEX IF NOT EXISTS idx_barberos_ubicacion
    ON barberos(ubicacion_actualizada DESC);

COMMENT ON COLUMN barberos.ciudad
    IS 'Ciudad donde atiende el barbero';

COMMENT ON COLUMN barberos.zona
    IS 'Zona, barrio o localidad del barbero';

COMMENT ON COLUMN barberos.latitud
    IS 'Última latitud compartida por el barbero';

COMMENT ON COLUMN barberos.longitud
    IS 'Última longitud compartida por el barbero';

COMMENT ON COLUMN barberos.ubicacion_actualizada
    IS 'Momento en que el barbero compartió su ubicación';
