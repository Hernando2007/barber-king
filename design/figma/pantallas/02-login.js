const { C } = require("../sistema/tokens");
const { fondo, barraEstado } = require("../sistema/base");
const { texto, parrafo } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { emblema } = require("../sistema/marca");
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
${emblema(195, 132, 38)}
${texto(195, 216, "BARBER KING", { tam: 27, peso: 800, ancla: "middle", espaciado: 5 })}
${texto(195, 238, "Gestión profesional para tu barbería", { tam: 12, color: C.subtitle, ancla: "middle" })}
${tarjeta(24, 262, 342, 452, { gradiente: "card" })}
${texto(46, 300, "Bienvenido de nuevo", { tam: 20, peso: 700 })}
${parrafo(46, 322, "Ingresa para gestionar tus citas y servicios.", { tam: 11.5, ancho: 290, color: C.subtitle })}
${campo(44, 362, 302, { etiqueta: "Correo electrónico", placeholder: "tu@correo.com", icono: "at", valor: "hernando@correo.com" })}
${campo(44, 446, 302, { etiqueta: "Contraseña", placeholder: "••••••••", icono: "lock", der: "eye", valor: "••••••••" })}
${texto(346, 526, "¿Olvidaste tu contraseña?", { tam: 11.5, color: C.primary, peso: 500, ancla: "end" })}
${boton(44, 546, 302, "Iniciar sesión", { icono: "login" })}
${texto(195, 628, "o continúa con", { tam: 11, color: C.muted, ancla: "middle" })}
<line x1="44" y1="624" x2="150" y2="624" stroke="${C.border}"/>
<line x1="240" y1="624" x2="346" y2="624" stroke="${C.border}"/>
${boton(44, 648, 302, "Continuar con Google", { tipo: "contorno", alto: 50, icono: "shield" })}
<g>
  ${texto(112, 742, "¿Aún no tienes cuenta?", { tam: 12.5, color: C.subtitle })}
  ${texto(316, 742, "Crear cuenta", { tam: 13, peso: 600, color: C.primary, ancla: "middle" })}
</g>
${texto(195, 800, "CORTE  •  ESTILO  •  EXPERIENCIA", { tam: 10, color: C.muted, ancla: "middle", espaciado: 2 })}
`,
};
