import jwt from "jsonwebtoken";
import supabase from "../config/supabase.js";

export const verificarToken = async (
    req,
    res,
    next
) => {

    try {

        const authHeader =
            req.headers.authorization;

        if (
            !authHeader ||
            !authHeader.startsWith(
                "Bearer "
            )
        ) {

            return res.status(401).json({
                success: false,
                message:
                    "Token no proporcionado."
            });

        }

        const token =
            authHeader.split(" ")[1];

        const decoded =
            jwt.verify(
                token,
                process.env.JWT_SECRET
            );

        const {
            data: usuario,
            error
        } = await supabase
            .from("usuarios")
            .select(`
                id,
                nombres,
                correo,
                rol_id,
                roles(nombre)
            `)
            .eq("id", decoded.id)
            .maybeSingle();

        if (
            error ||
            !usuario
        ) {

            return res.status(401).json({
                success: false,
                message:
                    "Usuario no encontrado."
            });

        }

        req.usuario = {
            id: usuario.id,
            nombres:
                usuario.nombres,
            correo:
                usuario.correo,
            rol:
                usuario.roles?.nombre ??
                null,
            rol_id:
                usuario.rol_id
        };

        next();

    } catch (error) {

        if (
            error.name ===
            "TokenExpiredError"
        ) {

            return res.status(401).json({
                success: false,
                message:
                    "La sesión ha expirado."
            });

        }

        return res.status(401).json({
            success: false,
            message:
                "Token inválido."
        });

    }

};