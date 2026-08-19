/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 04_servicios.sql
=========================================================
*/

DROP TABLE IF EXISTS servicios CASCADE;

CREATE TABLE servicios (

    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nombre VARCHAR(100) NOT NULL UNIQUE,

    descripcion TEXT,

    precio DECIMAL(10,2) NOT NULL,

    duracion INTEGER NOT NULL,

    imagen TEXT,
    
    estado BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT NOW(),

    updated_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT chk_precio
        CHECK (precio > 0),

    CONSTRAINT chk_duracion
        CHECK (duracion > 0)
);