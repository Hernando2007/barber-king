const { C } = require("../sistema/tokens");
const { fondo, barraEstado } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, boton, insignia, fab } = require("../sistema/componentes");

const stat = (x, valor, etiqueta, nombreIcono, color) => `
<g>
  ${tarjeta(x, 300, 110, 88, { radio: 18 })}
  <g>
    <rect x="${x + 12}" y="312" width="30" height="30" rx="9" fill="${color}" opacity="0.13"/>
    ${icono(nombreIcono, x + 18, 318, 18, color)}
  </g>
  ${texto(x + 12, 366, valor, { tam: 21, peso: 700 })}
  ${texto(x + 12, 382, etiqueta, { tam: 10, color: C.subtitle })}
</g>`;

const tile = (x, y, etiqueta, nombreIcono) => `
<g>
  ${tarjeta(x, y, 167, 88, { radio: 17 })}
  ${icono(nombreIcono, x + 16, y + 18, 22, C.primary)}
  ${texto(x + 16, y + 64, etiqueta, { tam: 11.5, peso: 600 })}
</g>`;

module.exports = {
  id: "07-cliente-home",
  nombre: "Inicio cliente",
  rol: "Cliente",
  render: () => `
${fondo()}
${barraEstado()}
${texto(20, 62, "BUENAS TARDES", { tam: 11, peso: 600, color: C.primary, espaciado: 1.8 })}
${texto(20, 92, "Hola, Camila", { tam: 26, peso: 700 })}
${icono("user", 316, 58, 22, C.primary)}
${icono("logout", 352, 58, 22, C.primary)}
${tarjeta(20, 112, 350, 172, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.32 })}
${texto(40, 140, "TU PRÓXIMA CITA", { tam: 10.5, peso: 600, color: C.primary, espaciado: 1.2 })}
${insignia(276, 128, "Pendiente", { tipo: "warning" })}
${texto(40, 176, "Corte + Barba", { tam: 19, peso: 700 })}
${texto(40, 200, "viernes, 23 de octubre · 15:30", { tam: 12.5, color: C.subtitle })}
${boton(40, 220, 152, "Ver mis citas", { tipo: "contorno", alto: 40, icono: "calendar" })}
${stat(20, "4", "Mis citas", "calendar", C.primary)}
${stat(130, "2", "Completadas", "checkCircle", C.success)}
${stat(240, "5", "Servicios", "scissors", C.info)}
${texto(20, 424, "¿Qué necesitas hoy?", { tam: 18, peso: 600 })}
${texto(20, 446, "Todo a un toque de distancia", { tam: 12, color: C.subtitle })}
${tile(20, 462, "Reservar cita", "calendar")}
${tile(203, 462, "Nuestros barberos", "scissors")}
${tile(20, 554, "Servicios", "tag")}
${tile(203, 554, "Mis citas", "clock")}
${tile(20, 646, "Chat con barbero", "chat")}
${tile(203, 646, "Mi perfil", "user")}
${fab("Reservar", "plus")}
`,
};
