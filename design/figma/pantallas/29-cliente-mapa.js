const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, insignia, boton } = require("../sistema/componentes");

const CALLES = [140, 210, 280, 350, 420, 490, 560];
const AVENIDAS = [70, 150, 230, 310];

module.exports = {
  id: "29-cliente-mapa",
  nombre: "Ubicación del barbero",
  rol: "Cliente",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Ubicación del barbero", acciones: ["refresh"] })}
<rect x="0" y="112" width="390" height="640" fill="${C.backgroundSoft}"/>
${CALLES.map((y) => `<rect x="0" y="${y}" width="390" height="1.4" fill="${C.border}" opacity="0.9"/>`).join("")}
${AVENIDAS.map((x) => `<rect x="${x}" y="112" width="1.4" height="640" fill="${C.border}" opacity="0.9"/>`).join("")}
<rect x="150" y="112" width="26" height="640" fill="${C.surface}" opacity="0.75"/>
<rect x="0" y="420" width="390" height="22" fill="${C.surface}" opacity="0.75"/>
<circle cx="196" cy="404" r="58" fill="${C.primary}" opacity="0.10"/>
<circle cx="196" cy="404" r="30" fill="${C.primary}" opacity="0.16"/>
<path d="M196 366c-11 0-20 9-20 20 0 15 20 34 20 34s20-19 20-34c0-11-9-20-20-20z" fill="url(#gold)" stroke="${C.background}" stroke-width="1.5"/>
<circle cx="196" cy="386" r="6.5" fill="${C.black}"/>
${insignia(150, 268, "En vivo", { tipo: "success" })}
${tarjeta(20, 566, 350, 246, { radio: 20 })}
${texto(36, 600, "Andrés Ramírez", { tam: 17, peso: 700 })}
${insignia(300, 584, "2.4 km", { tipo: "gold" })}
${texto(36, 620, "Fade · Bogotá, Chapinero", { tam: 12, color: C.subtitle })}
${icono("pin", 36, 642, 18, C.primary)}
${texto(62, 656, "Calle 63 con Carrera 7 · distancia aproximada", { tam: 11.5, color: C.subtitle })}
${texto(36, 684, "Actualizada ahora mismo", { tam: 10.5, color: C.muted })}
${boton(36, 700, 318, "Actualizar", { tipo: "contorno", alto: 44, icono: "refresh" })}
${texto(195, 776, "El barbero comparte su ubicación desde su app mientras está activa.", { tam: 9.5, color: C.muted, ancla: "middle" })}
${texto(195, 792, "Mapa © OpenStreetMap.", { tam: 9.5, color: C.muted, ancla: "middle" })}
`,
};
