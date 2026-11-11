const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto, parrafo } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, avatar, insignia, boton, filaInfo, estrellas } = require("../sistema/componentes");

const resena = (y, iniciales, nombre, fecha, nota, comentario) => `
<g>
  ${tarjeta(20, y, 350, 116, { radio: 18 })}
  ${avatar(36, y + 16, 36, { iniciales })}
  ${texto(84, y + 30, nombre, { tam: 13, peso: 600 })}
  ${texto(84, y + 47, fecha, { tam: 10, color: C.muted })}
  ${estrellas(282, y + 22, nota, { tam: 12, separacion: 3 })}
  ${parrafo(36, y + 78, comentario, { tam: 11.5, ancho: 318, color: C.subtitle })}
</g>`;

module.exports = {
  id: "22-perfil-barbero",
  nombre: "Perfil del barbero",
  rol: "Cliente",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Perfil del barbero", acciones: ["refresh"] })}
${tarjeta(20, 112, 350, 232)}
${avatar(36, 130, 66, { iniciales: "AR", activo: true })}
${texto(118, 152, "Andrés Ramírez", { tam: 19, peso: 700 })}
${texto(118, 172, "Fade y barba", { tam: 12.5, peso: 500, color: C.primary })}
${icono("star", 118, 186, 13, C.primary, 0)}
${texto(135, 197, "4.8 (124 reseñas)", { tam: 11.5, peso: 600, color: C.primary })}
${insignia(284, 130, "Disponible", { tipo: "success" })}
${filaInfo(36, 214, 148, { etiqueta: "Zona", valor: "Chapinero · 2.4 km" })}
${filaInfo(192, 214, 158, { etiqueta: "Experiencia", valor: "7 años" })}
${parrafo(36, 292, "Especialista en fades y diseños personalizados con productos premium.", { tam: 12, ancho: 318, color: C.subtitle })}
${boton(20, 360, 350, "Reservar cita", { icono: "calendar" })}
${boton(20, 424, 350, "Ubicación", { tipo: "contorno", alto: 46, icono: "pin" })}
${boton(20, 482, 350, "Calificar mi cita", { tipo: "contorno", alto: 46, icono: "star" })}
${texto(24, 564, "Reseñas", { tam: 15.5, peso: 600 })}
${texto(370, 564, "Ver las 124", { tam: 11, color: C.primary, ancla: "end" })}
${resena(580, "CR", "Camila Rodríguez", "18 nov 2026", 5, "Excelente servicio, salió justo como lo quería. Muy puntual.")}
${resena(708, "JP", "Juan Pablo Gómez", "12 nov 2026", 4, "Buen fade y buena atención, solo demoró un poco en llegar.")}
`,
};
