export const ROL_BARBERO = 2;
export const ROL_CLIENTE = 3;

export const CORREO_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export const texto = (valor) => {
    if (valor === undefined || valor === null) {
        return null;
    }

    const limpio = String(valor).trim();
    return limpio.length ? limpio : null;
};

export const nombreRol = (rolId) => {
    if (Number(rolId) === 1) {
        return "Administrador";
    }

    if (Number(rolId) === ROL_BARBERO) {
        return "Barbero";
    }

    return "Cliente";
};

export const quitarDatosSensibles = (usuario) => {
    const {
        password: _password,
        token_recuperacion: _tokenRecuperacion,
        token_expiracion: _tokenExpiracion,
        ...seguro
    } = usuario;

    return seguro;
};
