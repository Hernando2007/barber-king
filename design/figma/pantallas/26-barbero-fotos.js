const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, insignia, boton, chip } = require("../sistema/componentes");

// Una celda de la cuadrícula: o una foto publicada, o una pendiente de subir.
const celda = (x, y, etiqueta, o = {}) => `
<g>
  ${tarjeta(x, y, 167, 150, { radio: 16, relleno: o.publicada ? C.surface : C.surfaceAlt, borde: o.nueva ? C.primary : C.border, opacidadBorde: o.nueva ? 0.6 : 1 })}
  <rect x="${x + 42}" y="${y + 34}" width="84" height="60" rx="12" fill="${o.publicada ? C.card : C.surface}" stroke="${C.border}"/>
  ${icono(o.publicada ? "scissors" : "upload", x + 70, y + 50, 26, o.publicada ? C.primary : C.muted)}
  ${texto(x + 83.5, y + 122, etiqueta, { tam: 10, color: C.subtitle, ancla: "middle" })}
  ${o.nueva ? insignia(x + 8, y + 8, "NUEVA", { tipo: "gold" }) : ""}
  ${icono(o.nueva ? "close" : "trash", x + 138, y + 10, 18, o.nueva ? C.primary : C.muted)}
</g>`;

module.exports = {
  id: "26-barbero-fotos",
  nombre: "Mis fotos",
  rol: "Barbero",
  alto: 1080,
  render: () => `
${fondo("", 1080)}
${barraEstado()}
${appBar({ titulo: "Mis fotos", atras: false, acciones: ["refresh"] })}
${texto(24, 138, "Tu trabajo, a la vista", { tam: 24, peso: 700 })}
${texto(24, 162, "El cliente reserva por lo que ve. Muestra cortes reales:", { tam: 12, color: C.subtitle })}
${texto(24, 180, "barba, degradados y diseño.", { tam: 12, color: C.subtitle })}
${chip(20, 200, "6 de 24", { alto: 32, ancho: 84, icono: "image" })}
${boton(164, 196, 206, "AGREGAR FOTOS", { alto: 40, radio: 14, icono: "plus" })}
${celda(20, 252, "Fade alto", { publicada: true })}
${celda(203, 252, "Barba perfilada", { publicada: true })}
${celda(20, 410, "Corte clásico", { publicada: true })}
${celda(203, 410, "Diseño lateral", { publicada: true })}
${celda(20, 568, "Pendiente 1", { nueva: true })}
${celda(203, 568, "Pendiente 2", { nueva: true })}
${boton(20, 748, 350, "PUBLICAR 2 FOTOS", { icono: "upload" })}
${boton(20, 816, 350, "Descartar la selección", { tipo: "contorno", icono: "close" })}
${texto(195, 890, "Subes máximo 6 fotos por envío y hasta 24 en total.", { tam: 10.5, color: C.muted, ancla: "middle" })}
${texto(195, 908, "Cada foto se guarda en Cloudinary y aparece en tu perfil.", { tam: 10.5, color: C.muted, ancla: "middle" })}
`,
};
