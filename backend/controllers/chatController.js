import { enviarMensaje, recomendarCorte, obtenerHistorial } from "../services/chatService.js";

//CHAT DE TEXTO NORMAL
export const chatearConBarberKing = async (req, res) => {
    try {
        const { mensaje, sesionId } = req.body;

        // Busca el ID del usuario en los lugares más comunes del token
        const usuarioId = req.usuario?.id || req.usuarioId || req.user?.id;

        // Si no encuentra el usuario, frena la petición
        if (!usuarioId) {
            return res.status(401).json({
                success: false,
                message: "No se encontró un usuario autenticado válido."
            });
        }

        // Si el mensaje viene vacío, frena la petición
        if (!mensaje || !mensaje.trim()) {
            return res.status(400).json({
                success: false,
                message: "Debes enviar un mensaje."
            });
        }

        // Llama al servicio para procesar el chat con la IA
        const resultado = await enviarMensaje(
            mensaje,
            usuarioId,
            sesionId
        );

        // Devuelve la respuesta limpia que Flutter espera
        return res.status(200).json({
            success: true,
            respuesta: resultado.respuesta,
            sesionId: resultado.sesionId
        });

    } catch (error) {
        console.error("❌ Error en controlador chatearConBarberKing:", error);
        return res.status(500).json({
            success: false,
            message: "Error al procesar el mensaje con la Inteligencia Artificial."
        });
    }
};

// 2. RECOMENDACIÓN DE CORTE MEDIANTE FOTO
export const recomendarCorteConIA = async (req, res) => {
    try {
        // Si no subió ninguna foto, frena la petición
        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: "Debes enviar una imagen."
            });
        }

        // Busca el ID del usuario autenticado
        const usuarioId = req.usuario?.id || req.usuarioId || req.user?.id;
        
        if (!usuarioId) {
            return res.status(401).json({
                success: false,
                message: "Sesión inválida o expirada."
            });
        }

        const sesionId = req.body.sesionId;

        // Extrae la URL de la imagen que Multer ya subió a Cloudinary
        const imagenUrl = req.file.path;

        // Llama al servicio para analizar la foto con Groq Vision
        const resultado = await recomendarCorte(
            imagenUrl,
            usuarioId,
            sesionId
        );

        // Devuelve los datos organizados del corte y la imagen
        return res.status(200).json({
            success: true,
            sesionId: resultado.sesionId,
            imagenUrl: resultado.imagenUrl,
            recomendacion: resultado.recomendacion
        });

    } catch (error) {
        console.error("❌ Error en controlador recomendarCorteConIA:", error);
        return res.status(500).json({
            success: false,
            message: "No se pudo generar la recomendación de corte.",
            error: error.message
        });
    }
};

// 3. OBTENER CHATS ANTERIORES
export const obtenerHistorialBarberKing = async (req, res) => {
    try {
        const { sesionId } = req.params;
        const usuarioId = req.usuario?.id || req.usuarioId || req.user?.id;

        if (!usuarioId) {
            return res.status(401).json({
                success: false,
                message: "Acceso denegado. Se requiere token válido."
            });
        }

        // Busca los mensajes viejos guardados en Supabase
        const historial = await obtenerHistorial(
            sesionId,
            usuarioId
        );

        // Envía el arreglo de mensajes de vuelta a la app móvil
        return res.status(200).json({
            success: true,
            historial
        });

    } catch (error) {
        console.error("❌ Error en controlador obtenerHistorialBarberKing:", error);
        return res.status(500).json({
            success: false,
            message: "Error de la base de datos al obtener el historial."
        });
    }
};
