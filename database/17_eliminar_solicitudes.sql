/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 17_eliminar_solicitudes.sql
=========================================================
Las solicitudes de un toque quedaron redundantes: la cita
se confirma al reservar según el horario real y el barbero
se muestra activo o inactivo. Se elimina su tabla y los
avisos viejos que generó.

avisos_usuario SE CONSERVA: es el buzón que notifica las
citas nuevas (GET /api/avisos/novedades).

Es idempotente: se puede volver a ejecutar sin error.
========================================================
*/

-- Los índices de la tabla caen con ella.
DROP TABLE IF EXISTS solicitudes_cliente;

DELETE FROM avisos_usuario
WHERE tipo IN ('solicitud_nueva', 'solicitud_respuesta');

/*
-- Verificación después de ejecutar:
SELECT COUNT(*) AS tablas_solicitudes
FROM information_schema.tables
WHERE table_name = 'solicitudes_cliente';
-- Debe ser 0.

SELECT COUNT(*) AS avisos_viejos
FROM avisos_usuario
WHERE tipo IN ('solicitud_nueva', 'solicitud_respuesta');
-- Debe ser 0. La tabla avisos_usuario debe seguir existiendo.
*/