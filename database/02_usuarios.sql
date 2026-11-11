/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 02_usuarios.sql
=========================================================
*/

DROP TABLE IF EXISTS usuarios CASCADE;

CREATE TABLE usuarios (

    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    rol_id BIGINT NOT NULL,

    nombres VARCHAR(100) NOT NULL,

    apellidos VARCHAR(100) NOT NULL,

    correo VARCHAR(150) NOT NULL UNIQUE,

    telefono VARCHAR(20),

    -- NULL en las cuentas creadas con Google: no usan contraseña local.
    password TEXT,

    foto TEXT,

    -- Foto que devuelve Google; foto es la que el usuario sube a mano.
    avatar TEXT,

    -- Identificador de la cuenta de Google.
    google_id TEXT,

    email_verificado BOOLEAN NOT NULL DEFAULT FALSE,

    token_recuperacion VARCHAR(10),

    token_expiracion TIMESTAMP WITH TIME ZONE,

    ultimo_login TIMESTAMP WITH TIME ZONE,

    vip BOOLEAN NOT NULL DEFAULT FALSE,

    fecha_nacimiento DATE,

    estado BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT NOW(),

    updated_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (rol_id)
        REFERENCES roles(id),

    CONSTRAINT chk_correo
        CHECK (
            correo ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        ),

    CONSTRAINT uq_usuarios_google_id
        UNIQUE (google_id)
);

CREATE INDEX idx_usuario_correo
ON usuarios(correo);

CREATE INDEX idx_usuario_rol
ON usuarios(rol_id);