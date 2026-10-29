const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, campo, areaTexto, boton, switchControl } = require("../sistema/componentes");

module.exports = {
  id: "17-servicio-form",
  nombre: "Editar servicio",
  rol: "Administrador",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Editar servicio" })}
${tarjeta(20, 112, 350, 88, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.3 })}
<rect x="36" y="132" width="48" height="48" rx="14" fill="url(#gold)"/>
${icono("scissors", 49, 145, 22, C.black)}
${texto(96, 152, "Actualiza la información", { tam: 14, peso: 600 })}
${texto(96, 172, "del servicio", { tam: 14, peso: 600 })}
${campo(20, 230, 350, { etiqueta: "Nombre del servicio", valor: "Fade", icono: "scissors" })}
${areaTexto(20, 310, 350, { etiqueta: "Descripción", valor: "Corte Fade profesional con perfilado y acabado premium.", alto: 104 })}
${campo(20, 442, 167, { etiqueta: "Precio", valor: "$ 30.000", icono: "wallet" })}
${campo(203, 442, 167, { etiqueta: "Duración", valor: "45 min", icono: "clock" })}
${campo(20, 522, 350, { etiqueta: "Tiempo de descanso", valor: "10 min", icono: "clock" })}
${texto(22, 586, "Tiempo entre citas. Opcional.", { tam: 10, color: C.muted })}
${tarjeta(20, 600, 350, 64, { radio: 16 })}
${texto(36, 624, "Servicio activo", { tam: 13.5, peso: 600 })}
${texto(36, 642, "Los servicios inactivos no aparecen en las reservas.", { tam: 9.5, color: C.muted })}
${switchControl(310, 619, { on: true })}
${boton(20, 692, 350, "GUARDAR CAMBIOS", { icono: "check" })}
${texto(195, 790, "Los cambios se reflejan de inmediato en el catálogo.", { tam: 9.5, color: C.muted, ancla: "middle" })}
`,
};
