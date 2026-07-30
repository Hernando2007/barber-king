import {
    obtenerHorarioBarbero,
    obtenerServicio,
    obtenerCitas
} from "../models/citasModel.js";

import {
    generarBloques
} from "../utils/horarios.js";

export const obtenerDisponibilidad = async (
    barberoId,
    servicioId,
    fecha
) => {


    const [anio, mes, dia] = fecha.split("-").map(Number);

    const fechaLocal = new Date(anio, mes - 1, dia);

    const diaSemana = fechaLocal.getDay();

    console.log("=================================");
    console.log("Fecha:", fecha);
    console.log("Día:", diaSemana);
    console.log("=================================");


    const { data: horario, error: errorHorario } =
        await obtenerHorarioBarbero(barberoId, diaSemana);

    if (errorHorario) {
        throw new Error(errorHorario.message);
    }

    if (!horario) {
        throw new Error("El barbero no trabaja ese día.");
    }


    const { data: servicio, error: errorServicio } =
        await obtenerServicio(servicioId);

    if (errorServicio) {
        throw new Error(errorServicio.message);
    }

    if (!servicio) {
        throw new Error("Servicio no encontrado.");
    }


    const { data: citas, error: errorCitas } =
        await obtenerCitas(barberoId, fecha);

    if (errorCitas) {
        throw new Error(errorCitas.message);
    }

    let bloques = generarBloques(
        horario.hora_inicio,
        horario.hora_fin,
        servicio.duracion
    );


    if (citas && citas.length > 0) {

        bloques = bloques.filter(hora => {

            return !citas.some(cita =>
                cita.hora.slice(0, 5) === hora
            );

        });

    }

    return bloques;

};