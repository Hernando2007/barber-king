// Convierte "08:30" en minutos
export const horaAMinutos = (hora) => {

    const [h, m] = hora.split(":").map(Number);

    return h * 60 + m;

};

// Convierte minutos a formato "08:30"
export const minutosAHora = (minutos) => {

    const horas = Math.floor(minutos / 60)
        .toString()
        .padStart(2, "0");

    const mins = (minutos % 60)
        .toString()
        .padStart(2, "0");

    return `${horas}:${mins}`;

};

// Suma minutos a una hora
export const sumarMinutos = (hora, minutos) => {

    return minutosAHora(
        horaAMinutos(hora) + minutos
    );

};

// Día de la semana en formato barbería: lunes=1 ... domingo=7.
export const diaDeLaSemana = (fecha) => {

    const [anio, mes, dia] = String(fecha)
        .split("-")
        .map(Number);

    const local = new Date(anio, mes - 1, dia);

    if (Number.isNaN(local.getTime())) {
        throw new Error("La fecha es inválida.");
    }

    const js = local.getDay();

    return js === 0 ? 7 : js;

};

// Genera bloques de tiempo
export const generarBloques = (
    horaInicio,
    horaFin,
    duracion
) => {

    const bloques = [];

    let actual = horaAMinutos(horaInicio);

    const fin = horaAMinutos(horaFin);

    while (actual + duracion <= fin) {

        bloques.push(
            minutosAHora(actual)
        );

        actual += duracion;

    }

    return bloques;

};

// Estados que dejan el bloque libre aunque la cita siga en la tabla.
const ESTADOS_CANCELADOS = ["Cancelada", "cancelada"];

// Dos intervalos se pisan cuando uno empieza antes de que el otro termine.
export const haySolapamiento = (inicioA, finA, inicioB, finB) => {

    return inicioA < finB && finA > inicioB;

};

// Una cita ocupa el bloque [inicio, fin). Se usa igual al listar horas
// libres y al reservar, para que ambas vistas coincidan siempre.
export const bloqueaHorario = (
    cita,
    inicio,
    fin,
    duracionPorDefecto = 0
) => {

    if (ESTADOS_CANCELADOS.includes(cita.estado)) {

        return false;

    }

    const inicioCita = horaAMinutos(cita.hora);

    const duracion =
        Number(cita.duracion_minutos) ||
        Number(duracionPorDefecto);

    if (
        !Number.isFinite(inicioCita) ||
        !Number.isFinite(duracion) ||
        duracion <= 0
    ) {

        return false;

    }

    return haySolapamiento(
        inicio,
        fin,
        inicioCita,
        inicioCita + duracion
    );

};
