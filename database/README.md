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

Los scripts eliminan y recrean las tablas que definen, por lo que no deben ejecutarse sobre una base con información que quieras conservar.

`10_verificacion_barberos.sql` es una migración incremental (no borra datos): agrega `barberos.verificacion_estado`, la tabla de auditoría `verificaciones_barberos` y marca como aprobados a los barberos existentes.

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
