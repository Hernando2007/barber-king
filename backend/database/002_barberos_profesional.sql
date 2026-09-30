-- Barber King - migración para perfil profesional del barbero
-- Ejecutar después de crear las tablas base de Barber King.

alter table if exists barberos
  add column if not exists especialidad text,
  add column if not exists diploma_url text,
  add column if not exists diploma_nombre text,
  add column if not exists verificacion_estado text default 'pendiente',
  add column if not exists activo boolean default true;

update barberos
set verificacion_estado = coalesce(verificacion_estado, 'pendiente')
where verificacion_estado is null;

update barberos
set activo = coalesce(activo, true)
where activo is null;

create index if not exists idx_barberos_especialidad
  on barberos(especialidad);

create index if not exists idx_barberos_verificacion
  on barberos(verificacion_estado);


alter table if exists servicios
  add column if not exists barbero_id bigint references barberos(id) on delete set null;

create index if not exists idx_servicios_barbero
  on servicios(barbero_id);
