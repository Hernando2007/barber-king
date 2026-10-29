const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto, parrafo } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, campo, avatar, insignia, boton } = require("../sistema/componentes");

const filaTop = (y, posicion, nombre, ciudad, nota, resenas) => `
<g>
  <circle cx="51" cy="${y}" r="11" fill="${posicion === 1 ? C.primary : C.surfaceAlt}" stroke="${posicion === 1 ? C.primary : C.border}"/>
  ${texto(51, y + 4, String(posicion), { tam: 10.5, peso: 700, color: posicion === 1 ? C.black : C.subtitle, ancla: "middle" })}
  ${avatar(72, y - 16, 32, { iniciales: nombre.split(" ").map((p) => p[0]).join("").slice(0, 2) })}
  ${texto(112, y - 3, nombre, { tam: 12.5, peso: 500 })}
  ${texto(112, y + 11, ciudad, { tam: 10, color: C.muted })}
  ${icono("star", 280, y - 7, 12, C.primary, 0)}
  ${texto(346, y + 3, `${nota} (${resenas})`, { tam: 11.5, peso: 600, color: C.primary, ancla: "end" })}
</g>`;

module.exports = {
  id: "08-barberos",
  nombre: "Nuestros barberos",
  rol: "Cliente",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Nuestros barberos", atras: false, acciones: ["refresh"] })}
${tarjeta(20, 112, 350, 176)}
${icono("award", 36, 122, 20, C.primary)}
${texto(64, 138, "Mejor calificados", { tam: 15, peso: 600 })}
${texto(64, 154, "Elegidos por los clientes", { tam: 10.5, color: C.muted })}
${icono("star", 336, 122, 14, C.primary, 0)}
${filaTop(182, 1, "Sebastián Torres", "Bogotá, Zona T", "4.9", 86)}
${filaTop(218, 2, "Andrés Ramírez", "Bogotá, Chapinero", "4.8", 124)}
${filaTop(254, 3, "Mateo Herrera", "Bogotá, Cedritos", "4.7", 41)}
${campo(20, 304, 286, { placeholder: "Buscar barbero o zona", icono: "search" })}
<rect x="318" y="304" width="52" height="52" rx="14" fill="${C.primary}" opacity="0.13"/>
${icono("pin", 333, 319, 22, C.primary)}
${texto(20, 380, "Barberos a menos de 15 km de tu ubicación.", { tam: 11.5, color: C.subtitle })}
${tarjeta(20, 394, 350, 288)}
${avatar(36, 412, 58, { iniciales: "AR", activo: true })}
${texto(108, 432, "Andrés Ramírez", { tam: 16, peso: 600 })}
${texto(108, 452, "Fade", { tam: 12, peso: 500, color: C.primary })}
${icono("star", 108, 466, 12, C.primary, 0)}
${texto(124, 477, "4.8 (124)", { tam: 11.5, peso: 600, color: C.primary })}
${icono("pin", 108, 484, 12, C.muted)}
${texto(124, 495, "Bogotá, Chapinero · a 2.4 km", { tam: 10.5, color: C.subtitle })}
${texto(108, 515, "7 años de experiencia", { tam: 10.5, color: C.muted })}
${insignia(284, 408, "Disponible", { tipo: "success" })}
${parrafo(36, 548, "Especialista en fades y diseños personalizados. Trabaja con productos premium para cuidar tu estilo.", { tam: 12, ancho: 318, color: C.subtitle })}
${boton(36, 620, 150, "Chatear", { tipo: "contorno", alto: 44, icono: "chat" })}
${boton(194, 620, 160, "Reservar", { alto: 44, icono: "calendar" })}
${tarjeta(20, 694, 350, 288)}
${avatar(36, 712, 58, { iniciales: "JP", activo: true })}
${texto(108, 732, "Juan Pablo Gómez", { tam: 16, peso: 600 })}
${texto(108, 752, "Corte clásico", { tam: 12, peso: 500, color: C.primary })}
${icono("star", 108, 766, 12, C.primary, 0)}
${texto(124, 777, "4.6 (58)", { tam: 11.5, peso: 600, color: C.primary })}
`,
};
