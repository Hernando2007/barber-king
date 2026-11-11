const { C, W, H } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, selector, campo, switchControl, boton } = require("../sistema/componentes");

// La hoja "Nueva jornada" abierta sobre la pantalla de horarios.
module.exports = {
  id: "28-barbero-jornada",
  nombre: "Nueva jornada",
  rol: "Barbero",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Mis horarios", atras: false, acciones: ["refresh"] })}
${texto(24, 138, "Tu semana de trabajo", { tam: 24, peso: 700 })}
${texto(24, 162, "Define los días y horas en que tus", { tam: 12.5, color: C.subtitle })}
<rect x="0" y="0" width="${W}" height="${H}" fill="${C.black}" opacity="0.6"/>
${tarjeta(0, 300, W, 544, { relleno: C.card, borde: C.borderStrong, radio: 26 })}
<rect x="${W / 2 - 18}" y="318" width="36" height="4" rx="2" fill="${C.borderStrong}"/>
${texto(24, 360, "Nueva jornada", { tam: 19, peso: 700 })}
${texto(24, 382, "Elige el día y el rango de atención.", { tam: 12, color: C.subtitle })}
${selector(20, 424, 350, { etiqueta: "Día de trabajo", valor: "Miércoles", icono: "calendar" })}
${campo(20, 508, 167, { etiqueta: "Hora de inicio", valor: "14:00", icono: "clock", alto: 54 })}
${campo(203, 508, 167, { etiqueta: "Hora de fin", valor: "19:00", icono: "clock", alto: 54 })}
${tarjeta(20, 592, 350, 62, { radio: 16 })}
${texto(36, 616, "Jornada activa", { tam: 13.5, peso: 600 })}
${texto(36, 634, "Los clientes solo pueden reservar en jornadas activas.", { tam: 9.5, color: C.muted })}
${switchControl(310, 610, { on: true })}
${boton(20, 676, 350, "Crear jornada", { icono: "check" })}
${texto(195, 754, "Cancelar", { tam: 13, peso: 500, color: C.subtitle, ancla: "middle" })}
`,
};
