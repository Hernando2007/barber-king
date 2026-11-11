const { C, W } = require("../sistema/tokens");
const { fondo, barraEstado } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, cuadroIcono } = require("../sistema/componentes");

const kpi = (x, y, valor, etiqueta, pie, nombreIcono, color) => `
<g>
  ${tarjeta(x, y, 169, 132, { radio: 18 })}
  ${cuadroIcono(x + 14, y + 14, 34, { icono: nombreIcono, color })}
  ${icono("forward", x + 141, y + 18, 14, C.muted)}
  ${texto(x + 14, y + 78, valor, { tam: 24, peso: 700 })}
  ${texto(x + 14, y + 96, etiqueta, { tam: 11.5, color: C.subtitle })}
  <circle cx="${x + 17}" cy="${y + 112}" r="3" fill="${color}"/>
  ${texto(x + 26, y + 116, pie, { tam: 10.5, peso: 600, color })}
</g>`;

const filaMenu = (y, titulo, subtitulo, nombreIcono, insignia, ultima) => `
<g>
  ${cuadroIcono(34, y + 12, 38, { icono: nombreIcono })}
  ${texto(84, y + 28, titulo, { tam: 13.5, peso: 600 })}
  ${texto(84, y + 45, subtitulo, { tam: 11, color: C.subtitle })}
  ${insignia ? `<rect x="300" y="${y + 20}" width="22" height="20" rx="10" fill="${C.error}"/>${texto(311, y + 34, insignia, { tam: 9.5, peso: 700, color: C.white, ancla: "middle" })}` : ""}
  ${icono("forward", 340, y + 22, 18, C.muted)}
  ${ultima ? "" : `<rect x="34" y="${y + 61}" width="322" height="1" fill="${C.border}"/>`}
</g>`;

const LEYENDA = [
  { t: "Confirmadas", n: 180, p: "73%", color: C.info },
  { t: "Pendientes", n: 6, p: "2%", color: C.warning },
  { t: "Completadas", n: 54, p: "22%", color: C.success },
  { t: "Canceladas", n: 8, p: "3%", color: C.error },
];

const estadoCitas = () => {
  const ancho = 318;
  let x = 36;
  const segmentos = LEYENDA.map((s) => {
    const w = (s.n / 248) * ancho;
    const svg = `<rect x="${x}" y="598" width="${w}" height="10" fill="${s.color}"/>`;
    x += w;
    return svg;
  }).join("");

  return `
<g>
  ${tarjeta(20, 562, 350, 170, { radio: 20 })}
  ${texto(36, 586, "Total histórico", { tam: 11.5, color: C.subtitle })}
  ${texto(354, 586, "248 citas", { tam: 13, peso: 700, ancla: "end" })}
  <clipPath id="bkBar"><rect x="36" y="598" width="${ancho}" height="10" rx="5"/></clipPath>
  <g clip-path="url(#bkBar)">${segmentos}</g>
  ${LEYENDA.map((s, i) => {
    const y = 630 + i * 24;
    return `<g>
      <circle cx="40" cy="${y - 4}" r="4" fill="${s.color}"/>
      ${texto(54, y, s.t, { tam: 12, color: C.subtitle })}
      ${texto(300, y, String(s.n), { tam: 12.5, peso: 700, ancla: "end" })}
      ${texto(354, y, s.p, { tam: 11.5, color: C.muted, ancla: "end" })}
    </g>`;
  }).join("")}
</g>`;
};

module.exports = {
  id: "14-admin-home",
  nombre: "Panel administrador",
  rol: "Administrador",
  alto: 1140,
  render: () => `
${fondo("", 1140)}
${barraEstado()}
<circle cx="24" cy="60" r="3.5" fill="${C.success}"/>
${texto(36, 64, "PANEL DE CONTROL", { tam: 10.5, peso: 700, color: C.primary, espaciado: 1.6 })}
${texto(20, 94, "Hola, Carlos", { tam: 24, peso: 700 })}
${texto(20, 114, "Jueves, 5 de noviembre · Administrador", { tam: 12, color: C.subtitle })}
${icono("user", 316, 58, 22, C.primary)}
${icono("logout", 352, 58, 22, C.primary)}
${kpi(20, 132, "128", "Usuarios", "Gestionar cuentas", "users", C.primary)}
${kpi(201, 132, "12", "Barberos", "Ver equipo", "scissors", C.info)}
${kpi(20, 276, "36", "Servicios", "Ver catálogo", "tag", C.success)}
${kpi(201, 276, "248", "Citas", "6 pendientes", "calendar", C.warning)}
${tarjeta(20, 424, 350, 76, { gradiente: "hero", borde: C.warning, opacidadBorde: 0.45, radio: 18 })}
${cuadroIcono(34, 440, 44, { icono: "shield", color: C.warning })}
${texto(90, 456, "2 barberos esperan verificación", { tam: 14, peso: 600 })}
${texto(90, 474, "Revisa el diploma y otorga el sello.", { tam: 11.5, color: C.subtitle })}
${icono("forward", 340, 452, 20, C.muted)}
${texto(20, 532, "Operación de citas", { tam: 18, peso: 600 })}
${texto(20, 550, "Distribución por estado", { tam: 12, color: C.subtitle })}
${texto(W - 24, 532, "Ver todas", { tam: 11.5, peso: 500, color: C.primary, ancla: "end" })}
${estadoCitas()}
${texto(20, 764, "Gestión del negocio", { tam: 18, peso: 600 })}
${texto(20, 782, "Todo lo que administras en un solo lugar", { tam: 12, color: C.subtitle })}
${tarjeta(20, 794, 350, 310, { radio: 18 })}
${filaMenu(794, "Usuarios", "Clientes, barberos y admins", "users")}
${filaMenu(856, "Verificar barberos", "Diplomas y cuentas sin sello", "shield", "2")}
${filaMenu(918, "Servicios", "Catálogo y precios", "tag")}
${filaMenu(980, "Citas", "Agenda general del negocio", "calendar")}
${filaMenu(1042, "Barberos", "Equipo profesional", "scissors", null, true)}
`,
};