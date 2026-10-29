const { C } = require("../sistema/tokens");
const { fondo, barraEstado } = require("../sistema/base");
const { texto, parrafo } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, boton, campo } = require("../sistema/componentes");

const halos = `
<defs>
  <radialGradient id="haloOro"><stop offset="0" stop-color="${C.primary}" stop-opacity="0.14"/><stop offset="1" stop-color="${C.primary}" stop-opacity="0"/></radialGradient>
  <radialGradient id="haloAzul"><stop offset="0" stop-color="${C.info}" stop-opacity="0.09"/><stop offset="1" stop-color="${C.info}" stop-opacity="0"/></radialGradient>
</defs>
<circle cx="352" cy="120" r="260" fill="url(#haloOro)"/>
<circle cx="30" cy="700" r="300" fill="url(#haloAzul)"/>`;

module.exports = {
  id: "02-login",
  nombre: "Iniciar sesión",
  rol: "Acceso",
  render: () => `
${fondo()}
${barraEstado()}
${halos}
<circle cx="195" cy="146" r="49" fill="${C.primary}" opacity="0.10"/>
<circle cx="195" cy="146" r="41" fill="url(#gold)"/>
${icono("scissors", 177, 128, 37, C.black, 1.7)}
${texto(195, 236, "BARBER KING", { tam: 28, peso: 800, ancla: "middle", espaciado: 5 })}
${texto(195, 260, "Gestión profesional para tu barbería", { tam: 12.5, color: C.subtitle, ancla: "middle" })}
${tarjeta(24, 286, 342, 430, { gradiente: "card" })}
${texto(46, 326, "Bienvenido de nuevo", { tam: 21, peso: 700 })}
${parrafo(46, 350, "Ingresa para gestionar tus citas y servicios.", { tam: 12, ancho: 300, color: C.subtitle })}
${campo(44, 394, 302, { etiqueta: "Correo electrónico", placeholder: "tu@correo.com", icono: "at", valor: "hernando@correo.com" })}
${campo(44, 478, 302, { etiqueta: "Contraseña", placeholder: "••••••••", icono: "lock", der: "eye", valor: "••••••••" })}
${texto(346, 560, "¿Olvidaste tu contraseña?", { tam: 11.5, color: C.primary, peso: 500, ancla: "end" })}
${boton(44, 582, 302, "Iniciar sesión", { icono: "login" })}
<g>
  ${texto(195, 672, "¿Aún no tienes cuenta?", { tam: 12.5, color: C.subtitle, ancla: "middle" })}
  ${texto(195, 692, "Crear cuenta", { tam: 13, peso: 600, color: C.primary, ancla: "middle" })}
</g>
${texto(195, 794, "CORTE  •  ESTILO  •  EXPERIENCIA", { tam: 10, color: C.muted, ancla: "middle", espaciado: 2 })}
`,
};
