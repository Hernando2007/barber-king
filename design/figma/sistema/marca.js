const fs = require("fs");
const path = require("path");
const { C } = require("./tokens");

const carpeta = path.join(__dirname, "..", "marca");
const cache = new Map();

const uri = (variante) => {
  if (!cache.has(variante)) {
    const bytes = fs.readFileSync(path.join(carpeta, `emblema-${variante}.png`));
    cache.set(variante, `data:image/png;base64,${bytes.toString("base64")}`);
  }
  return cache.get(variante);
};

/** La marca sola dentro de un lienzo cuadrado de `lado` px. */
const marca = (x, y, lado, { variante = "blanco", opacidad = 1 } = {}) => {
  const datos = uri(variante);
  return `<image x="${x}" y="${y}" width="${lado}" height="${lado}" opacity="${opacidad}" href="${datos}" xlink:href="${datos}" preserveAspectRatio="xMidYMid meet"/>`;
};

/** Emblema de la app: círculo dorado con la marca negra, igual que BrandLogo. */
const emblema = (cx, cy, radio, { halo = true, variante = "negro" } = {}) => {
  const lado = radio * 2 * 0.68;
  return `<g>
  ${halo ? `<circle cx="${cx}" cy="${cy}" r="${radio * 1.22}" fill="${C.primary}" opacity="0.1"/>` : ""}
  <circle cx="${cx}" cy="${cy}" r="${radio}" fill="url(#gold)"/>
  ${marca(cx - lado / 2, cy - lado / 2, lado, { variante })}
</g>`;
};

/** Muestra la marca sobre sus tres fondos de marca. */
const variantes = (x, y) => {
  const lado = 76;
  const salto = 92;
  const celdas = [
    { titulo: "Dorado", fondo: "url(#gold)", marca: "negro" },
    { titulo: "Sobre oscuro", fondo: C.backgroundSoft, marca: "blanco" },
    { titulo: "Sobre claro", fondo: C.white, marca: "negro" },
  ];
  return celdas
    .map((celda, i) => {
      const cx = x + i * salto;
      const centro = cx + lado / 2;
      return `<g>
  <rect x="${cx}" y="${y}" width="${lado}" height="${lado}" rx="18" fill="${celda.fondo}" stroke="${C.border}"/>
  ${marca(cx + (lado - lado * 0.72) / 2, y + (lado - lado * 0.72) / 2, lado * 0.72, { variante: celda.marca })}
  ${`<text x="${centro}" y="${y + lado + 18}" fill="${C.subtitle}" font-family="Poppins, Arial, sans-serif" font-size="9.5" text-anchor="middle">${celda.titulo}</text>`}
</g>`;
    })
    .join("");
};

module.exports = { marca, emblema, variantes };
