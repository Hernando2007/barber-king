const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, avatar, insignia, boton, filaInfo } = require("../sistema/componentes");

module.exports = {
  id: "13-perfil",
  nombre: "Mi perfil",
  rol: "Cliente",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Mi perfil", atras: false, acciones: ["edit"] })}
${tarjeta(20, 112, 350, 240, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.3 })}
${avatar(149, 134, 92, { iniciales: "CR", borde: C.primary })}
<g>
  <circle cx="233" cy="210" r="16" fill="${C.primary}" stroke="${C.background}" stroke-width="3"/>
  ${icono("camera", 224, 201, 18, C.black)}
</g>
${texto(195, 260, "Camila Rodríguez", { tam: 21, peso: 700, ancla: "middle" })}
${insignia(169, 272, "Cliente", { tipo: "gold" })}
${boton(56, 306, 128, "Editar", { tipo: "contorno", alto: 40, icono: "edit" })}
${boton(194, 306, 140, "Contraseña", { tipo: "contorno", alto: 40, icono: "lock" })}
${texto(24, 382, "Información personal", { tam: 15.5, peso: 600 })}
${filaInfo(20, 398, 350, { etiqueta: "Correo electrónico", valor: "camila.rodriguez@gmail.com" })}
${filaInfo(20, 456, 350, { etiqueta: "Teléfono", valor: "+57 310 456 7890" })}
${filaInfo(20, 514, 350, { etiqueta: "Fecha de nacimiento", valor: "12 mar 1996" })}
${filaInfo(20, 572, 350, { etiqueta: "Estado de la cuenta", valor: "Activa", color: C.success })}
${texto(24, 656, "Sesión", { tam: 15.5, peso: 600 })}
${boton(20, 674, 350, "CERRAR SESIÓN", { tipo: "peligro", icono: "logout" })}
${texto(195, 792, "BARBER KING  ·  v1.0.0", { tam: 9.5, color: C.muted, ancla: "middle", espaciado: 1.4 })}
`,
};
