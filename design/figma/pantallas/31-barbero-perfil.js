const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, avatar, insignia, boton, filaInfo } = require("../sistema/componentes");

const fila = (y, etiqueta, valor, color) => filaInfo(20, y, 350, { etiqueta, valor, color });

module.exports = {
  id: "31-barbero-perfil",
  nombre: "Perfil profesional del barbero",
  rol: "Barbero",
  alto: 1620,
  render: () => `
${fondo("", 1620)}
${barraEstado()}
${appBar({ titulo: "Perfil profesional", atras: false, acciones: ["edit"] })}
${tarjeta(20, 112, 350, 240, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.3 })}
${avatar(149, 134, 92, { iniciales: "MR", borde: C.primary })}
<g>
  <circle cx="233" cy="210" r="16" fill="${C.primary}" stroke="${C.background}" stroke-width="3"/>
  ${icono("camera", 224, 201, 18, C.black)}
</g>
${texto(195, 254, "Marco Ruiz", { tam: 21, peso: 700, ancla: "middle" })}
${insignia(158, 264, "Barbero", { tipo: "gold" })}
${texto(195, 300, "Fade y barba", { tam: 12, color: C.subtitle, ancla: "middle" })}
${boton(56, 306, 128, "Editar", { tipo: "contorno", alto: 40, icono: "edit" })}
${boton(194, 306, 140, "Contraseña", { tipo: "contorno", alto: 40, icono: "lock" })}
${texto(24, 382, "Información personal", { tam: 15.5, peso: 600 })}
${fila(398, "Correo electrónico", "marco@barberking.com")}
${fila(456, "Teléfono", "+57 310 555 8899")}
${fila(514, "Fecha de nacimiento", "14 jun 1992")}
${fila(572, "Estado de la cuenta", "Activa", C.success)}
${texto(24, 654, "Información profesional", { tam: 15.5, peso: 600 })}
${texto(24, 672, "Visible para los clientes", { tam: 11, color: C.muted })}
${fila(688, "Especialidad", "Fade y barba")}
${fila(746, "Experiencia", "6 años")}
${fila(804, "Dirección", "Calle 63 con Carrera 7")}
${fila(862, "Ciudad", "Bogotá")}
${fila(920, "Zona o barrio", "Chapinero")}
${fila(978, "Descripción", "Degradados y perfilado con productos premium.")}
${tarjeta(20, 1050, 350, 176, { radio: 18 })}
${icono("pin", 36, 1072, 22, C.primary)}
${texto(66, 1088, "Ubicación", { tam: 14.5, peso: 600 })}
${insignia(296, 1072, "Visible", { tipo: "success" })}
${texto(36, 1116, "Actualizada hace 4 min", { tam: 11.5, color: C.subtitle })}
${texto(36, 1134, "Bogotá · Chapinero", { tam: 11.5, color: C.muted })}
${boton(36, 1148, 318, "Compartir ubicación actual", { tipo: "contorno", alto: 42, icono: "refresh" })}
${texto(195, 1252, "Los clientes solo ven la distancia aproximada y tu ciudad;", { tam: 9.5, color: C.muted, ancla: "middle" })}
${texto(195, 1266, "nunca tus coordenadas exactas.", { tam: 9.5, color: C.muted, ancla: "middle" })}
${tarjeta(20, 1290, 350, 158, { radio: 18 })}
${icono("award", 36, 1312, 22, C.success)}
${texto(66, 1328, "Documento profesional", { tam: 14.5, peso: 600 })}
${insignia(258, 1312, "Verificado", { tipo: "success" })}
${texto(36, 1356, "Sello de verificado activo.", { tam: 11.5, color: C.success })}
${texto(36, 1376, "diploma-marco.jpg · revisado por el administrador", { tam: 10.5, color: C.muted })}
${boton(36, 1392, 318, "Subir otro documento", { tipo: "suave", alto: 40, icono: "upload" })}
${texto(195, 1470, "Si la IA no reconoce el diploma, un administrador decide.", { tam: 9.5, color: C.muted, ancla: "middle" })}
${boton(20, 1494, 350, "CERRAR SESIÓN", { tipo: "peligro", icono: "logout" })}
`,
};
