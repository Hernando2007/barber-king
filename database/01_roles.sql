/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 01_roles.sql
DESCRIPCIÓN:
Crea la tabla de roles del sistema.
=========================================================
*/

DROP TABLE IF EXISTS roles CASCADE;

CREATE TABLE roles (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    nombre VARCHAR(50) NOT NULL UNIQUE,

    descripcion TEXT,

    estado BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_roles_nombre
        CHECK (nombre IN ('Administrador', 'Barbero', 'Cliente'))
);

COMMENT ON TABLE roles IS 'Roles disponibles dentro del sistema.';
COMMENT ON COLUMN roles.nombre IS 'Nombre del rol.';
COMMENT ON COLUMN roles.estado IS 'Indica si el rol está activo.';