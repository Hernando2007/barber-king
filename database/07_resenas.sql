/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 07_resenas.sql
DESCRIPCIÓN:
Reseñas y calificaciones de los clientes a los barberos.
=========================================================
*/

DROP TABLE IF EXISTS resenas CASCADE;

CREATE TABLE resenas (

    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    cliente_id BIGINT NOT NULL,

    barbero_id BIGINT NOT NULL,

    cita_id BIGINT,

    calificacion SMALLINT NOT NULL,

    comentario TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_resena_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES usuarios(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_resena_barbero
        FOREIGN KEY (barbero_id)
        REFERENCES barberos(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_resena_cita
        FOREIGN KEY (cita_id)
        REFERENCES citas(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_resena_calificacion
        CHECK (calificacion BETWEEN 1 AND 5)
);

CREATE INDEX idx_resenas_barbero
    ON resenas (barbero_id, created_at DESC);

CREATE INDEX idx_resenas_cliente
    ON resenas (cliente_id);
