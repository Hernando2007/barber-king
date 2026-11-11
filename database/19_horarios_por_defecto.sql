/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 19_horarios_por_defecto.sql
=========================================================
Da horario semanal a los barberos que no tienen ninguna
franja registrada, para que cualquier barbero admita citas.
1 = lunes ... 7 = domingo (igual que la disponibilidad).

Es idempotente: solo inserta los días que falten y no toca
los horarios existentes.
=========================================================
*/

WITH dias (dia_semana, hora_inicio, hora_fin) AS (
    VALUES
        (1, '09:00', '19:00'),
        (2, '09:00', '19:00'),
        (3, '09:00', '19:00'),
        (4, '09:00', '19:00'),
        (5, '09:00', '19:00'),
        (6, '09:00', '18:00'),
        (7, '10:00', '14:00')
), faltantes AS (
    SELECT
        b.id AS barbero_id,
        d.dia_semana,
        d.hora_inicio::time AS hora_inicio,
        d.hora_fin::time AS hora_fin
    FROM barberos b
    CROSS JOIN dias d
    WHERE NOT EXISTS (
        SELECT 1
        FROM horarios h
        WHERE h.barbero_id = b.id
          AND h.dia_semana = d.dia_semana
    )
)
INSERT INTO horarios (barbero_id, dia_semana, hora_inicio, hora_fin, disponible)
SELECT barbero_id, dia_semana, hora_inicio, hora_fin, true
FROM faltantes;

-- Verificación rápida:
-- SELECT barbero_id, COUNT(*) FROM horarios GROUP BY barbero_id ORDER BY barbero_id;
