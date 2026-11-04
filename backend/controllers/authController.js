import {
    registrarUsuario,
    iniciarSesion,
    solicitarRecuperacion,
    cambiarPassword
} from "../services/authService.js";
 
export const registrar = async (req, res, next) => {
    try {
        const datos = {
            ...req.body,
            ...(req.file
                ? {
                    diploma_url: `/uploads/documents/${req.file.filename}`,
                    diploma_nombre: req.file.originalname,
                    diploma_mimetype: req.file.mimetype
                }
                : {})
        };
 
        const sesion = await registrarUsuario(datos);
 
        // Se devuelve la sesión igual que en el login: la cuenta recién
        // creada entra directo a la app y puede subir sus fotos.
        return res.status(201).json({
            success: true,
            message: "Usuario registrado correctamente.",
            ...sesion
        });
    } catch (error) {
        next(error);
    }
};
 
export const login = async (req, res, next) => {
    try {
        const { correo, password } = req.body;
 
        const resultado = await iniciarSesion({
            correo,
            password
        });
 
        return res.status(200).json({
            success: true,
            message: "Inicio de sesión exitoso.",
            token: resultado.token,
            usuario: resultado.usuario
        });
    } catch (error) {
        next(error);
    }
};
 
export const googleConfig = (req, res) => {
    const clientId = (process.env.GOOGLE_CLIENT_ID || "").trim();

    return res.status(200).json({
        success: true,
        data: { clientId: clientId || null }
    });
};

export const forgotPassword = async (req, res, next) => {
    try {
        const { correo } = req.body;
        await solicitarRecuperacion(correo);
 
        return res.status(200).json({
            success: true,
            message:
                "Si el correo existe, se envió un código de recuperación."
        });
    } catch (error) {
        next(error);
    }
};
 
export const resetPassword = async (req, res) => {
    try {
        const { correo, codigo, password } = req.body;
 
        if (!correo || !codigo || !password) {
            return res.status(400).json({
                success: false,
                message:
                    "Correo, código y contraseña son obligatorios."
            });
        }
 
        if (password.length < 6) {
            return res.status(400).json({
                success: false,
                message:
                    "La contraseña debe tener mínimo 6 caracteres."
            });
        }
 
        await cambiarPassword(correo, codigo, password);
 
        return res.status(200).json({
            success: true,
            message: "Contraseña actualizada correctamente."
        });
    } catch (error) {
        return res.status(400).json({
            success: false,
            message: error.message
        });
    }
};
