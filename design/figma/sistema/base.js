const { C, W, H, gradientes } = require("./tokens");
const { texto } = require("./texto");
const { icono } = require("./iconos");

// Pestañas reales de la barra inferior (tabs_home_pestanas.dart).
const NAV_CLIENTE = [
  { id: "inicio", etiqueta: "Inicio", icono: "home" },
  { id: "citas", etiqueta: "Citas", icono: "calendar" },
  { id: "barberos", etiqueta: "Barberos", icono: "scissors" },
];

const NAV_BARBERO = [
  { id: "inicio", etiqueta: "Inicio", icono: "home" },
  { id: "agenda", etiqueta: "Agenda", icono: "calendar" },
  { id: "horarios", etiqueta: "Horarios", icono: "clock" },
];

const degradado = (id, colores, x1 = 0, y1 = 0, x2 = 0, y2 = 1) =>
  `<linearGradient id="${id}" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}">${colores
    .map((c, i) => `<stop offset="${(i / (colores.length - 1)) * 100}%" stop-color="${c}"/>`)
    .join("")}</linearGradient>`;

const defs = () =>
  `<defs>${degradado("bg", gradientes.fondo)}${degradado("gold", gradientes.gold, 0, 0, 1, 1)}${degradado("card", gradientes.card, 0, 0, 1, 1)}${degradado("hero", gradientes.hero, 0, 0, 1, 1)}</defs>`;

const fondo = (extra = "", alto = H) =>
  `${defs()}<rect width="${W}" height="${alto}" fill="url(#bg)"/>${extra}`;

const barraEstado = (color = C.white) => `
<g>
  ${texto(24, 28, "9:41", { tam: 12, peso: 600, color })}
  ${[0, 1, 2, 3]
    .map(
      (i) =>
        `<rect x="${300 + i * 5}" y="${27 - i * 2.5}" width="3" height="${4 + i * 2.5}" rx="1" fill="${color}"/>`
    )
    .join("")}
  <path d="M324 24.5a12 12 0 0 1 15 0M327 28a8 8 0 0 1 9 0M330 31.2a4 4 0 0 1 3 0" fill="none" stroke="${color}" stroke-width="1.6" stroke-linecap="round"/>
  <rect x="345" y="19" width="23" height="11" rx="3" fill="none" stroke="${color}" stroke-width="1.3" opacity="0.7"/>
  <rect x="348" y="22" width="15" height="5" rx="1.2" fill="${color}"/>
  <path d="M370 22.5v4" stroke="${color}" stroke-width="2" stroke-linecap="round" opacity="0.7"/>
</g>`;

const appBar = ({ titulo, subtitulo, atras = true, acciones = [] }) => {
  const xTitulo = atras ? 56 : 24;
  const accionesSvg = acciones
    .map((nombre, i) => icono(nombre, W - 44 - i * 38, 58, 22, C.white))
    .join("");
  return `
<g>
  ${atras ? icono("back", 20, 57, 24, C.white) : ""}
  ${texto(xTitulo, subtitulo ? 74 : 80, titulo, { tam: 19, peso: 600, espaciado: -0.2 })}
  ${subtitulo ? texto(xTitulo, 95, subtitulo, { tam: 11.5, color: C.subtitle }) : ""}
  ${accionesSvg}
</g>`;
};

// NavigationBar de Material 3: 80 dp fijos, pegados al borde inferior del lienzo.
const ALTO_BARRA = 80;

const barraInferior = (activo, items = NAV_CLIENTE, o = {}) => {
  const alto = o.alto || H;
  const base = alto - ALTO_BARRA;
  const ancho = W / items.length;
  return `
<g>
  <rect x="0" y="${base}" width="${W}" height="${ALTO_BARRA}" fill="${C.backgroundSoft}" opacity="0.98"/>
  <rect x="0" y="${base}" width="${W}" height="1" fill="${C.border}"/>
  ${items
    .map((item, i) => {
      const cx = ancho * i + ancho / 2;
      const on = item.id === activo;
      const color = on ? C.primary : C.muted;
      const anchoInsignia = item.badge ? (String(item.badge).length > 1 ? 26 : 18) : 0;
      const insignia = item.badge
        ? `<rect x="${cx + 6}" y="${base + 4}" width="${anchoInsignia}" height="17" rx="8.5" fill="${C.error}"/>` +
          texto(cx + 6 + anchoInsignia / 2, base + 16, item.badge, {
            tam: 9.5,
            peso: 700,
            color: C.white,
            ancla: "middle",
          })
        : "";
      return `<g>
    ${on ? `<rect x="${cx - 32}" y="${base + 6}" width="64" height="36" rx="18" fill="${C.primary}" opacity="0.14"/>` : ""}
    ${icono(item.icono, cx - 12, base + 12, 24, color)}
    ${texto(cx, base + 66, item.etiqueta, { tam: 11, peso: on ? 600 : 500, color, ancla: "middle" })}
    ${insignia}
  </g>`;
    })
    .join("")}
</g>`;
};

const etiqueta = (x, y, contenido, color = C.subtitle) =>
  texto(x, y, contenido.toUpperCase(), {
    tam: 10.5,
    peso: 600,
    color,
    espaciado: 1.1,
  });

const cabecera = (x, y, titulo, accion) => `
<g>
  ${texto(x, y, titulo, { tam: 15.5, peso: 600 })}
  ${
    accion
      ? `${texto(W - 24, y, accion, { tam: 11.5, peso: 500, color: C.primary, ancla: "end" })}${icono("forward", W - 20, y - 11, 14, C.primary, 2)}`
      : ""
  }
</g>`;

const divisor = (x, y, ancho, color = C.border) =>
  `<rect x="${x}" y="${y}" width="${ancho}" height="1" fill="${color}"/>`;

const punto = (x, y, color = C.success, tam = 7) =>
  `<circle cx="${x}" cy="${y}" r="${tam / 2}" fill="${color}"/>`;

module.exports = {
  W,
  H,
  ALTO_BARRA,
  NAV_CLIENTE,
  NAV_BARBERO,
  degradado,
  defs,
  fondo,
  barraEstado,
  appBar,
  barraInferior,
  etiqueta,
  cabecera,
  divisor,
  punto,
};
