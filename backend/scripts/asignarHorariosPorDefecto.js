import supabase from "../config/supabase.js";
import { asegurarHorariosPorDefecto } from "../models/horariosModel.js";

const barberos = await supabase
    .from("barberos")
    .select("id, disponible")
    .order("id", { ascending: true });

if (barberos.error) {
    console.error(
        "No fue posible listar los barberos:",
        barberos.error.message
    );
    process.exit(1);
}

let totalCreados = 0;

for (const barbero of barberos.data || []) {
    const { data, error } = await asegurarHorariosPorDefecto(barbero.id);

    if (error) {
        console.error(`Barbero ${barbero.id}: ${error.message}`);
        continue;
    }

    const creados = (data || []).length;
    totalCreados += creados;

    console.log(
        `Barbero ${barbero.id}: ${creados ? `+${creados} horarios` : "ya tenía la semana completa"}`
    );
}

console.log(`\nListo. Se crearon ${totalCreados} franjas horarias.`);
