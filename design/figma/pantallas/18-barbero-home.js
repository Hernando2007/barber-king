const { C } = require("../sistema/tokens");
const { fondo, barraEstado } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, insignia, switchControl } = require("../sistema/componentes");

const metrica = (x, y, valor, etiqueta, nombreIcono, color) => `
<g>
  ${tarjeta(x, y, 169, 82, { radio: 18 })}
  <rect x="${x + 14}" y="${y + 13}" width="32" height="32" rx="10" fill="${color}" opacity="0.13"/>
  ${icono(nombreIcono, x + 22, y + 21, 16, color)}
  ${texto(x + 14, y + 62, valor, { tam: 21, peso: 700 })}
  ${texto(x + 14, y + 78, etiqueta, { tam: 10, color: C.subtitle })}
</g>`;

const herramienta = (x, y, etiqueta, nombreIcono, badge) => `
<g>
  ${tarjeta(x, y, 167, 76, { radio: 17 })}
  ${icono(nombreIcono, x + 14, y + 14, 22, C.primary)}
  ${texto(x + 14, y + 54, etiqueta, { tam: 11.5, peso: 600 })}
  ${badge ? `<rect x="${x + 132}" y="${y + 12}" width="22" height="18" rx="9" fill="${C.error}"/>${texto(x + 143, y + 25, badge, { tam: 9, peso: 700, color: C.white, ancla: "middle" })}` : ""}
</g>`;

module.exports = {
  id: "18-barbero-home",
  nombre: "Panel del barbero",
  rol: "Barbero",
  render: () => `
${fondo()}
${barraEstado()}
${texto(20, 62, "PANEL PROFESIONAL", { tam: 10.5, peso: 600, color: C.primary, espaciado: 1.8 })}
${texto(20, 92, "Hola, Marco", { tam: 25, peso: 700 })}
${texto(20, 112, "Fade", { tam: 12, color: C.subtitle })}
${icono("user", 316, 58, 22, C.primary)}
${icono("logout", 352, 58, 22, C.primary)}
${tarjeta(20, 128, 350, 160, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.32 })}
${icono("calendar", 40, 142, 14, C.primary)}
${texto(60, 153, "AGENDA DE HOY", { tam: 10.5, peso: 700, color: C.primary, espaciado: 1.2 })}
${icono("forward", 332, 142, 18, C.primary)}
${texto(40, 196, "09:00", { tam: 30, peso: 700 })}
${texto(40, 218, "Luis Pérez · Fade", { tam: 12.5, color: C.subtitle })}
${insignia(278, 180, "Pendiente", { tipo: "warning" })}
${texto(338, 240, "Gestionar", { tam: 11.5, peso: 600, color: C.primary, ancla: "end" })}
${icono("forward", 342, 229, 14, C.primary, 2)}
${tarjeta(20, 302, 350, 112, { radio: 18 })}
<rect x="36" y="324" width="40" height="40" rx="12" fill="${C.primary}" opacity="0.13"/>
${icono("pin", 46, 334, 20, C.primary)}
${texto(88, 338, "Ubicación en tiempo real", { tam: 13.5, peso: 600 })}
${texto(88, 356, "Compartiendo · ahora", { tam: 10.5, color: C.muted })}
${switchControl(312, 329, { on: true })}
${texto(36, 382, "Se actualiza cada 3 minutos mientras la app esté abierta.", { tam: 10, color: C.muted })}
${texto(36, 396, "Los clientes solo ven la distancia aproximada.", { tam: 10, color: C.muted })}
${metrica(20, 424, "12", "Citas totales", "calendar", C.primary)}
${metrica(201, 424, "3", "Pendientes", "clock", C.warning)}
${metrica(20, 512, "9", "Completadas", "checkCircle", C.success)}
${metrica(201, 512, "4.8", "Calificación", "star", C.primaryLight)}
${texto(20, 626, "Herramientas", { tam: 18, peso: 600 })}
${texto(20, 646, "Gestiona tu día a día", { tam: 12, color: C.subtitle })}
${herramienta(20, 664, "Mis citas", "calendar")}
${herramienta(203, 664, "Chats de clientes", "chat", "9+")}
${herramienta(20, 750, "Mis horarios", "clock")}
${herramienta(203, 750, "Servicios", "tag")}
`,
};
