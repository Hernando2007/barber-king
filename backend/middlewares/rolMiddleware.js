export const verificarRol = (...rolesPermitidos) => {

    return (
        req,
        res,
        next
    ) => {

        if (!req.usuario) {

            return res.status(401).json({

                success: false,

                message:
                    "Usuario no autenticado."

            });

        }

        if (!req.usuario.rol) {

            return res.status(403).json({

                success: false,

                message:
                    "El usuario no tiene un rol asignado."

            });

        }

        if (

            !rolesPermitidos.includes(
                req.usuario.rol
            )

        ) {

            return res.status(403).json({

                success: false,

                message:
                    "No tienes permisos para realizar esta acción."

            });

        }

        next();

    };

};