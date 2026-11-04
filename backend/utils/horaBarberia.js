import { horaAMinutos } from "./horarios.js";

// El servidor de producción corre en UTC, pero la agenda se piensa en la hora
// local de la barbería. Todo lo que compare "ahora" debe pasar por aquí.
const ZONA = process.env.BARBERIA_ZONA_HORARIA || "America/Bogota";

const PARTES = new Intl.DateTimeFormat("en-CA", {
    timeZone: ZONA,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
});

const DIA_LARGO = new Intl.DateTimeFormat("es-CO", {
    timeZone: ZONA,
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
});

/** Momento actual visto desde la barbería: fecha ISO y minutos del día. */
export const instanteLocal = (momento = new Date()) => {
    const partes = Object.fromEntries(
        PARTES.formatToParts(momento).map(({ type, value }) => [type, value])
    );

    return {
        fecha: `${partes.year}-${partes.month}-${partes.day}`,
        minutos: Number(partes.hour) * 60 + Number(partes.minute),
    };
};

/** "3 de noviembre de 2026, martes" según la hora de la barbería. */
export const hoyEnBarberia = (momento = new Date()) =>
    DIA_LARGO.format(momento).replace(/,/g, "");

/**
 * Dice si una cita de la barbería ya quedó atrás para quien reserva.
 * Se compara como hora de pared ("2026-11-03" + "14:30"), nunca con UTC.
 */
export const yaPasó = (fecha, hora, momento = new Date()) => {
    const ahora = instanteLocal(momento);
    const textoFecha = String(fecha).slice(0, 10);
    const textoHora = String(hora).slice(0, 5);

    if (textoFecha !== ahora.fecha) {
        return textoFecha < ahora.fecha;
    }

    return horaAMinutos(textoHora) <= ahora.minutos;
};
