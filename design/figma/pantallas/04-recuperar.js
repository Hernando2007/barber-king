const { C } = require("../sistema/tokens");
const { fondo, barraEstado } = require("../sistema/base");
const { texto, parrafo } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, boton, campo } = require("../sistema/componentes");

module.exports = {
  id: "04-recuperar",
  nombre: "Recuperar contraseña",
  rol: "Acceso",
  render: () => `
${fondo()}
${barraEstado()}
<g>
  ${icono("back", 20, 58, 18, C.primary, 2)}
  ${texto(46, 72, "Atrás", { tam: 13, peso: 500, color: C.primary })}
</g>
<circle cx="195" cy="150" r="39" fill="${C.backgroundSoft}" stroke="${C.primary}" stroke-width="1.5"/>
${icono("scissors", 178, 133, 34, C.primary, 1.7)}
${texto(195, 234, "BARBER KING", { tam: 32, peso: 900, color: C.primary, ancla: "middle", familia: "'Playfair Display', Georgia, serif" })}
${texto(195, 260, "Recupera tu contraseña", { tam: 13, color: C.subtitle, ancla: "middle" })}
${tarjeta(20, 292, 350, 300)}
${parrafo(195, 328, "Ingresa tu correo y te enviaremos un código de 6 dígitos para restablecer tu contraseña.", { tam: 12, ancho: 306, color: C.subtitle, ancla: "middle" })}
${campo(38, 400, 314, { etiqueta: "CORREO ELECTRÓNICO", placeholder: "correo@ejemplo.com", icono: "at" })}
${boton(38, 476, 314, "ENVIAR CÓDIGO", { tipo: "primario" })}
${texto(195, 556, "Ya tengo un código", { tam: 12.5, peso: 600, color: C.primary, ancla: "middle" })}
${texto(195, 792, "CORTE  •  ESTILO  •  EXPERIENCIA", { tam: 10, color: C.muted, ancla: "middle", espaciado: 2 })}
`,
};
