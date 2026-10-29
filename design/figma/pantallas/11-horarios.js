const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, insignia, fab } = require("../sistema/componentes");

const DIAS = [
  ["Lunes", "09:00 - 13:00  ·  +1 jornada", "Activo", "success", true],
  ["Martes", "14:00 - 20:00", "Activo", "success", false],
  ["Miércoles", "Día libre", null, null, false],
  ["Jueves", "09:00 - 18:00", "Activo", "success", false],
  ["Viernes", "08:00 - 12:00", "Activo", "success", false],
];

const dia = (y, [nombre, horario, estado, tipo, hoy]) => `
<g>
  ${tarjeta(20, y, 350, 66, { radio: 18 })}
  <g>
    <rect x="34" y="${y + 16}" width="34" height="34" rx="10" fill="${hoy ? C.primary : C.surfaceAlt}" opacity="${hoy ? 0.16 : 1}" stroke="${hoy ? C.primary : C.border}"/>
    ${texto(51, y + 38, nombre.slice(0, 2).toUpperCase(), { tam: 11, peso: 700, color: hoy ? C.primary : C.subtitle, ancla: "middle" })}
  </g>
  ${texto(80, y + 27, nombre, { tam: 14, peso: 600 })}
  ${hoy ? insignia(148, y + 13, "Hoy", { tipo: "gold" }) : ""}
  ${texto(80, y + 49, horario, { tam: 11.5, color: estado ? C.white : C.muted })}
  ${estado ? insignia(268, y + 13, estado, { tipo }) : ""}
  ${icono("more", 342, y + 22, 18, C.muted)}
</g>`;

module.exports = {
  id: "11-horarios",
  nombre: "Mis horarios",
  rol: "Barbero",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Mis horarios", atras: false, acciones: ["refresh"] })}
${texto(24, 138, "Tu semana de trabajo", { tam: 24, peso: 700 })}
${texto(24, 162, "Define los días y horas en que tus", { tam: 12.5, color: C.subtitle })}
${texto(24, 180, "clientes pueden reservar.", { tam: 12.5, color: C.subtitle })}
${tarjeta(20, 198, 350, 104, { gradiente: "card", borde: C.primary, opacidadBorde: 0.3 })}
<g>
  <rect x="34" y="216" width="48" height="48" rx="14" fill="url(#gold)"/>
  ${icono("calendar", 48, 230, 20, C.black)}
</g>
${texto(98, 240, "5 días activos", { tam: 16, peso: 700 })}
${texto(98, 260, "6 jornadas configuradas", { tam: 11.5, color: C.subtitle })}
<rect x="310" y="222" width="40" height="40" rx="12" fill="${C.primary}" opacity="0.15"/>
${icono("plus", 321, 233, 18, C.primary)}
${texto(24, 330, "Disponibilidad semanal", { tam: 15.5, peso: 600 })}
${texto(24, 348, "Puedes tener varias jornadas por día.", { tam: 11.5, color: C.muted })}
${DIAS.map((d, i) => dia(364 + i * 74, d)).join("")}
${fab("Agregar jornada", "plus")}
`,
};
