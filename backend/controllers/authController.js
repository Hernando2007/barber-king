import {
    registrarUsuario,
    iniciarSesion
} from "../services/authService.js";

export const registrar = async (req, res) => {

    try {

        const usuario = await registrarUsuario(req.body);

        res.status(201).json({
            success: true,
            message: "Usuario registrado correctamente.",
            data: usuario
        });

    } catch (error) {

        res.status(400).json({
            success: false,
            message: error.message
        });

    }

};

export const login = async (req, res) => {

    try {

        const resultado = await iniciarSesion(req.body);

        res.json({
            success: true,
            message: "Inicio de sesión exitoso.",
            data: resultado
        });

    } catch (error) {

        res.status(401).json({
            success: false,
            message: error.message
        });

    }

};