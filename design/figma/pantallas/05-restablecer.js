const { C } = require("../sistema/tokens");
const { fondo, barraEstado } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, boton, campo } = require("../sistema/componentes");

module.exports = {
  id: "05-restablecer",
  nombre: "Nueva contraseña",
  rol: "Acceso",
  render: () => `
${fondo()}
${barraEstado()}
<g>
  ${icono("back", 20, 58, 18, C.primary, 2)}
  ${texto(46, 72, "Atrás", { tam: 13, peso: 500, color: C.primary })}
</g>
<circle cx="195" cy="126" r="33" fill="${C.backgroundSoft}" stroke="${C.primary}" stroke-width="1.5"/>
${icono("scissors", 180, 111, 30, C.primary, 1.7)}
${texto(195, 198, "BARBER KING", { tam: 27, peso: 900, color: C.primary, ancla: "middle", familia: "'Playfair Display', Georgia, serif" })}
${texto(195, 222, "Crea tu nueva contraseña", { tam: 13, color: C.subtitle, ancla: "middle" })}
${tarjeta(20, 250, 350, 462)}
${campo(38, 292, 314, { etiqueta: "CORREO ELECTRÓNICO", placeholder: "correo@ejemplo.com", icono: "at", valor: "hernando@correo.com" })}
${campo(38, 372, 314, { etiqueta: "CÓDIGO DE 6 DÍGITOS", placeholder: "123456", icono: "pin", valor: "482913" })}
${campo(38, 452, 314, { etiqueta: "NUEVA CONTRASEÑA", placeholder: "••••••••", icono: "lock", der: "eye", valor: "••••••••" })}
${campo(38, 532, 314, { etiqueta: "CONFIRMAR CONTRASEÑA", placeholder: "••••••••", icono: "lock", der: "eye", valor: "••••••••" })}
${boton(38, 616, 314, "CAMBIAR CONTRASEÑA")}
${texto(195, 792, "CORTE  •  ESTILO  •  EXPERIENCIA", { tam: 10, color: C.muted, ancla: "middle", espaciado: 2 })}
`,
};
