const { C, W, H } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, boton, areaTexto } = require("../sistema/componentes");

const estrellas = (x, y, activos) =>
  [0, 1, 2, 3, 4]
    .map((i) => icono("star", x + i * 74, y, 44, i < activos ? C.primary : C.borderStrong, 0))
    .join("");

module.exports = {
  id: "23-resena",
  nombre: "Dejar reseña",
  rol: "Cliente",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Mis citas", atras: false })}
${tarjeta(20, 112, 350, 168)}
${icono("calendar", 36, 132, 22, C.primary)}
${texto(70, 149, "Corte de cabello + barba", { tam: 13.5, peso: 600 })}
${texto(70, 168, "Andrés Ramírez · hoy, 3:00 p.m.", { tam: 11, color: C.subtitle })}
${texto(70, 196, "Completada", { tam: 11, peso: 600, color: C.success })}
${boton(36, 214, 132, "Calificar", { tipo: "suave", alto: 40, icono: "star", radio: 12 })}
<rect x="0" y="0" width="${W}" height="${H}" fill="${C.black}" opacity="0.62"/>
${tarjeta(0, 332, W, 512, { relleno: C.card, borde: C.borderStrong, radio: 26 })}
<rect x="${W / 2 - 18}" y="350" width="36" height="4" rx="2" fill="${C.borderStrong}"/>
${texto(24, 392, "Deja tu reseña", { tam: 17, peso: 700 })}
${texto(24, 414, "¿Cómo te fue con Andrés Ramírez?", { tam: 12.5, color: C.subtitle })}
${estrellas(30, 446, 4)}
${texto(195, 524, "¡Bien!", { tam: 12.5, peso: 600, color: C.primary, ancla: "middle" })}
${areaTexto(20, 560, 350, {
  alto: 128,
  etiqueta: "Comentario (opcional)",
  valor: "El fade quedó exactamente como lo quería, muy puntual.",
})}
${texto(370, 706, "56/300", { tam: 10, color: C.muted, ancla: "end" })}
${boton(20, 730, 350, "Publicar reseña", { icono: "check" })}
${texto(195, 808, "Solo tú y el barbero verán esta reseña", { tam: 10.5, color: C.muted, ancla: "middle" })}
`,
};
