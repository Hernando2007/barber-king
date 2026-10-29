const { C, W } = require("../sistema/tokens");
const { fondo, barraEstado } = require("../sistema/base");
const { texto, parrafo } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, cuadroIcono } = require("../sistema/componentes");
const { compositor } = require("../sistema/chat");

const sugerencia = (y, contenido) => {
  const alto = contenido.length > 38 ? 64 : 50;
  return `<g>
    ${tarjeta(20, y, 350, alto, { radio: 15 })}
    ${icono("chat", 36, y + (alto === 64 ? 24 : 17), 17, C.primary)}
    ${parrafo(64, y + (alto === 64 ? 28 : 30), contenido, { tam: 12.5, ancho: 260 })}
    ${icono("forward", 340, y + alto / 2 - 8, 16, C.muted)}
  </g>`;
};

module.exports = {
  id: "21-chat-ia",
  nombre: "Asistente IA",
  rol: "Cliente",
  render: () => `
${fondo()}
${barraEstado()}
${icono("back", 20, 57, 24, C.white)}
${icono("sparkles", 52, 58, 21, C.primary)}
${texto(82, 80, "Asistente Barber King", { tam: 18, peso: 600, espaciado: -0.2 })}
${icono("refresh", 344, 58, 21, C.white)}
<rect x="126" y="150" width="138" height="138" rx="69" fill="${C.primary}" opacity="0.08"/>
<rect x="156" y="150" width="78" height="78" rx="24" fill="url(#gold)"/>
${icono("sparkles", 177, 171, 36, C.black, 1.6)}
${texto(195, 264, "Tu asesor de estilo personal", { tam: 20, peso: 700, ancla: "middle" })}
${parrafo(195, 288, "Pregunta lo que quieras o sube una foto y la IA te recomendará el corte que mejor va contigo.", { tam: 12.5, ancho: 300, color: C.subtitle, ancla: "middle", linea: 19 })}
${sugerencia(356, "¿Qué corte me recomiendas para cabello rizado?")}
${sugerencia(429, "¿Qué servicios ofrece Barber King?")}
${sugerencia(488, "¿Cómo puedo reservar una cita?")}
${tarjeta(20, 556, 350, 76, { radio: 16, borde: C.primary, opacidadBorde: 0.35 })}
${cuadroIcono(36, 577, 34, { icono: "camera" })}
${texto(82, 592, "Analiza tu foto", { tam: 13, peso: 600 })}
${texto(82, 610, "La IA sugiere el corte ideal para tu rostro.", { tam: 11, color: C.subtitle })}
${icono("forward", 340, 590, 16, C.primary)}
${texto(195, 728, "La IA puede equivocarse. Verifica antes de reservar.", { tam: 9.5, color: C.muted, ancla: "middle" })}
${compositor({ y: 760, placeholder: "Pregunta o sube una foto...", icono: "camera" })}
`,
};
