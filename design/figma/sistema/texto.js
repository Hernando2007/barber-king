const { F } = require("./tokens");

const esc = (valor) =>
  String(valor)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");

const texto = (x, y, contenido, o = {}) => {
  const tam = o.tam || 14;
  const peso = o.peso || 400;
  const color = o.color || "#F8FAFC";
  const ancla = o.ancla || "start";
  const opacidad = o.opacidad === undefined ? 1 : o.opacidad;
  const espaciado = o.espaciado || 0;
  const familia = o.familia || F;
  return `<text x="${x}" y="${y}" font-family="${familia}" font-size="${tam}" font-weight="${peso}" fill="${color}" text-anchor="${ancla}" opacity="${opacidad}" letter-spacing="${espaciado}">${esc(contenido)}</text>`;
};

const anchoTexto = (contenido, tam) => String(contenido).length * tam * 0.54;

const parrafo = (x, y, contenido, o = {}) => {
  const tam = o.tam || 13;
  const ancho = o.ancho || 300;
  const linea = o.linea || Math.round(tam * 1.55);
  const palabras = String(contenido).split(/\s+/);
  const lineas = [];
  let actual = "";
  for (const palabra of palabras) {
    const intento = actual ? `${actual} ${palabra}` : palabra;
    if (anchoTexto(intento, tam) > ancho && actual) {
      lineas.push(actual);
      actual = palabra;
    } else {
      actual = intento;
    }
  }
  if (actual) lineas.push(actual);
  return lineas
    .map((l, i) =>
      texto(x, y + i * linea, l, { ...o, tam, linea: undefined })
    )
    .join("\n");
};

const recortar = (contenido, maximo) => {
  const limpio = String(contenido).trim();
  if (limpio.length <= maximo) return limpio;
  return `${limpio.slice(0, maximo - 1).trimEnd()}…`;
};

const contarLineas = (contenido, tam, ancho) => {
  const palabras = String(contenido).split(/\s+/);
  let lineas = 1;
  let actual = "";
  for (const palabra of palabras) {
    const intento = actual ? `${actual} ${palabra}` : palabra;
    if (anchoTexto(intento, tam) > ancho && actual) {
      lineas += 1;
      actual = palabra;
    } else {
      actual = intento;
    }
  }
  return lineas;
};

module.exports = { esc, texto, parrafo, anchoTexto, recortar, contarLineas };
