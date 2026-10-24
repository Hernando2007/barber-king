/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 05_horarios.sql
DESCRIPCIÓN:
Crea los bloques de disponibilidad semanal de cada barbero.
dia_semana: 1 = lunes ... 7 = domingo.
=========================================================
*/

DROP TABLE IF EXISTS horarios CASCADE;

CREATE TABLE horarios (

    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    barbero_id BIGINT NOT NULL,

    dia_semana SMALLINT NOT NULL,

    hora_inicio TIME NOT NULL,

    hora_fin TIME NOT NULL,

    disponible BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_horario_barbero
        FOREIGN KEY (barbero_id)
        REFERENCES barberos(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_horario_dia
        CHECK (dia_semana BETWEEN 1 AND 7),

    CONSTRAINT chk_horario_horas
        CHECK (hora_inicio < hora_fin)
);

CREATE INDEX idx_horarios_barbero
    ON horarios (barbero_id, dia_semana);
