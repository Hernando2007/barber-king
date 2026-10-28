# Migraciones Barber King

El esquema completo vive en [`database/`](../../database/README.md) y debe aplicarse primero en Supabase.

`002_barberos_profesional.sql` es una migración de compatibilidad para bases creadas con una versión anterior del esquema. Agrega `direccion`, `portafolio` y `disponible` al perfil del barbero; el diploma se guarda dentro de `portafolio` con `tipo: "diploma"`. Es idempotente, por lo que puedes ejecutarla sin riesgo de duplicar columnas.

`003_barberos_ubicacion.sql` agrega `ciudad`, `zona`, `latitud`, `longitud` y `ubicacion_actualizada` al barbero. Es necesaria para el ranking por zona y la búsqueda de barberos cercanos. También es idempotente.
