-- Barber King - compatibilidad del perfil profesional del barbero
-- Ejecutar solo sobre bases creadas con una versión anterior del esquema.
-- Es idempotente: no falla si las columnas ya existen.

alter table if exists barberos
  add column if not exists direccion text,
  add column if not exists portafolio jsonb not null default '[]'::jsonb,
  add column if not exists disponible boolean not null default true;

create index if not exists idx_barberos_especialidad
  on barberos(especialidad);

create index if not exists idx_barberos_disponible
  on barberos(disponible);
