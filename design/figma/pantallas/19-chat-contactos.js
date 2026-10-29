const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto, recortar } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, campo, avatar } = require("../sistema/componentes");

const contacto = (y, iniciales, nombre, rol, mensaje, fecha) => `
<g>
  ${tarjeta(20, y, 350, 96, { radio: 18 })}
  ${avatar(34, y + 18, 48, { iniciales, activo: true })}
  ${texto(96, y + 32, nombre, { tam: 14.5, peso: 600 })}
  ${texto(346, y + 28, fecha, { tam: 9.5, color: C.muted, ancla: "end" })}
  ${texto(96, y + 50, rol, { tam: 11, peso: 500, color: C.primary })}
  ${texto(96, y + 70, recortar(mensaje, 40), { tam: 11.5, color: C.subtitle })}
  ${icono("forward", 342, y + 40, 16, C.muted)}
</g>`;

module.exports = {
  id: "19-chat-contactos",
  nombre: "Chat · contactos",
  rol: "Cliente",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Chatea con tu barbero", atras: false, acciones: ["refresh"] })}
${texto(20, 120, "Resuelve dudas y agenda tu próxima cita por chat.", { tam: 11.5, color: C.subtitle })}
${campo(20, 144, 350, { placeholder: "Buscar contacto", icono: "search" })}
${contacto(216, "MR", "Marco Ruiz", "Fade", "Perfecto, te espero a las 10:00.", "11 ago")}
${contacto(330, "ST", "Sebastián Torres", "Barba", "¿Tienen disponibilidad el sábado?", "10 ago")}
${contacto(444, "AR", "Andrés Ramírez", "Fade", "Inicia la conversación", "9 ago")}
${texto(195, 806, "Tus conversaciones son privadas.", { tam: 9.5, color: C.muted, ancla: "middle" })}
`,
};
