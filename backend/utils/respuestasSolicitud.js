// Un solo lugar para los motivos y las respuestas de un toque: el backend
// los devuelve y la app solo los pinta, para que cliente y barbero siempre
// lean el mismo texto.
const MOTIVOS = [
    {
        clave: "disponibilidad",
        etiqueta: "¿Tienes hueco?",
        descripcion: "Pregunta si puede atenderte en una fecha.",
        pide_fecha: true,
        pide_servicio: false,
    },
    {
        clave: "reservar",
        etiqueta: "Quiero reservar",
        descripcion: "Pide un hueco antes de pagar la cita.",
        pide_fecha: true,
        pide_servicio: true,
    },
    {
        clave: "reprogramar",
        etiqueta: "Cambiar una cita",
        descripcion: "Propón otra hora para una cita que ya tienes.",
        pide_fecha: true,
        pide_servicio: false,
    },
    {
        clave: "presupuesto",
        etiqueta: "Precio de un servicio",
        descripcion: "Pregunta cuánto cobra por un trabajo.",
        pide_fecha: false,
        pide_servicio: true,
    },
];

const RESPUESTAS = {
    disponibilidad: [
        {
            clave: "hay_hueco",
            estado: "aceptada",
            texto: "Sí, tengo hueco. Reserva tu cita.",
        },
        {
            clave: "sin_hueco",
            estado: "rechazada",
            texto: "Ando lleno estos días, vuelve a preguntar.",
        },
    ],
    reservar: [
        {
            clave: "apartado",
            estado: "aceptada",
            texto: "Te lo dejo apartado, confirma la cita.",
        },
        {
            clave: "no_puedo",
            estado: "rechazada",
            texto: "En ese horario no me es posible.",
        },
    ],
    reprogramar: [
        {
            clave: "nueva_hora",
            estado: "aceptada",
            texto: "Listo, dejamos esa nueva hora.",
        },
        {
            clave: "no_se_mueve",
            estado: "rechazada",
            texto: "Esa cita no la puedo mover.",
        },
    ],
    presupuesto: [
        {
            clave: "precio_ok",
            estado: "aceptada",
            texto: "Sí, ese es mi precio para ese servicio.",
        },
        {
            clave: "otro_precio",
            estado: "rechazada",
            texto: "Ese trabajo tiene otro precio, hablemos.",
        },
    ],
};

export const listarMotivos = () => MOTIVOS;

export const opcionesPara = (motivo) => RESPUESTAS[motivo] || [];

export const resolverRespuesta = (motivo, clave) =>
    opcionesPara(motivo).find((opcion) => opcion.clave === clave) || null;

export const esMotivoValido = (motivo) =>
    MOTIVOS.some((item) => item.clave === motivo);
