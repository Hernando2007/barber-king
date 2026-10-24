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

    created_at TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_barbero_usuario
        FOREIGN KEY(usuario_id)
        REFERENCES usuarios(id)
        ON DELETE CASCADE
);