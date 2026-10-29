const { C } = require("../sistema/tokens");
const { fondo, barraEstado } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");

module.exports = {
  id: "06-cargando",
  nombre: "Cargando sesión",
  rol: "Acceso",
  render: () => `
${fondo()}
${barraEstado()}
<circle cx="195" cy="380" r="40" fill="${C.surface}" stroke="${C.border}"/>
${icono("scissors", 176, 361, 38, C.primary, 1.7)}
<circle cx="195" cy="470" r="22" fill="none" stroke="${C.border}" stroke-width="3"/>
<path d="M195 448a22 22 0 0 1 19 11" fill="none" stroke="${C.primary}" stroke-width="3" stroke-linecap="round"/>
${texto(195, 528, "Cargando tu experiencia…", { tam: 13, color: C.subtitle, ancla: "middle" })}
`,
};
