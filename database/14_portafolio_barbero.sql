/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 14_portafolio_barbero.sql
=========================================================
El barbero quiere mostrar sus cortes. La foto vive en
Cloudinary y aqui queda la referencia (url + public_id) para
poder listarla y borrarla del lado del servidor.

Es aditiva: no toca barberos.portafolio, que sigue guardando
el diploma, y se puede ejecutar dos veces sin cambiar nada.
=========================================================
*/

CREATE TABLE IF NOT EXISTS portafolio_barbero (

    id BIGSERIAL PRIMARY KEY,

    barbero_id BIGINT NOT NULL
        REFERENCES barberos(id) ON DELETE CASCADE,

    -- URL publica de Cloudinary (secure_url).
    url TEXT NOT NULL,

    -- Con esto se borra la imagen del cloud, no solo de la base.
    public_id TEXT NOT NULL,

    created_at TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_portafolio_url
        CHECK (url ~ '^https?://'),

    CONSTRAINT uq_portafolio_public_id
        UNIQUE (public_id)
);

-- La galeria de un barbero, siempre de la mas nueva a la mas vieja.
CREATE INDEX IF NOT EXISTS idx_portafolio_barbero
    ON portafolio_barbero (barbero_id, created_at DESC);

/*
-- Verificacion despues de ejecutar:
SELECT COUNT(*) AS fotos FROM portafolio_barbero;

-- Debe listar las columnas url y public_id:
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'portafolio_barbero'
ORDER BY ordinal_position;
*/
