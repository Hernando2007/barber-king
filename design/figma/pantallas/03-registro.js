const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, campo, cuadroIcono, boton } = require("../sistema/componentes");

const tipoCuenta = (x, activo, etiqueta, nombreIcono) => `
<g>
  <rect x="${x}" y="286" width="155" height="90" rx="16" fill="${activo ? C.primary : C.surface}" fill-opacity="${activo ? 0.16 : 1}" stroke="${activo ? C.primary : C.border}" stroke-width="${activo ? 2 : 1}"/>
  ${icono(nombreIcono, x + 63, 302, 28, activo ? C.primary : C.subtitle)}
  ${texto(x + 77.5, 360, etiqueta, { tam: 13, peso: 600, color: activo ? C.primary : C.white, ancla: "middle" })}
</g>`;

module.exports = {
  id: "03-registro",
  nombre: "Crear cuenta",
  rol: "Acceso",
  alto: 1180,
  render: () => `
${fondo("", 1180)}
${barraEstado()}
${appBar({ titulo: "Crear cuenta" })}
${icono("scissors", 172, 124, 46, C.primary, 1.6)}
${texto(195, 200, "ÚNETE A BARBER KING", { tam: 23, peso: 700, color: C.primary, ancla: "middle", espaciado: 2.4 })}
${texto(195, 224, "Crea tu cuenta y vive la experiencia premium.", { tam: 13, color: C.subtitle, ancla: "middle" })}
${tarjeta(20, 248, 350, 900)}
${texto(40, 282, "Tipo de cuenta", { tam: 14, peso: 600 })}
${tipoCuenta(40, true, "Cliente", "user")}
${tipoCuenta(195, false, "Barbero", "scissors")}
<g>
  ${cuadroIcono(40, 396, 30, { icono: "user" })}
  ${texto(80, 416, "Datos personales", { tam: 17, peso: 600 })}
</g>
${campo(40, 446, 310, { etiqueta: "Nombres", placeholder: "Hernando", icono: "user", valor: "Hernando" })}
${campo(40, 526, 310, { etiqueta: "Apellidos", placeholder: "Botello", icono: "file", valor: "Botello" })}
${campo(40, 606, 310, { etiqueta: "Correo electrónico", placeholder: "tu@correo.com", icono: "at", valor: "hernando@correo.com" })}
${campo(40, 686, 310, { etiqueta: "Teléfono", placeholder: "+57 300 000 0000", icono: "phone", valor: "+57 300 456 7890" })}
${campo(40, 766, 310, { etiqueta: "Fecha de nacimiento", placeholder: "aaaa-mm-dd", icono: "calendar", der: "down", valor: "1998-04-16" })}
<g>
  ${cuadroIcono(40, 846, 30, { icono: "lock" })}
  ${texto(80, 866, "Seguridad", { tam: 17, peso: 600 })}
</g>
${campo(40, 896, 310, { etiqueta: "Contraseña", placeholder: "••••••••", icono: "lock", der: "eye" })}
${campo(40, 976, 310, { etiqueta: "Confirmar contraseña", placeholder: "••••••••", icono: "lock", der: "eye" })}
${boton(40, 1046, 310, "CREAR CUENTA", { icono: "user" })}
${texto(195, 1122, "Ya tengo una cuenta", { tam: 12.5, peso: 500, color: C.primary, ancla: "middle" })}
`,
};
