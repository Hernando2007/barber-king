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