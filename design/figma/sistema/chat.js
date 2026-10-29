const { C, W } = require("./tokens");
const { texto, parrafo, anchoTexto, contarLineas } = require("./texto");
const { icono } = require("./iconos");

const rectRadio = (x, y, w, h, o = {}) => {
  const tl = o.tl ?? 16;
  const tr = o.tr ?? 16;
  const br = o.br ?? 16;
  const bl = o.bl ?? 16;
  return `<path d="M${x + tl} ${y} H${x + w - tr} A${tr} ${tr} 0 0 1 ${x + w} ${y + tr} V${y + h - br} A${br} ${br} 0 0 1 ${x + w - br} ${y + h} H${x + bl} A${bl} ${bl} 0 0 1 ${x} ${y + h - bl} V${y + tl} A${tl} ${tl} 0 0 1 ${x + tl} ${y} Z" fill="${o.relleno || C.card}" ${o.borde ? `stroke="${o.borde}"` : ""}/>`;
};

const burbuja = (o) => {
  const tam = 13;
  const anchoMax = o.anchoMax || 286;
  const anchoTextoBurbuja = Math.min(anchoMax, anchoTexto(o.texto, tam) + 38);
  const lineas = contarLineas(o.texto, tam, anchoTextoBurbuja - 38);
  const alto = 20 + lineas * 19 + 14;
  const x = o.propio ? W - 16 - anchoTextoBurbuja : 16;
  const fondo = o.propio ? "url(#gold)" : C.card;
  const color = o.propio ? C.black : C.white;
  const hora = o.hora || "";
  const svg = `<g>
    ${rectRadio(x, o.y, anchoTextoBurbuja, alto, {
      relleno: fondo,
      borde: o.propio ? null : C.border,
      br: o.propio ? 4 : 16,
      bl: o.propio ? 16 : 4,
    })}
    ${parrafo(x + 15, o.y + 23, o.texto, {
      tam,
      ancho: anchoTextoBurbuja - 30,
      color,
    })}
    ${texto(o.propio ? x + anchoTextoBurbuja - 15 : x + anchoTextoBurbuja - 15, o.y + alto - 9, hora, {
      tam: 9,
      color,
      ancla: "end",
      opacidad: o.propio ? 0.55 : 0.5,
    })}
  </g>`;
  return { svg, alto };
};

const compositor = (o = {}) => {
  const y = o.y || 760;
  return `<g>
    <rect x="0" y="${y}" width="${W}" height="${844 - y}" fill="${C.backgroundSoft}"/>
    <rect x="0" y="${y}" width="${W}" height="1" fill="${C.border}"/>
    ${icono(o.icono || "image", 20, y + 30, 22, C.primary)}
    <rect x="56" y="${y + 16}" width="${W - 132}" height="48" rx="16" fill="${C.surface}" stroke="${C.border}"/>
    ${texto(72, y + 46, o.placeholder || "Escribe un mensaje...", { tam: 12.5, color: C.muted })}
    <rect x="${W - 64}" y="${y + 15}" width="46" height="46" rx="14" fill="url(#gold)"/>
    ${icono("send", W - 52, y + 27, 22, C.black)}
  </g>`;
};

const separadorFecha = (y, contenido) => `
<g>
  <rect x="129" y="${y - 14}" width="132" height="24" rx="12" fill="${C.surface}"/>
  ${texto(195, y + 2, contenido, { tam: 9.5, peso: 500, color: C.subtitle, ancla: "middle" })}
</g>`;

module.exports = { rectRadio, burbuja, compositor, separadorFecha };
