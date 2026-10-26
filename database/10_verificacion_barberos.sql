-- ============================================================
-- Barber King — Migración 10: verificación anti-fraude de barberos
-- Ejecutar en el SQL Editor de Supabase (en orden).
-- La app funciona sin esta migración, pero sin auditoría ni
-- columna de estado; se recomienda ejecutarla.
-- ============================================================

-- 1. Estado de verificación en el perfil del barbero
ALTER TABLE barberos
    ADD COLUMN IF NOT EXISTS verificacion_estado VARCHAR(20)
    NOT NULL DEFAULT 'pendiente';

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'barberos_verificacion_estado_check'
    ) THEN
        ALTER TABLE barberos
            ADD CONSTRAINT barberos_verificacion_estado_check
            CHECK (verificacion_estado IN ('pendiente', 'aprobado', 'rechazado'));
    END IF;
END $$;

-- 2. Los barberos existentes quedan aprobados (ya operan en la app)
UPDATE barberos
SET verificacion_estado = 'aprobado'
WHERE verificacion_estado = 'pendiente';

-- 3. Tabla de auditoría de verificaciones con IA
CREATE TABLE IF NOT EXISTS verificaciones_barberos (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    barbero_id BIGINT REFERENCES barberos (id) ON DELETE SET NULL,
    usuario_id BIGINT REFERENCES usuarios (id) ON DELETE SET NULL,
    documento_url TEXT,
    documento_nombre TEXT,
    origen VARCHAR(20) NOT NULL DEFAULT 'registro',
    proveedor VARCHAR(40) NOT NULL DEFAULT 'groq',
    modelo TEXT,
    es_valido BOOLEAN,
    confianza SMALLINT,
    tipo_documento TEXT,
    titular TEXT,
    institucion TEXT,
    motivo TEXT,
    estado VARCHAR(20) NOT NULL
        CHECK (estado IN ('aprobado', 'rechazado')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_verificaciones_barbero
    ON verificaciones_barberos (barbero_id);

CREATE INDEX IF NOT EXISTS idx_verificaciones_fecha
    ON verificaciones_barberos (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_barberos_verificacion_estado
    ON barberos (verificacion_estado);
