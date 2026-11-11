const { C, W } = require("../sistema/tokens");
const { fondo, barraEstado, appBar, barraInferior, NAV_BARBERO } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, insignia, boton, avatar } = require("../sistema/componentes");

// Semana del 2 al 8 de noviembre de 2026; el jueves 5 es el día abierto.
const DIAS = [
  { l: "L", n: 2 },
  { l: "M", n: 3 },
  { l: "X", n: 4 },
  { l: "J", n: 5, on: true, carga: 2 },
  { l: "V", n: 6, carga: 1 },
  { l: "S", n: 7, carga: 2 },
  { l: "D", n: 8 },
];

const semana = () => {
  const x0 = 36;
  const ancho = 45.4;
  return `
<g>
  ${texto(20, 124, "Noviembre 2026", { tam: 15, peso: 600 })}
  ${texto(W - 24, 124, "Hoy", { tam: 11.5, peso: 600, color: C.primary, ancla: "end" })}
  ${icono("back", 6, 156, 20, C.subtitle)}
  ${icono("forward", 364, 156, 20, C.subtitle)}
  ${DIAS.map((d, i) => {
    const x = x0 + i * ancho;
    const cx = x + ancho / 2;
    return `<g>
      <rect x="${x + 2}" y="136" width="${ancho - 4}" height="60" rx="15" fill="${d.on ? "url(#gold)" : C.surface}" stroke="${d.on ? C.primary : C.border}"/>
      ${texto(cx, 154, d.l, { tam: 10.5, peso: 600, color: d.on ? C.black : C.muted, ancla: "middle" })}
      ${texto(cx, 174, String(d.n), { tam: 15, peso: 700, color: d.on ? C.black : C.white, ancla: "middle" })}
      ${d.carga ? `<circle cx="${cx}" cy="185" r="2.5" fill="${d.on ? C.black : C.primary}"/>` : ""}
    </g>`;
  }).join("")}
</g>`;
};

const resumen = () => `
<g>
  ${tarjeta(20, 208, 350, 104, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.35, radio: 20 })}
  ${texto(36, 236, "Jueves, 5 de noviembre", { tam: 16, peso: 700 })}
  ${texto(36, 254, "2 reservas en el día", { tam: 12, color: C.subtitle })}
  <rect x="272" y="222" width="82" height="30" rx="12" fill="${C.surface}" stroke="${C.primary}" stroke-opacity="0.3"/>
  ${icono("wallet", 282, 230, 14, C.primary)}
  ${texto(302, 242, "$ 70.000", { tam: 12.5, peso: 700, color: C.primary })}
  ${texto(48, 288, "1", { tam: 20, peso: 700, color: C.warning })}
  ${texto(48, 304, "Por confirmar", { tam: 10.5, color: C.subtitle })}
  <rect x="140" y="276" width="1" height="32" fill="${C.border}"/>
  ${texto(164, 288, "1", { tam: 20, peso: 700, color: C.info })}
  ${texto(164, 304, "Confirmadas", { tam: 10.5, color: C.subtitle })}
  <rect x="256" y="276" width="1" height="32" fill="${C.border}"/>
  ${texto(280, 288, "0", { tam: 20, peso: 700, color: C.success })}
  ${texto(280, 304, "Completadas", { tam: 10.5, color: C.subtitle })}
</g>`;

const cita = (y, nombre, iniciales, servicio, minutos, estado, tipo, color, precio, accion, iconoAccion) => `
<g>
  ${texto(68, y + 18, y === 376 ? "09:00" : "11:00", { tam: 12.5, peso: 700, ancla: "end" })}
  ${texto(68, y + 32, y === 376 ? "09:30" : "11:45", { tam: 10, color: C.muted, ancla: "end" })}
  <circle cx="77" cy="${y + 14}" r="5" fill="${color}" stroke="${C.background}" stroke-width="2"/>
  ${tarjeta(86, y, 284, 140, { radio: 16, borde: tipo === "warning" ? C.warning : C.border, opacidadBorde: tipo === "warning" ? 0.45 : 1 })}
  ${avatar(98, y + 12, 36, { iniciales })}
  ${texto(142, y + 28, nombre, { tam: 14, peso: 600 })}
  ${texto(142, y + 44, `${servicio} · ${minutos} min`, { tam: 11.5, color: C.subtitle })}
  ${insignia(y === 376 ? 282 : 272, y + 14, estado, { tipo })}
  ${texto(98, y + 72, precio, { tam: 13, peso: 700, color: C.primary })}
  ${boton(98, y + 86, 220, accion, { alto: 40, icono: iconoAccion })}
  ${icono("more", 336, y + 96, 20, C.subtitle)}
</g>`;

module.exports = {
  id: "24-barbero-agenda",
  nombre: "Agenda del barbero",
  rol: "Barbero",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Mi agenda", atras: false, acciones: ["refresh", "calendar"] })}
${semana()}
${resumen()}
${texto(20, 342, "Línea de tiempo", { tam: 15.5, peso: 600 })}
${texto(20, 360, "2 reservas", { tam: 12, color: C.subtitle })}
${texto(W - 24, 342, "Ocultar cerradas", { tam: 11.5, peso: 500, color: C.primary, ancla: "end" })}
<rect x="76" y="380" width="2" height="310" fill="${C.border}"/>
${cita(376, "Luis Pérez", "LP", "Fade", 30, "Pendiente", "warning", C.warning, "$ 30.000", "Confirmar", "checkCircle")}
${icono("clock", 86, 524, 12, C.muted)}
${texto(104, 534, "90 min libres", { tam: 10.5, color: C.muted })}
${cita(544, "Andrés Gómez", "AG", "Corte + Barba", 45, "Confirmada", "success", C.success, "$ 40.000", "Completar", "check")}
${texto(68, 704, "14:32", { tam: 11, peso: 700, color: C.primary, ancla: "end" })}
<circle cx="77" cy="700" r="6" fill="${C.primary}" stroke="${C.background}" stroke-width="2"/>
${texto(92, 704, "Ahora", { tam: 11, peso: 700, color: C.primary })}
<rect x="128" y="699" width="242" height="1" fill="${C.primary}" opacity="0.35"/>
${barraInferior("agenda", NAV_BARBERO)}
`,
};