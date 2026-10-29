const { C, W } = require("./tokens");
const { texto, parrafo, anchoTexto } = require("./texto");
const { icono } = require("./iconos");

const tarjeta = (x, y, w, h, o = {}) => {
  const relleno = o.gradiente ? `url(#${o.gradiente})` : o.relleno || C.card;
  const borde = o.borde === null ? "" : `stroke="${o.borde || C.border}" stroke-opacity="${o.opacidadBorde ?? 1}" stroke-width="${o.grosorBorde || 1}"`;
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${o.radio ?? 20}" fill="${relleno}" ${borde} opacity="${o.opacidad ?? 1}"/>`;
};

const boton = (x, y, w, contenido, o = {}) => {
  const alto = o.alto || 52;
  const radio = o.radio || 14;
  const tipo = o.tipo || "primario";
  let capa = "";
  let color = C.black;
  if (tipo === "primario") capa = `<rect x="${x}" y="${y}" width="${w}" height="${alto}" rx="${radio}" fill="url(#gold)"/>`;
  if (tipo === "contorno") {
    capa = `<rect x="${x}" y="${y}" width="${w}" height="${alto}" rx="${radio}" fill="none" stroke="${C.borderStrong}"/>`;
    color = C.white;
  }
  if (tipo === "suave" || tipo === "peligro") {
    color = tipo === "peligro" ? C.error : C.primary;
    capa = `<rect x="${x}" y="${y}" width="${w}" height="${alto}" rx="${radio}" fill="${color}" opacity="0.13"/><rect x="${x}" y="${y}" width="${w}" height="${alto}" rx="${radio}" fill="none" stroke="${color}" opacity="0.35"/>`;
  }
  const iconoIzq = o.icono ? icono(o.icono, 0, 0, 18, color) : "";
  const contenidoAncho = anchoTexto(contenido, 14.5) + (o.icono ? 26 : 0);
  const inicio = x + (w - contenidoAncho) / 2;
  const lineaBase = y + alto / 2 + 5;
  const xTexto = o.icono ? inicio + 26 : x + w / 2;
  return `<g>${capa}${iconoIzq ? `<g transform="translate(${inicio} ${y + alto / 2 - 9})">${iconoIzq}</g>` : ""}${texto(xTexto, lineaBase, contenido, { tam: 14.5, peso: 600, color, ancla: o.icono ? "start" : "middle" })}</g>`;
};

const campo = (x, y, w, o = {}) => {
  const alto = o.alto || 54;
  const enfocado = o.enfocado;
  const colorBorde = enfocado ? C.primary : C.border;
  const valor = o.valor || o.placeholder || "";
  const colorValor = o.valor ? C.white : C.muted;
  return `<g>
    ${o.etiqueta ? texto(x + 2, y - 9, o.etiqueta, { tam: 10.5, peso: 500, color: C.subtitle }) : ""}
    <rect x="${x}" y="${y}" width="${w}" height="${alto}" rx="14" fill="${C.surface}" stroke="${colorBorde}" stroke-width="${enfocado ? 1.4 : 1}"/>
    ${o.icono ? icono(o.icono, x + 16, y + alto / 2 - 10, 20, enfocado ? C.primary : C.muted) : ""}
    ${texto(x + (o.icono ? 46 : 16), y + alto / 2 + 5, valor, { tam: 13, color: colorValor })}
    ${o.der ? icono(o.der, x + w - 36, y + alto / 2 - 10, 20, C.muted) : ""}
  </g>`;
};

const selector = (x, y, w, o = {}) => campo(x, y, w, { ...o, der: "down" });

const areaTexto = (x, y, w, o = {}) => {
  const alto = o.alto || 104;
  return `<g>
    ${o.etiqueta ? texto(x + 2, y - 9, o.etiqueta, { tam: 10.5, peso: 500, color: C.subtitle }) : ""}
    <rect x="${x}" y="${y}" width="${w}" height="${alto}" rx="14" fill="${C.surface}" stroke="${C.border}"/>
    ${parrafo(x + 16, y + 26, o.valor || o.placeholder || "", { tam: 12.5, ancho: w - 32, color: o.valor ? C.white : C.muted })}
  </g>`;
};

const avatar = (x, y, tam = 48, o = {}) => {
  const cx = x + tam / 2;
  const cy = y + tam / 2;
  const relleno = o.color || C.surfaceAlt;
  return `<g>
    <circle cx="${cx}" cy="${cy}" r="${tam / 2}" fill="${relleno}" stroke="${o.borde || C.borderStrong}"/>
    ${o.iniciales ? texto(cx, cy + tam * 0.12, o.iniciales, { tam: tam * 0.34, peso: 600, ancla: "middle" }) : icono("user", cx - tam * 0.26, cy - tam * 0.26, tam * 0.52, C.subtitle)}
    ${o.activo ? `<circle cx="${x + tam - 4}" cy="${y + tam - 4}" r="6" fill="${C.success}" stroke="${C.card}" stroke-width="2"/>` : ""}
  </g>`;
};

const chip = (x, y, contenido, o = {}) => {
  const alto = o.alto || 30;
  const ancho = o.ancho || anchoTexto(contenido, 11.5) + (o.icono ? 26 : 0) + 24;
  const activo = o.activo;
  const color = activo ? C.black : C.subtitle;
  return `<g>
    <rect x="${x}" y="${y}" width="${ancho}" height="${alto}" rx="${alto / 2}" fill="${activo ? C.primary : C.surface}" stroke="${activo ? C.primary : C.border}"/>
    ${o.icono ? icono(o.icono, x + 11, y + alto / 2 - 8, 16, color) : ""}
    ${texto(x + (o.icono ? 32 : ancho / 2), y + alto / 2 + 4, contenido, { tam: 11.5, peso: 500, color, ancla: o.icono ? "start" : "middle" })}
  </g>`;
};

const insignia = (x, y, contenido, o = {}) => {
  const mapa = { success: C.success, warning: C.warning, error: C.error, info: C.info, gold: C.primary, neutral: C.subtitle };
  const color = mapa[o.tipo || "success"];
  const ancho = anchoTexto(contenido, 9.5) + 20;
  return `<g>
    <rect x="${x}" y="${y}" width="${ancho}" height="20" rx="10" fill="${color}" opacity="0.14"/>
    ${texto(x + ancho / 2, y + 13.5, contenido, { tam: 9.5, peso: 600, color, ancla: "middle" })}
  </g>`;
};

const estrellas = (x, y, promedio, o = {}) => {
  const tam = o.tam || 12;
  const separacion = o.separacion || 3;
  const llenas = Math.round(promedio);
  return Array.from({ length: 5 })
    .map((_, i) => icono("star", x + i * (tam + separacion), y, tam, i < llenas ? C.primary : C.borderStrong, 0))
    .join("");
};

const metrica = (x, y, w, o = {}) => `
<g>
  ${tarjeta(x, y, w, 92, { radio: 18 })}
  ${cuadroIcono(x + 14, y + 14, 32, { icono: o.icono || "trending", color: o.color || C.primary })}
  ${texto(x + 14, y + 66, o.valor, { tam: 20, peso: 600 })}
  ${texto(x + 14, y + 83, o.etiqueta, { tam: 10, color: C.subtitle })}
</g>`;

const cuadroIcono = (x, y, tam = 34, o = {}) => {
  const color = o.color || C.primary;
  return `<g>
    <rect x="${x}" y="${y}" width="${tam}" height="${tam}" rx="${tam * 0.3}" fill="${color}" opacity="${o.opacidad ?? 0.13}"/>
    ${icono(o.icono || "scissors", x + tam * 0.22, y + tam * 0.22, tam * 0.56, color)}
  </g>`;
};

const switchControl = (x, y, o = {}) => {
  const ancho = o.ancho || 46;
  return `<g>
    <rect x="${x}" y="${y}" width="${ancho}" height="26" rx="13" fill="${o.on ? C.primary : C.surfaceAlt}" stroke="${o.on ? C.primary : C.border}"/>
    <circle cx="${o.on ? x + ancho - 13 : x + 13}" cy="${y + 13}" r="10" fill="${o.on ? C.black : C.subtitle}"/>
  </g>`;
};

const barraProgreso = (x, y, w, o = {}) => {
  const valor = Math.max(0, Math.min(1, o.valor || 0));
  return `<g>
    <rect x="${x}" y="${y}" width="${w}" height="6" rx="3" fill="${C.surfaceAlt}"/>
    <rect x="${x}" y="${y}" width="${w * valor}" height="6" rx="3" fill="${o.color || C.primary}"/>
  </g>`;
};

const estadoVacio = (x, y, o = {}) => `
<g>
  <circle cx="${x}" cy="${y}" r="34" fill="${C.surface}" stroke="${C.border}"/>
  ${icono(o.icono || "scissors", x - 15, y - 15, 30, C.muted)}
  ${texto(x, y + 64, o.titulo, { tam: 15, peso: 600, ancla: "middle" })}
  ${parrafo(x - (o.ancho || 240) / 2, y + 86, o.texto, { tam: 12, ancho: o.ancho || 240, color: C.subtitle, ancla: "middle" })}
</g>`;

const tituloValor = (x, y, etiqueta, valor) => `
<g>
  ${texto(x, y, etiqueta, { tam: 10.5, color: C.subtitle })}
  ${texto(x, y + 18, valor, { tam: 13, peso: 500 })}
</g>`;

const filaInfo = (x, y, w, o = {}) => `
<g>
  <rect x="${x}" y="${y}" width="${w}" height="50" rx="14" fill="${C.surface}" stroke="${C.border}"/>
  ${texto(x + 14, y + 19, o.etiqueta, { tam: 10, color: C.subtitle })}
  ${texto(x + 14, y + 38, o.valor, { tam: 12.5, peso: 500, color: o.color || C.white })}
</g>`;

const fab = (contenido, iconoNombre = "plus", y = 764) => {
  const ancho = anchoTexto(contenido, 14.5) + 74;
  return boton(W - 20 - ancho, y, ancho, contenido, { icono: iconoNombre, alto: 54, radio: 16 });
};

module.exports = {
  filaInfo,
  fab,
  tarjeta,
  boton,
  campo,
  selector,
  areaTexto,
  avatar,
  chip,
  insignia,
  estrellas,
  metrica,
  cuadroIcono,
  switchControl,
  barraProgreso,
  estadoVacio,
  tituloValor,
};
