/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 08_mensajes_chat.sql
DESCRIPCIÓN:
Mensajes del chat directo cliente-barbero y del chat con IA.
tipo_mensaje: texto | directo | recomendacion_corte.
=========================================================
*/

DROP TABLE IF EXISTS mensajes_chat CASCADE;

CREATE TABLE mensajes_chat (

    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    sesion_id TEXT NOT NULL,

    usuario_id BIGINT NOT NULL,

    emisor VARCHAR(20) NOT NULL,

    mensaje TEXT NOT NULL,

    imagen_url TEXT,

    tipo_mensaje VARCHAR(30) NOT NULL DEFAULT 'texto',

    metadata JSONB,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_mensaje_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_mensaje_emisor
        CHECK (emisor IN ('user', 'bot', 'usuario')),

    CONSTRAINT chk_mensaje_tipo
        CHECK (tipo_mensaje IN ('texto', 'directo', 'recomendacion_corte'))
);

CREATE INDEX idx_mensajes_sesion
    ON mensajes_chat (sesion_id, id);

CREATE INDEX idx_mensajes_directos
    ON mensajes_chat (tipo_mensaje, created_at DESC);
