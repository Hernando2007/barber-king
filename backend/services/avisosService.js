import { crearAviso, listarNovedades } from "../models/avisosModel.js";

// El aviso es best-effort: si falla, la acción principal (p. ej. la cita)
// igual queda guardada y la app lo descubre en el siguiente sondeo.
export const avisar = async (usuarioId, tipo, titulo, cuerpo, datos) => {
    if (!usuarioId) {
        return null;
    }

    const resultado = await crearAviso({
        usuarioId,
        tipo,
        titulo,
        cuerpo,
        datos,
    });

    if (resultado?.error) {
        console.warn(
            "⚠️ No se pudo registrar el aviso:",
            resultado.error.message
        );
    }

    return resultado?.data ?? null;
};

export const leerNovedadesAvisos = async (
    usuario,
    { desdeId = 0, limite = 30 } = {}
) => {
    const consulta = await listarNovedades({
        usuarioId: usuario.id,
        desdeId,
        limite,
    });

    // Un aviso que no se pudo leer no puede tumbar el polling: la app vuelve
    // a preguntar en el siguiente ciclo.
    if (consulta.error) {
        return { avisos: [], ultimo_id: Number(desdeId) || 0 };
    }

    const lista = (consulta.data || []).slice().reverse();

    return {
        avisos: lista.map((aviso) => ({
            id: aviso.id,
            tipo: aviso.tipo,
            titulo: aviso.titulo,
            cuerpo: aviso.cuerpo,
            datos: aviso.datos || {},
            creado: aviso.created_at,
        })),
        ultimo_id: lista.length ? lista[lista.length - 1].id : Number(desdeId) || 0,
    };
};