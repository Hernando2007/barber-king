# Base de datos

Scripts SQL para crear el esquema de Barber King en un proyecto de Supabase.

## Orden de ejecución

Ejecuta los archivos en el editor SQL de Supabase, uno por uno y en este orden:

1. `01_roles.sql`
2. `02_usuarios.sql`
3. `03_barberos.sql`
4. `04_servicios.sql`
5. `05_horarios.sql`
6. `06_citas.sql`
7. `07_resenas.sql`
8. `08_mensajes_chat.sql`
9. `09_datos_prueba.sql` (opcional)
10. `10_verificacion_barberos.sql` (verificación anti-fraude de barberos)
11. `11_limpieza_tablas.sql` (elimina tablas legadas sin uso)
12. `12_resenas_por_cita.sql` (una reseña por cita)
13. `13_barbero_servicios.sql` (servicios que atiende cada barbero y su precio)
14. `14_portafolio_barbero.sql` (fotos del barbero)
15. `15_revision_verificaciones.sql` (trazabilidad de la revisión de barberos)
16. `16_solicitudes_cliente.sql` (solicitudes de un toque y bandeja de avisos)
17. `17_eliminar_solicitudes.sql` (elimina las solicitudes; conserva los avisos)
18. `18_barberos_compatibilidad.sql` (columnas de perfil y ubicación en bases antiguas)
19. `19_horarios_por_defecto.sql` (horario semanal para barberos sin franjas)
20. `20_usuarios_auth_compatibilidad.sql` (columnas de autenticación en bases antiguas)

Los scripts eliminan y recrean las tablas que definen, por lo que no deben ejecutarse sobre una base con información que quieras conservar.

`10_verificacion_barberos.sql` es una migración incremental (no borra datos): agrega `barberos.verificacion_estado`, la tabla de auditoría `verificaciones_barberos` y marca como aprobados a los barberos existentes.

`12_resenas_por_cita.sql` también es incremental: agrega `resenas.cita_id` si falta y lo marca único, de modo que cada cita completada admite una sola reseña.

Los scripts `13` a `20` también son incrementales y se pueden volver a ejecutar
sin dañar datos: crean sus tablas con `IF NOT EXISTS` y agregan columnas con
`ADD COLUMN IF NOT EXISTS`.

- `13_barbero_servicios.sql` crea `barbero_servicios` (qué servicio atiende cada
  barbero y a qué precio), le agrega `precio` y `duracion_minutos` a `citas` para
  congelar lo acordado al reservar, y recrea la vista `vista_servicios_barbero`.
  Postgres no permite reordenar las columnas de una vista, así que la vista se
  botaba y se volvía a crear; por eso ese `DROP VIEW` es esperado.
- `14_portafolio_barbero.sql` crea `portafolio_barbero`, una fila por foto
  subida a Cloudinary, con `public_id` único para poder borrarla después.
- `15_revision_verificaciones.sql` agrega a `verificaciones_barberos` quién
  revisó (`revisado_por`), cuándo (`revisado_at`) y la nota del administrador, y
  indexa `estado` para la bandeja. Al final trae una consulta de
  verificación: déjala correr para comprobar que las columnas existen.
- `16_solicitudes_cliente.sql` crea `solicitudes_cliente` (el toque de "resérvame")
  y `avisos_usuario`, el buzón que la app lee con `GET /api/avisos/novedades`
  guardando el último id leído.
- `17_eliminar_solicitudes.sql` elimina `solicitudes_cliente` y los avisos viejos
  de solicitudes: la cita ya se confirma al reservar. `avisos_usuario` se
  conserva porque es el buzón que notifica las citas nuevas.
- `18_barberos_compatibilidad.sql` agrega a `barberos` las columnas de perfil
  (`direccion`, `portafolio`, `disponible`) y de ubicación (`ciudad`, `zona`,
  `latitud`, `longitud`, `ubicacion_actualizada`) en bases creadas con un esquema
  anterior. El esquema completo de `03_barberos.sql` ya las incluye.
- `19_horarios_por_defecto.sql` completa el horario semanal de los barberos que
  no tengan ninguna franja, sin tocar las que ya existan.
- `20_usuarios_auth_compatibilidad.sql` agrega a `usuarios` las columnas de
  autenticación (`google_id`, `avatar`, `email_verificado`, tokens de
  recuperación, `ultimo_login` y `vip`), permite `password` nulo para las cuentas
  de Google y renombra la variante camelCase de `google_id` si ya existía,
  conservando los datos. El backend acepta ambos nombres (`google_id` y
  `googleId`), así que el inicio de sesión con Google funciona aunque esta
  migración todavía no se haya aplicado; aplicarla deja el esquema normalizado.

Si vas a aplicar solo algunos, respeta el orden: `16` depende de `citas` y de los
barberos, y `13` debe ir antes de cualquier reserva nueva porque `citas.precio`
se escribe al crear la cita.

## Datos iniciales

`01_roles.sql` inserta los tres roles del sistema:

| id | Rol |
| --- | --- |
| 1 | Administrador |
| 2 | Barbero |
| 3 | Cliente |

Después de crear las tablas, registra los usuarios desde la aplicación o desde el panel de Supabase y asigna el `rol_id` correspondiente.

## Datos de prueba

`09_datos_prueba.sql` inserta servicios, un barbero, citas y reseñas de ejemplo. Requiere que ya existan:

- Un usuario con `id = 2` y rol Barbero.
- Un usuario con `id = 3` y rol Cliente.
- Un perfil en `barberos` para el usuario `2` (el script lo crea).

Si tus usuarios tienen otros identificadores, ajusta los valores antes de ejecutar el script.

## Relaciones principales

- `usuarios.rol_id` → `roles.id`
- `barberos.usuario_id` → `usuarios.id`
- `horarios.barbero_id` → `barberos.id`
- `citas.cliente_id` → `usuarios.id`
- `citas.barbero_id` → `barberos.id`
- `citas.servicio_id` → `servicios.id`
- `resenas.cliente_id` → `usuarios.id`
- `resenas.barbero_id` → `barberos.id`
- `resenas.cita_id` → `citas.id`
- `mensajes_chat.usuario_id` → `usuarios.id`

Las tablas de horarios, reseñas y mensajes eliminan sus registros en cascada cuando se elimina el usuario o barbero relacionado.
