export const validarRegistro = (usuario) => {

    if (!usuario.nombres) {

        throw new Error("El nombre es obligatorio");

    }

    if (!usuario.apellidos) {

        throw new Error("Los apellidos son obligatorios");

    }

    if (!usuario.correo) {

        throw new Error("El correo es obligatorio");

    }

    if (!usuario.password) {

        throw new Error("La contraseña es obligatoria");

    }

    if (usuario.password.length < 6) {

        throw new Error(
            "La contraseña debe tener mínimo 6 caracteres."
        );

    }

};