/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 03_barberos.sql
=========================================================
*/

DROP TABLE IF EXISTS barberos CASCADE;

CREATE TABLE barberos (

    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    usuario_id BIGINT UNIQUE NOT NULL,

    especialidad VARCHAR(100),

    experiencia INTEGER DEFAULT 0,

    descripcion TEXT,

    direccion TEXT,

    foto_trabajo TEXT,

    portafolio JSONB NOT NULL DEFAULT '[]'::JSONB,

    disponible BOOLEAN NOT NULL DEFAULT TRUE,

    -- Ubicación y procedencia que usa el ranking por zona.
    ciudad TEXT,

    zona TEXT,

    latitud DOUBLE PRECISION,

    longitud DOUBLE PRECISION,

    ubicacion_actualizada TIMESTAMP WITH TIME ZONE,

    -- La bandeja del administrador revisa todo lo que no esté aprobado.
    verificacion_estado VARCHAR(20)
        NOT NULL DEFAULT 'pendiente',

    created_at TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_barbero_usuario
        FOREIGN KEY(usuario_id)
        REFERENCES usuarios(id)
        ON DELETE CASCADE,

    CONSTRAINT barberos_verificacion_estado_check
        CHECK (
            verificacion_estado IN (
                'pendiente',
                'aprobado',
                'rechazado'
            )
        )
);

CREATE INDEX idx_barberos_ubicacion
ON barberos(ubicacion_actualizada DESC);

CREATE INDEX idx_barberos_verificacion_estado
ON barberos(verificacion_estado);
