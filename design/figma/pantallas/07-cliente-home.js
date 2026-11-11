const { C } = require("../sistema/tokens");
const { fondo, barraEstado, barraInferior, NAV_CLIENTE } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, boton, insignia, fab } = require("../sistema/componentes");

const stat = (x, y, valor, etiqueta, nombreIcono, color) => `
<g>
  ${tarjeta(x, y, 110, 82, { radio: 18 })}
  <g>
    <rect x="${x + 12}" y="${y + 12}" width="30" height="30" rx="9" fill="${color}" opacity="0.13"/>
    ${icono(nombreIcono, x + 18, y + 18, 18, color)}
  </g>
  ${texto(x + 12, y + 62, valor, { tam: 20, peso: 700 })}
  ${texto(x + 12, y + 76, etiqueta, { tam: 9.5, color: C.subtitle })}
</g>`;

const tile = (x, y, etiqueta, nombreIcono) => `
<g>
  ${tarjeta(x, y, 167, 82, { radio: 17 })}
  ${icono(nombreIcono, x + 16, y + 16, 22, C.primary)}
  ${texto(x + 16, y + 62, etiqueta, { tam: 11.5, peso: 600 })}
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
${tarjeta(20, 112, 350, 164, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.32 })}
${texto(40, 138, "TU PRÓXIMA CITA", { tam: 10.5, peso: 600, color: C.primary, espaciado: 1.2 })}
${insignia(276, 126, "Pendiente", { tipo: "warning" })}
${texto(40, 174, "Corte + Barba", { tam: 19, peso: 700 })}
${texto(40, 198, "viernes, 23 de octubre · 15:30", { tam: 12.5, color: C.subtitle })}
${boton(40, 216, 152, "Ver mis citas", { tipo: "contorno", alto: 40, icono: "calendar" })}
${stat(20, 288, "4", "Mis citas", "calendar", C.primary)}
${stat(130, 288, "2", "Completadas", "checkCircle", C.success)}
${stat(240, 288, "5", "Servicios", "scissors", C.info)}
${texto(20, 398, "¿Qué necesitas hoy?", { tam: 18, peso: 600 })}
${texto(20, 418, "Todo a un toque de distancia", { tam: 12, color: C.subtitle })}
${tile(20, 426, "Servicios", "tag")}
${tile(203, 426, "Mi perfil", "user")}
${tarjeta(20, 520, 350, 80, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.35 })}
<rect x="36" y="537" width="46" height="46" rx="15" fill="url(#gold)"/>
${icono("sparkles", 49, 550, 20, C.black)}
${texto(94, 555, "Asesor de estilo con IA", { tam: 14.5, peso: 600 })}
${texto(94, 574, "Toma una foto y descubre qué corte te favorece.", { tam: 11, color: C.subtitle })}
${icono("forward", 340, 552, 18, C.primary)}
${fab("Reservar", "plus", 700)}
${barraInferior("inicio", NAV_CLIENTE)}
`,
};
