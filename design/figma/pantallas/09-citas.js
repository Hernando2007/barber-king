const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto, anchoTexto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, chip, insignia, boton, fab } = require("../sistema/componentes");

const FILTROS = [
  { t: "Todas", on: true },
  { t: "Pendiente" },
  { t: "Confirmada" },
  { t: "Completada" },
  { t: "Cancelada" },
];

const filaChips = () => {
  let x = 20;
  return FILTROS.map((f) => {
    const ancho = anchoTexto(f.t, 11.5) + 12;
    const svg = chip(x, 112, f.t, { activo: f.on, ancho });
    x += ancho + 4;
    return svg;
  }).join("");
};

const dato = (x, y, etiqueta, valor) => `
<g>
  <rect x="${x}" y="${y}" width="98" height="50" rx="11" fill="${C.surface}"/>
  ${texto(x + 11, y + 18, etiqueta, { tam: 9.5, color: C.muted })}
  ${texto(x + 11, y + 38, valor, { tam: 11.5, peso: 600 })}
</g>`;

const cita = (y, nombre, servicio, estado, tipo, iconoColor, fecha, hora, precio) => `
<g>
  ${tarjeta(20, y, 350, 184)}
  <g>
    <rect x="36" y="${y + 16}" width="44" height="44" rx="13" fill="${iconoColor}" opacity="0.13"/>
    ${icono("calendar", 48, y + 28, 20, iconoColor)}
  </g>
  ${texto(94, y + 34, nombre, { tam: 15, peso: 600 })}
  ${texto(94, y + 53, servicio, { tam: 12, color: C.subtitle })}
  ${insignia(274, y + 18, estado, { tipo })}
  ${dato(36, y + 68, "Fecha", fecha)}
  ${dato(134, y + 68, "Hora", hora)}
  ${dato(232, y + 68, "Precio", precio)}
  ${boton(36, y + 130, 152, "Barbero", { tipo: "contorno", alto: 40, icono: "chat" })}
  ${boton(202, y + 130, 152, "Cancelar", { tipo: "peligro", alto: 40 })}
</g>`;

module.exports = {
  id: "09-citas",
  nombre: "Mis citas",
  rol: "Cliente",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Mis citas", atras: false, acciones: ["refresh"] })}
${filaChips()}
${cita(158, "Andrés Ramírez", "Corte + Barba", "Confirmada", "success", C.success, "23 oct 2026", "15:30", "$ 40.000")}
${cita(356, "Sebastián Torres", "Fade", "Pendiente", "warning", C.warning, "24 oct 2026", "10:00", "$ 30.000")}
${cita(554, "Mateo Herrera", "Corte Clásico", "Completada", "neutral", C.info, "18 oct 2026", "09:00", "$ 20.000")}
${fab("Nueva cita", "plus")}
`,
};
