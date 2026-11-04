/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 13_barbero_servicios.sql
=========================================================
Cada barbero atiende unos servicios concretos y puede cobrarlos
a su propio precio. La migracion 11 borraba esta tabla cuando no
tenia uso; vuelve con precio y duracion propios.

Es aditiva: no borra ni reemplaza nada. Ejecutarla dos veces no
cambia el resultado.
=========================================================
*/

CREATE TABLE IF NOT EXISTS barbero_servicios (

    barbero_id BIGINT NOT NULL
        REFERENCES barberos(id) ON DELETE CASCADE,

    servicio_id BIGINT NOT NULL
        REFERENCES servicios(id) ON DELETE CASCADE,

    -- NULL significa "usa el precio del catalogo".
    precio DECIMAL(10,2),

    -- NULL significa "usa la duracion del catalogo".
    duracion INTEGER,

    created_at TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW(),

    PRIMARY KEY (barbero_id, servicio_id),

    CONSTRAINT chk_precio_barbero
        CHECK (precio IS NULL OR precio > 0),

    CONSTRAINT chk_duracion_barbero
        CHECK (duracion IS NULL OR duracion > 0)
);

-- Busca inversa: que barberos prestan un servicio dado.
CREATE INDEX IF NOT EXISTS idx_barbero_servicios_servicio
    ON barbero_servicios (servicio_id);

-- Precio y duracion ya resueltos, para no repetir el COALESCE
-- en cada consulta del backend y de la app.
-- precio_propio / duracion_propia vienen directos de la tabla: la app
-- del barbero los necesita para pintar el campo vacio cuando el
-- servicio se cobra al precio del catalogo.
--
-- Postgres no deja cambiar el ORDEN de las columnas de una vista con
-- CREATE OR REPLACE (lo lee como renombrar y da 42P16), asi que se bota
-- y se vuelve a crear. Nadie mas depende de esta vista: el backend la
-- consulta por nombre y no hay reglas ni vistas encimadas.
DROP VIEW IF EXISTS vista_servicios_barbero;

CREATE VIEW vista_servicios_barbero AS
SELECT
    bs.barbero_id,
    bs.servicio_id,
    s.nombre,
    s.descripcion,
    s.imagen,
    s.estado AS servicio_activo,
    s.precio AS precio_catalogo,
    s.duracion AS duracion_catalogo,
    bs.precio AS precio_propio,
    bs.duracion AS duracion_propia,
    COALESCE(bs.precio, s.precio) AS precio,
    COALESCE(bs.duracion, s.duracion) AS duracion,
    bs.precio IS NULL AS precio_del_catalogo,
    bs.created_at,
    bs.updated_at
FROM barbero_servicios bs
JOIN servicios s ON s.id = bs.servicio_id;

-- Semilla: nadie puede quedar sin reservar por no haber marcado
-- sus servicios. Cada barbero recibe hoy los servicios activos.
INSERT INTO barbero_servicios (barbero_id, servicio_id)
SELECT
    b.id,
    s.id
FROM barberos b
CROSS JOIN servicios s
WHERE s.estado = TRUE
ON CONFLICT (barbero_id, servicio_id) DO NOTHING;

-- Deriva conocida: el backend escribe estas dos columnas en cada
-- reserva (citasService.js) pero no estaban en el esquema versionado.
ALTER TABLE citas
    ADD COLUMN IF NOT EXISTS precio DECIMAL(10,2),
    ADD COLUMN IF NOT EXISTS duracion_minutos INTEGER;

/*
-- Verificacion despues de ejecutar:
SELECT (SELECT COUNT(*) FROM barberos) AS barberos,
       (SELECT COUNT(*) FROM servicios WHERE estado = TRUE) AS servicios,
       (SELECT COUNT(*) FROM barbero_servicios) AS enlaces,
       (SELECT COUNT(*) FROM barbero_servicios WHERE precio IS NOT NULL)
           AS con_precio_propio;

-- Las columnas nuevas de la vista (precio_propio / duracion_propia):
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'vista_servicios_barbero'
ORDER BY ordinal_position;
*/
