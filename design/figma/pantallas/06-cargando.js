const { C } = require("../sistema/tokens");
const { fondo, barraEstado } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { emblema } = require("../sistema/marca");

module.exports = {
  id: "06-cargando",
  nombre: "Cargando sesión",
  rol: "Acceso",
  render: () => `
${fondo()}
${barraEstado()}
${emblema(195, 380, 38)}
<circle cx="195" cy="470" r="22" fill="none" stroke="${C.border}" stroke-width="3"/>
<path d="M195 448a22 22 0 0 1 19 11" fill="none" stroke="${C.primary}" stroke-width="3" stroke-linecap="round"/>
${texto(195, 528, "Cargando tu experiencia…", { tam: 13, color: C.subtitle, ancla: "middle" })}
`,
};
