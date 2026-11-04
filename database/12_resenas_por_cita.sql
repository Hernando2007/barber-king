/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 12_resenas_por_cita.sql
DESCRIPCIÓN:
Migración incremental: una reseña por cita. Guarda la cita
calificada en resenas.cita_id y no permite repetir la
reseña de una misma cita.
=========================================================
*/

ALTER TABLE resenas
    ADD COLUMN IF NOT EXISTS cita_id BIGINT;

ALTER TABLE resenas
    DROP CONSTRAINT IF EXISTS uq_resena_cita;

ALTER TABLE resenas
    ADD CONSTRAINT uq_resena_cita
        UNIQUE (cita_id);
