const PALABRAS = [
    "hijueputa",
    "hijueputas",
    "hpta",
    "puta",
    "puto",
    "putas",
    "putos",
    "mierda",
    "mierdas",
    "marica",
    "maricon",
    "maricones",
    "gonorrea",
    "malparido",
    "malparida",
    "malparidos",
    "cabron",
    "cabrona",
    "cabrones",
    "pendejo",
    "pendeja",
    "pendejos",
    "pendejas",
    "idiota",
    "idiotas",
    "imbecil",
    "imbeciles",
    "estupido",
    "estupida",
    "culiao",
    "culiada",
    "culiado",
    "verga",
    "vergas",
    "zorra",
    "zorras",
    "perra",
    "perras",
    "pirobo",
    "piroba",
    "carepicha",
    "careverga",
    "carechimba",
    "mamaguevo",
    "mamahuevo",
    "chupaverga",
];

const PROHIBIDAS = new Set(PALABRAS);

const SUSTITUCIONES = {
    0: "o",
    1: "i",
    3: "e",
    4: "a",
    5: "s",
    7: "t",
    "@": "a",
    $: "s",
};

export const normalizarTexto = (texto) =>
    String(texto || "")
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .replace(/[013457@$]/g, (letra) => SUSTITUCIONES[letra])
        .replace(/[^a-z\s]/g, " ")
        .replace(/([a-z])\1+/g, "$1")
        .replace(/\s+/g, " ")
        .trim();

export const contieneProfanidad = (texto) => {
    const normalizado = normalizarTexto(texto);

    if (!normalizado) {
        return false;
    }

    return normalizado
        .split(" ")
        .some((palabra) => PROHIBIDAS.has(palabra));
};
