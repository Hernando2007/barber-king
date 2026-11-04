import cors from "cors";

const origenesPermitidos = [
    process.env.FRONTEND_URL,
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://192.168.100.165:3000",
].filter(Boolean);

// Sin origin (curl, apps móviles, healthchecks) se deja pasar: la app Flutter
// no manda cabecera Origin.
const esOrigenLocal = (origen) => {
    if (!origen) {
        return true;
    }

    return (
        /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origen) ||
        /^https?:\/\/(192\.168|10\.|172\.(1[6-9]|2\d|3[01]))\.\d+\.\d+(:\d+)?$/.test(
            origen
        ) ||
        origenesPermitidos.includes(origen)
    );
};

export const middlewareCors = cors({
    origin: (origin, callback) => {
        callback(null, esOrigenLocal(origin));
    },

    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],

    allowedHeaders: ["Content-Type", "Authorization"]
});
