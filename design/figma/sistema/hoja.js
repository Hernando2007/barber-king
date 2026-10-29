const { C, F } = require("./tokens");
const { degradado, etiqueta } = require("./base");
const { texto } = require("./texto");
const { icono } = require("./iconos");
const {
  boton,
  campo,
  chip,
  insignia,
  estrellas,
  avatar,
  switchControl,
  barraProgreso,
  tarjeta,
} = require("./componentes");

const W = 780;
const H = 1140;

const colores = [
  ["primary", C.primary],
  ["primaryLight", C.primaryLight],
  ["primaryDark", C.primaryDark],
  ["background", C.background],
  ["backgroundSoft", C.backgroundSoft],
  ["card", C.card],
  ["surface", C.surface],
  ["surfaceAlt", C.surfaceAlt],
  ["border", C.border],
  ["borderStrong", C.borderStrong],
  ["white", C.white],
  ["subtitle", C.subtitle],
  ["muted", C.muted],
  ["success", C.success],
  ["warning", C.warning],
  ["error", C.error],
];

const muestra = (x, y, nombre, color) => `
<g>
  <rect x="${x}" y="${y}" width="160" height="40" rx="10" fill="${color}" stroke="${C.borderStrong}"/>
  ${texto(x, y + 56, nombre, { tam: 10.5, peso: 500 })}
  ${texto(x, y + 70, color.toUpperCase(), { tam: 9.5, color: C.muted, espaciado: 0.6 })}
</g>`;

const tipografia = (y, tam, peso, nombre, uso) => `
<g>
  ${texto(48, y, "Aa", { tam: 34, peso })}
  ${texto(116, y - 12, nombre.toUpperCase(), { tam: 9.5, peso: 600, color: C.primary, espaciado: 1.1 })}
  ${texto(116, y + 5, `Poppins ${tam} / ${peso}`, { tam: 11, color: C.subtitle })}
  ${texto(430, y, uso, { tam: 11, color: C.muted })}
</g>`;

module.exports = {
  W,
  H,
  render: () => `<defs>${degradado("gold", ["#F4DA9A", "#D6B25E", "#A9832F"], 0, 0, 1, 1)}</defs>
<rect width="${W}" height="${H}" fill="${C.background}"/>
<rect x="0" y="0" width="${W}" height="240" fill="${C.backgroundSoft}"/>
${texto(48, 58, "SISTEMA DE DISEÑO", { tam: 10.5, peso: 600, color: C.primary, espaciado: 1.8 })}
${texto(48, 100, "Barber King", { tam: 34, peso: 700, espaciado: -0.6 })}
${texto(48, 124, "Colores, tipografía y componentes usados en las 21 pantallas.", { tam: 12.5, color: C.subtitle })}
${icono("scissors", 682, 66, 46, C.primary, 1.4)}
${texto(48, 202, "Mockups 390 × 844 · tema oscuro · Material 3", { tam: 11, color: C.muted })}
${etiqueta(48, 290, "01 · Color")}
${colores
  .map(([nombre, color], i) => muestra(48 + (i % 4) * 175, 310 + Math.floor(i / 4) * 82, nombre, color))
  .join("")}
${etiqueta(48, 682, "02 · Tipografía")}
${tipografia(736, 30, 700, "Display", "Hola, Marco · títulos de pantalla")}
${tipografia(800, 19, 600, "Título", "Encabezados de sección y tarjetas")}
${tipografia(864, 13, 400, "Cuerpo", "Textos de apoyo y descripciones")}
${etiqueta(48, 930, "03 · Componentes")}
${boton(48, 948, 170, "RESERVAR")}
${boton(234, 948, 170, "VER DETALLE", { tipo: "contorno" })}
${chip(420, 954, "Todos", { activo: true })}
${chip(496, 954, "Clientes")}
${chip(586, 954, "Barberos")}
${insignia(48, 1022, "Confirmada")}
${insignia(146, 1022, "Pendiente", { tipo: "warning" })}
${insignia(244, 1022, "Cancelada", { tipo: "error" })}
${insignia(342, 1022, "Barbero", { tipo: "info" })}
${estrellas(440, 1020, 4.8, { tam: 14, separacion: 5 })}
${texto(542, 1032, "4.8 (124)", { tam: 11.5, peso: 500, color: C.subtitle })}
${campo(48, 1062, 300, { placeholder: "Buscar barbero", icono: "search" })}
${avatar(378, 1062, 48, { iniciales: "MR", activo: true })}
${switchControl(440, 1073, { on: true })}
${barraProgreso(504, 1078, 160, { valor: 0.68 })}
${texto(504, 1066, "Progreso del día", { tam: 10, color: C.subtitle })}
${tarjeta(694, 1062, 38, 48, { radio: 12, gradiente: "gold", borde: null })}
${icono("scissors", 703, 1072, 20, C.black)}
`,
};
