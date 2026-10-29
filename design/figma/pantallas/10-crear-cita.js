const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, selector, chip, boton } = require("../sistema/componentes");

const seccion = (y, titulo, nombreIcono) => `
<g>
  ${icono(nombreIcono, 20, y - 11, 18, C.primary)}
  ${texto(46, y, titulo, { tam: 15, peso: 600 })}
</g>`;

const horarios = [
  ["09:00", false],
  ["09:45", false],
  ["10:30", false],
  ["11:15", false],
  ["14:00", false],
  ["15:30", true],
  ["16:15", false],
];

module.exports = {
  id: "10-crear-cita",
  nombre: "Reservar cita",
  rol: "Cliente",
  render: () => {
    const chips = horarios
      .map(([hora, activo], i) => {
        const x = 20 + (i % 4) * 78;
        const y = i < 4 ? 572 : 610;
        return chip(x, y, hora, { activo, ancho: 68 });
      })
      .join("");
    return `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Reservar cita" })}
${tarjeta(20, 112, 350, 92, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.3 })}
<g>
  <rect x="36" y="136" width="46" height="46" rx="14" fill="url(#gold)"/>
  ${icono("calendar", 49, 149, 20, C.black)}
</g>
${texto(96, 152, "Agenda tu cita con los", { tam: 14, peso: 600 })}
${texto(96, 172, "mejores barberos de la ciudad.", { tam: 14, peso: 600 })}
${seccion(242, "Servicio", "scissors")}
${selector(20, 256, 350, { placeholder: "Selecciona un servicio", valor: "Corte + Barba · $ 40.000" })}
${seccion(332, "Barbero", "user")}
${selector(20, 346, 350, { placeholder: "Selecciona un barbero", valor: "Andrés Ramírez · Fade" })}
${seccion(422, "Fecha", "calendar")}
<g>
  <rect x="20" y="436" width="350" height="54" rx="14" fill="${C.surface}" stroke="${C.border}"/>
  ${icono("calendar", 36, 453, 20, C.primary)}
  ${texto(66, 468, "viernes, 23 de octubre", { tam: 13 })}
  ${icono("down", 340, 453, 20, C.muted)}
</g>
${texto(20, 512, "$ 40.000 · 60 min", { tam: 11.5, color: C.subtitle })}
${seccion(548, "Horarios disponibles", "clock")}
${texto(20, 568, "Hora local · Bogotá", { tam: 11, color: C.muted })}
${chips}
${boton(20, 744, 350, "CONFIRMAR RESERVA", { icono: "check", alto: 52 })}
`;
  },
};
