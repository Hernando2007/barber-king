const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto, parrafo } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, avatar, insignia, boton, chip } = require("../sistema/componentes");

const pendiente = (y, iniciales, nombre, correo, perfil, nota, notaColor) => `
<g>
  ${tarjeta(20, y, 350, 250, { radio: 18 })}
  ${avatar(36, y + 18, 52, { iniciales })}
  ${texto(100, y + 36, nombre, { tam: 16, peso: 600 })}
  ${texto(100, y + 55, correo, { tam: 11.5, color: C.subtitle })}
  ${insignia(286, y + 18, "Pendiente", { tipo: "warning" })}
  ${texto(36, y + 92, perfil, { tam: 11.5, color: C.subtitle })}
  ${tarjeta(36, y + 106, 318, 52, { radio: 14, relleno: C.surface })}
  ${icono("file", 50, y + 122, 20, C.primary)}
  ${texto(80, y + 130, "diploma-" + iniciales.toLowerCase() + ".jpg", { tam: 11.5, peso: 500 })}
  ${texto(80, y + 148, "Cloudinary · barber-king/documentos", { tam: 9.5, color: C.muted })}
  ${icono("eye", 330, y + 122, 20, C.subtitle)}
  ${tarjeta(36, y + 166, 318, 42, { radio: 12, relleno: C.surface })}
  ${icono("sparkles", 48, y + 177, 18, notaColor)}
  ${parrafo(72, y + 183, nota, { tam: 10.5, ancho: 270, color: notaColor, linea: 14 })}
  ${boton(36, y + 218, 152, "APROBAR", { alto: 40, icono: "check" })}
  ${boton(202, y + 218, 152, "RECHAZAR", { tipo: "peligro", alto: 40, icono: "close" })}
</g>`;

module.exports = {
  id: "27-admin-revision",
  nombre: "Verificación de barberos",
  rol: "Administrador",
  alto: 1000,
  render: () => `
${fondo("", 1000)}
${barraEstado()}
${appBar({ titulo: "Verificación de barberos", atras: false, acciones: ["refresh"] })}
${texto(24, 138, "Bandeja de verificación", { tam: 24, peso: 700 })}
${texto(24, 162, "Tú decides quién lleva el sello.", { tam: 12, color: C.subtitle })}
${chip(20, 182, "2 pendientes", { alto: 32, ancho: 122, icono: "clock" })}
${pendiente(
    232,
    "MR",
    "Marco Ruiz",
    "marco@barberking.com",
    "Especialidad: Fade · 6 años de experiencia",
    "La IA lo vio válido con 82% de confianza. Diploma legible.",
    C.success
  )}
${pendiente(
    502,
    "JP",
    "Jorge Peña",
    "jorge@correo.com",
    "Sin perfil profesional cargado.",
    "Se registró sin diploma: solo tú puedes darle el sello.",
    C.warning
  )}
${texto(195, 940, "Al rechazar puedes escribir una nota: el barbero la ve en su app y vuelve a intentar.", { tam: 10, color: C.muted, ancla: "middle" })}
`,
};
