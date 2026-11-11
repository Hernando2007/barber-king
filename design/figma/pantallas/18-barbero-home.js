const { C } = require("../sistema/tokens");
const { fondo, barraEstado, barraInferior, NAV_BARBERO } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, insignia, switchControl } = require("../sistema/componentes");

const metrica = (x, y, valor, etiqueta, nombreIcono, color) => `
<g>
  ${tarjeta(x, y, 169, 74, { radio: 18 })}
  <rect x="${x + 14}" y="${y + 12}" width="30" height="30" rx="9" fill="${color}" opacity="0.13"/>
  ${icono(nombreIcono, x + 21, y + 19, 16, color)}
  ${texto(x + 14, y + 58, valor, { tam: 20, peso: 700 })}
  ${texto(x + 52, y + 58, etiqueta, { tam: 10, color: C.subtitle })}
</g>`;

const herramienta = (x, y, etiqueta, nombreIcono) => `
<g>
  ${tarjeta(x, y, 167, 74, { radio: 17 })}
  ${icono(nombreIcono, x + 14, y + 13, 22, C.primary)}
  ${texto(x + 14, y + 56, etiqueta, { tam: 11.5, peso: 600 })}
</g>`;

module.exports = {
  id: "18-barbero-home",
  nombre: "Panel del barbero",
  rol: "Barbero",
  render: () => `
${fondo()}
${barraEstado()}
${texto(20, 62, "PANEL PROFESIONAL", { tam: 10.5, peso: 600, color: C.primary, espaciado: 1.8 })}
${texto(20, 90, "Hola, Marco", { tam: 24, peso: 700 })}
${texto(20, 109, "Fade", { tam: 12, color: C.subtitle })}
${icono("user", 316, 58, 22, C.primary)}
${icono("logout", 352, 58, 22, C.primary)}
${tarjeta(20, 122, 350, 142, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.32 })}
${icono("calendar", 40, 136, 14, C.primary)}
${texto(60, 147, "AGENDA DE HOY", { tam: 10.5, peso: 700, color: C.primary, espaciado: 1.2 })}
${texto(40, 188, "09:00", { tam: 28, peso: 700 })}
${texto(40, 210, "Luis Pérez · Fade", { tam: 12.5, color: C.subtitle })}
${insignia(270, 176, "Pendiente", { tipo: "warning" })}
${texto(346, 240, "Gestionar", { tam: 11.5, peso: 600, color: C.primary, ancla: "end" })}
${icono("forward", 350, 229, 14, C.primary, 2)}
${tarjeta(20, 276, 350, 84, { radio: 18 })}
<rect x="36" y="294" width="40" height="40" rx="12" fill="${C.primary}" opacity="0.13"/>
${icono("pin", 46, 304, 20, C.primary)}
${texto(88, 308, "Ubicación en tiempo real", { tam: 13.5, peso: 600 })}
${texto(88, 326, "Compartiendo · ahora", { tam: 10.5, color: C.muted })}
${switchControl(312, 301, { on: true })}
${texto(36, 348, "Se actualiza cada 3 minutos mientras la app esté abierta.", { tam: 9.5, color: C.muted })}
${metrica(20, 372, "12", "Citas totales", "calendar", C.primary)}
${metrica(201, 372, "3", "Pendientes", "clock", C.warning)}
${metrica(20, 454, "9", "Completadas", "checkCircle", C.success)}
${metrica(201, 454, "4.8", "Calificación", "star", C.primaryLight)}
${texto(20, 560, "Herramientas", { tam: 18, peso: 600 })}
${texto(20, 580, "Gestiona tu día a día", { tam: 12, color: C.subtitle })}
${herramienta(20, 594, "Servicios que atiendo", "tag")}
${herramienta(203, 594, "Mis fotos", "file")}
${herramienta(20, 676, "Mi perfil", "user")}
${herramienta(203, 676, "Asesor IA", "sparkles")}
${barraInferior("inicio", NAV_BARBERO)}
`,
};
