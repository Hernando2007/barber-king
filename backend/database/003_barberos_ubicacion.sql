-- Barber King - ubicación y procedencia del barbero
-- Ejecutar en el SQL Editor de Supabase. Es idempotente.

alter table if exists barberos
  add column if not exists ciudad text,
  add column if not exists zona text,
  add column if not exists latitud double precision,
  add column if not exists longitud double precision,
  add column if not exists ubicacion_actualizada timestamptz;

create index if not exists idx_barberos_ubicacion
  on barberos(ubicacion_actualizada desc);

comment on column barberos.ciudad is 'Ciudad donde atiende el barbero';
comment on column barberos.zona is 'Zona, barrio o localidad del barbero';
comment on column barberos.latitud is 'Última latitud compartida por el barbero';
comment on column barberos.longitud is 'Última longitud compartida por el barbero';
comment on column barberos.ubicacion_actualizada is 'Momento en que el barbero compartió su ubicación';
