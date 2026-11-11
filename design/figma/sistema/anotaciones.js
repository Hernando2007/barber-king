const { C, W } = require("./tokens");
const { texto } = require("./texto");

const RADIO = 13;

// Un círculo dorado con el número del paso, al lado del elemento que se describe.
const marcador = (m, o = {}) => {
  const ancho = o.ancho || W;
  const alto = o.alto || 844;
  const x = Math.max(RADIO + 4, Math.min(ancho - RADIO - 4, m.x));
  const y = Math.max(RADIO + 4, Math.min(alto - RADIO - 4, m.y));
  const puntero = m.apunta
    ? `<line x1="${x}" y1="${y}" x2="${m.apunta.x}" y2="${m.apunta.y}" stroke="${C.primary}" stroke-width="1.6" stroke-dasharray="4 3" opacity="0.9"/>` +
      `<circle cx="${m.apunta.x}" cy="${m.apunta.y}" r="3" fill="${C.primary}"/>`
    : "";
  return `<g>
  ${puntero}
  <circle cx="${x}" cy="${y}" r="${RADIO + 3.5}" fill="${C.background}" opacity="0.9"/>
  <circle cx="${x}" cy="${y}" r="${RADIO}" fill="url(#gold)" stroke="${C.background}" stroke-width="1.2"/>
  ${texto(x, y + 4.7, String(m.n), { tam: 13.5, peso: 700, color: C.black, ancla: "middle" })}
</g>`;
};

const anotaciones = (marcas, o = {}) =>
  (marcas || []).map((m) => marcador(m, o)).join("");

module.exports = { anotaciones, RADIO };
