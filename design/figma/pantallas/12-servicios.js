const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, campo, insignia, boton } = require("../sistema/componentes");

const SERVICIOS = [
  ["Corte + Barba", "Combo completo", "$ 40.000", "60 min"],
  ["Fade", "Degradado y perfilado", "$ 30.000", "45 min"],
  ["Barba", "Perfilado y cuidado", "$ 15.000", "20 min"],
];

const servicio = (y, [nombre, descripcion, precio, duracion]) => `
<g>
  ${tarjeta(20, y, 350, 150)}
  <rect x="34" y="${y + 18}" width="46" height="46" rx="14" fill="url(#gold)"/>
  ${icono("scissors", 47, y + 31, 20, C.black)}
  ${texto(94, y + 34, nombre, { tam: 15.5, peso: 600 })}
  ${texto(94, y + 54, descripcion, { tam: 12, color: C.subtitle })}
  ${texto(94, y + 94, precio, { tam: 19, peso: 700, color: C.primary })}
  ${icono("clock", 202, y + 79, 13, C.muted)}
  ${texto(220, y + 90, duracion, { tam: 11, color: C.subtitle })}
  ${insignia(288, y + 16, "Activo", { tipo: "success" })}
  ${boton(34, y + 112, 322, "Reservar este servicio", { tipo: "contorno", alto: 36 })}
</g>`;

module.exports = {
  id: "12-servicios",
  nombre: "Servicios",
  rol: "Cliente",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Servicios", atras: false, acciones: ["refresh"] })}
${tarjeta(20, 112, 350, 104, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.3 })}
${icono("scissors", 38, 134, 34, C.primary, 1.6)}
${texto(90, 154, "Servicios premium", { tam: 16, peso: 600 })}
${texto(90, 176, "Elige el servicio ideal para", { tam: 12, color: C.subtitle })}
${texto(90, 192, "tu próximo look.", { tam: 12, color: C.subtitle })}
${campo(20, 236, 350, { placeholder: "Buscar servicio", icono: "search" })}
${SERVICIOS.map((s, i) => servicio(302 + i * 162, s)).join("")}
`,
};
