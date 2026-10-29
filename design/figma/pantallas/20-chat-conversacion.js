const { C } = require("../sistema/tokens");
const { fondo, barraEstado, divisor } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { avatar } = require("../sistema/componentes");
const { burbuja, compositor, separadorFecha } = require("../sistema/chat");

module.exports = {
  id: "20-chat-conversacion",
  nombre: "Chat · conversación",
  rol: "Cliente",
  render: () => {
    const mensajes = [
      { texto: "Hola Marco, ¿tienes espacio para un fade el viernes?", hora: "10:02", propio: false },
      { texto: "¡Claro! Tengo 10:00 y 15:30.", hora: "10:04", propio: true },
      { texto: "Listo, te espero a las 10:00.", hora: "10:04", propio: false },
      { texto: "Perfecto, 10:00.", hora: "10:05", propio: true },
      { texto: "Puedes confirmar la cita desde Mis citas.", hora: "10:06", propio: false },
      { texto: "Listo, ya la confirmé. ¡Gracias!", hora: "10:07", propio: true },
    ];
    let y = 148;
    const svg = mensajes
      .map((m) => {
        const b = burbuja({ ...m, y });
        y += b.alto + 10;
        return b.svg;
      })
      .join("");

    return `
${fondo()}
${barraEstado()}
${icono("back", 20, 57, 24, C.white)}
${avatar(56, 52, 36, { iniciales: "MR", activo: true })}
${texto(102, 70, "Marco Ruiz", { tam: 14.5, peso: 600 })}
${texto(102, 87, "Fade · en línea", { tam: 10, color: C.muted })}
${icono("more", 344, 60, 20, C.subtitle)}
${divisor(0, 108, 390)}
${separadorFecha(128, "HOY")}
${svg}
${compositor({ y: 760 })}
`;
  },
};
