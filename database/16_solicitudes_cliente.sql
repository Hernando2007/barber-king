/*
=========================================================
PROYECTO: BARBER KING
ARCHIVO: 16_solicitudes_cliente.sql
=========================================================
El barbero pidió dejar de responder mensajes sueltos. El
cliente envía una solicitud con un motivo fijo y el barbero
contesta con un toque. Cada aviso que genera esa solicitud
(o su respuesta) queda en avisos_usuario, que es lo que lee
la app para notificar, con o sin push.

Es aditivo e idempotente: no toca citas ni mensajes_chat.
========================================================
*/

CREATE TABLE IF NOT EXISTS solicitudes_cliente (

    id BIGSERIAL PRIMARY KEY,

    barbero_id BIGINT NOT NULL
        REFERENCES barberos(id) ON DELETE CASCADE,

    cliente_id BIGINT NOT NULL
        REFERENCES usuarios(id) ON DELETE CASCADE,

    -- Opcionales: dan contexto sin abrir un chat.
    cita_id BIGINT
        REFERENCES citas(id) ON DELETE SET NULL,

    servicio_id BIGINT
        REFERENCES servicios(id) ON DELETE SET NULL,

    motivo VARCHAR(20) NOT NULL
        CHECK (motivo IN (
            'disponibilidad',
            'reservar',
            'reprogramar',
            'presupuesto'
        )),

    fecha_propuesta TIMESTAMP WITH TIME ZONE,

    -- Una sola línea de contexto del cliente, no una conversación.
    nota TEXT
        CHECK (nota IS NULL OR char_length(nota) <= 140),

    estado VARCHAR(12) NOT NULL DEFAULT 'pendiente'
        CHECK (estado IN ('pendiente', 'aceptada', 'rechazada')),

    -- Clave de la respuesta rápida elegida por el barbero.
    respuesta VARCHAR(40),

    respuesta_nota TEXT
        CHECK (respuesta_nota IS NULL
               OR char_length(respuesta_nota) <= 140),

    respondido_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW()
);

-- La bandeja del barbero filtra por barbero y estado.
CREATE INDEX IF NOT EXISTS idx_solicitudes_barbero
    ON solicitudes_cliente (barbero_id, estado, created_at DESC);

-- "Mis solicitudes" del cliente.
CREATE INDEX IF NOT EXISTS idx_solicitudes_cliente
    ON solicitudes_cliente (cliente_id, created_at DESC);

CREATE TABLE IF NOT EXISTS avisos_usuario (

    id BIGSERIAL PRIMARY KEY,

    usuario_id BIGINT NOT NULL
        REFERENCES usuarios(id) ON DELETE CASCADE,

    -- 'solicitud_nueva' (para el barbero) o
    -- 'solicitud_respuesta' (para el cliente).
    tipo VARCHAR(30) NOT NULL,

    titulo TEXT NOT NULL,

    cuerpo TEXT NOT NULL,

    -- Lo que la app necesita para abrir la pantalla correcta.
    datos JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW()
);

-- Las novedades se piden siempre igual: "todo lo mío después de N".
CREATE INDEX IF NOT EXISTS idx_avisos_usuario
    ON avisos_usuario (usuario_id, id DESC);

/*
-- Verificación después de ejecutar:
SELECT COUNT(*) AS solicitudes FROM solicitudes_cliente;
SELECT COUNT(*) AS avisos FROM avisos_usuario;

-- Debe listar las columnas de ambas tablas:
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_name IN ('solicitudes_cliente', 'avisos_usuario')
ORDER BY table_name, ordinal_position;
*/
