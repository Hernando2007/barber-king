const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, campo, insignia, switchControl, boton, chip } = require("../sistema/componentes");

const servicio = (y, nombre, catalogo, on) => `
<g>
  ${tarjeta(20, y, 350, 132, { radio: 18 })}
  <rect x="34" y="${y + 14}" width="38" height="38" rx="12" fill="${on ? C.primary : C.surfaceAlt}" opacity="${on ? 0.16 : 1}"/>
  ${icono("scissors", 43, y + 23, 20, on ? C.primary : C.muted)}
  ${texto(84, y + 30, nombre, { tam: 14.5, peso: 600 })}
  ${texto(84, y + 48, catalogo, { tam: 11, color: C.subtitle })}
  ${switchControl(310, y + 20, { on })}
  ${insignia(292, y + 58, on ? "Atiendes" : "No atiendes", { tipo: on ? "success" : "neutral" })}
  ${campo(34, y + 82, 160, { etiqueta: "Tu precio", placeholder: "Igual al catálogo", alto: 42 })}
  ${campo(206, y + 82, 150, { etiqueta: "Tus minutos", placeholder: "Igual al catálogo", alto: 42 })}
</g>`;

module.exports = {
  id: "25-barbero-servicios",
  nombre: "Servicios que atiendo",
  rol: "Barbero",
  alto: 1140,
  render: () => `
${fondo("", 1140)}
${barraEstado()}
${appBar({ titulo: "Servicios que atiendo", atras: false, acciones: ["refresh"] })}
${texto(24, 138, "Tu carta de servicios", { tam: 24, peso: 700 })}
${texto(24, 162, "Marca los cortes que dominas. Solo te llegan reservas", { tam: 12, color: C.subtitle })}
${texto(24, 180, "de lo que atiendas, y puedes cobrarlos a tu propio precio.", { tam: 12, color: C.subtitle })}
${chip(20, 200, "Atiendes 3 de 5 servicios", { activo: true, alto: 32, ancho: 196 })}
${servicio(248, "Corte + Barba", "Catálogo: $ 40.000 · 60 min", true)}
${servicio(394, "Fade", "Catálogo: $ 30.000 · 45 min", true)}
${servicio(540, "Barba", "Catálogo: $ 15.000 · 20 min", true)}
${servicio(686, "Corte de niño", "Catálogo: $ 20.000 · 30 min", false)}
${servicio(832, "Colorimetría", "Catálogo: $ 60.000 · 90 min", false)}
${boton(20, 992, 350, "GUARDAR SERVICIOS", { icono: "check" })}
${texto(195, 1064, "Los precios que escribas reemplazan los del catálogo solo para ti.", { tam: 10, color: C.muted, ancla: "middle" })}
`,
};
