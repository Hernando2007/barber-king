const { C } = require("../sistema/tokens");
const { fondo, barraEstado } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");

const halos = `
<defs>
  <radialGradient id="haloOro"><stop offset="0" stop-color="${C.primary}" stop-opacity="0.18"/><stop offset="1" stop-color="${C.primary}" stop-opacity="0"/></radialGradient>
  <radialGradient id="haloAzul"><stop offset="0" stop-color="${C.info}" stop-opacity="0.10"/><stop offset="1" stop-color="${C.info}" stop-opacity="0"/></radialGradient>
</defs>
<circle cx="336" cy="96" r="270" fill="url(#haloOro)"/>
<circle cx="46" cy="720" r="300" fill="url(#haloAzul)"/>`;

module.exports = {
  id: "01-splash",
  nombre: "Splash",
  rol: "Acceso",
  render: () => `
${fondo()}
${barraEstado()}
${halos}
<circle cx="195" cy="330" r="66" fill="${C.primary}" opacity="0.10"/>
<circle cx="195" cy="330" r="54" fill="url(#gold)"/>
<circle cx="195" cy="330" r="62" fill="none" stroke="${C.primary}" stroke-opacity="0.35"/>
${icono("scissors", 171, 306, 48, C.black, 1.6)}
${texto(195, 458, "BARBER KING", { tam: 29, peso: 800, ancla: "middle", espaciado: 5.5 })}
${texto(195, 486, "CORTE  •  ESTILO  •  EXPERIENCIA", { tam: 10.5, color: C.subtitle, ancla: "middle", espaciado: 2.4 })}
<rect x="151" y="742" width="88" height="3" rx="1.5" fill="${C.border}"/>
<rect x="151" y="742" width="40" height="3" rx="1.5" fill="${C.primary}"/>
${texto(195, 780, "GESTIÓN PROFESIONAL PARA TU BARBERÍA", { tam: 9, color: C.muted, ancla: "middle", espaciado: 1.6 })}
`,
};
