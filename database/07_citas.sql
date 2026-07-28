CREATE TABLE citas (

    id BIGSERIAL PRIMARY KEY,

    cliente_id BIGINT NOT NULL REFERENCES usuarios(id),

    barbero_id BIGINT NOT NULL REFERENCES barberos(id),

    servicio_id BIGINT NOT NULL REFERENCES servicios(id),

    fecha DATE NOT NULL,

    hora TIME NOT NULL,

    estado VARCHAR(20) DEFAULT 'Pendiente',

    observaciones TEXT,

    created_at TIMESTAMP DEFAULT NOW(),

    updated_at TIMESTAMP DEFAULT NOW()

);