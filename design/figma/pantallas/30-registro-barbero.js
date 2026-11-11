const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { emblema } = require("../sistema/marca");
const { tarjeta, campo, selector, areaTexto, boton, insignia } = require("../sistema/componentes");

const tipoCuenta = (x, activo, etiqueta, nombreIcono) => `
<g>
  <rect x="${x}" y="286" width="155" height="90" rx="16" fill="${activo ? C.primary : C.surface}" fill-opacity="${activo ? 0.16 : 1}" stroke="${activo ? C.primary : C.border}" stroke-width="${activo ? 2 : 1}"/>
  ${icono(nombreIcono, x + 63, 302, 28, activo ? C.primary : C.subtitle)}
  ${texto(x + 77.5, 360, etiqueta, { tam: 13, peso: 600, color: activo ? C.primary : C.white, ancla: "middle" })}
</g>`;

const miniatura = (x, y, o = {}) => `
<g>
  <rect x="${x}" y="${y}" width="86" height="72" rx="12" fill="${o.relleno ? C.surface : C.surfaceAlt}" stroke="${o.relleno ? C.border : C.primary}" stroke-opacity="${o.relleno ? 1 : 0.5}"/>
  ${icono(o.relleno ? "scissors" : "plus", x + 33, y + 24, 22, o.relleno ? C.primary : C.muted)}
  ${o.relleno ? insignia(x + 4, y + 4, "OK", { tipo: "success" }) : ""}
</g>`;

module.exports = {
  id: "30-registro-barbero",
  nombre: "Crear cuenta de barbero",
  rol: "Barbero",
  alto: 2020,
  render: () => `
${fondo("", 2020)}
${barraEstado()}
${appBar({ titulo: "Crear cuenta" })}
${emblema(195, 148, 30)}
${texto(195, 200, "ÚNETE A BARBER KING", { tam: 23, peso: 700, color: C.primary, ancla: "middle", espaciado: 2.4 })}
${texto(195, 224, "Crea tu cuenta y vive la experiencia premium.", { tam: 13, color: C.subtitle, ancla: "middle" })}
${tarjeta(20, 248, 350, 1740)}
${texto(40, 282, "Tipo de cuenta", { tam: 14, peso: 600 })}
${tipoCuenta(40, false, "Cliente", "user")}
${tipoCuenta(195, true, "Barbero", "scissors")}
<g>
  ${icono("user", 40, 396, 26, C.primary)}
  ${texto(80, 416, "Datos personales", { tam: 17, peso: 600 })}
</g>
${campo(40, 446, 310, { etiqueta: "Nombres", placeholder: "Marco", icono: "user", valor: "Marco Antonio" })}
${campo(40, 526, 310, { etiqueta: "Apellidos", placeholder: "Ruiz", icono: "file", valor: "Ruiz Díaz" })}
${campo(40, 606, 310, { etiqueta: "Correo electrónico", placeholder: "tu@correo.com", icono: "at", valor: "marco@barberking.com" })}
${campo(40, 686, 310, { etiqueta: "Teléfono", placeholder: "+57 300 000 0000", icono: "phone", valor: "+57 310 555 8899" })}
${campo(40, 766, 310, { etiqueta: "Fecha de nacimiento", placeholder: "aaaa-mm-dd", icono: "calendar", der: "down", valor: "1992-06-14" })}
<g>
  ${icono("lock", 40, 846, 26, C.primary)}
  ${texto(80, 866, "Seguridad", { tam: 17, peso: 600 })}
</g>
${campo(40, 896, 310, { etiqueta: "Contraseña", placeholder: "••••••••", icono: "lock", der: "eye", valor: "••••••••" })}
${campo(40, 976, 310, { etiqueta: "Confirmar contraseña", placeholder: "••••••••", icono: "lock", der: "eye", valor: "••••••••" })}
<g>
  ${icono("briefcase", 40, 1056, 26, C.primary)}
  ${texto(80, 1076, "Perfil profesional", { tam: 17, peso: 600 })}
</g>
${selector(40, 1106, 310, { etiqueta: "Especialidad *", placeholder: "Ej. Fade, barbería clásica, colorimetría", valor: "Fade y barba", icono: "scissors" })}
${campo(40, 1186, 150, { etiqueta: "Años de experiencia", placeholder: "Ej. 3", icono: "clock", valor: "6" })}
${areaTexto(40, 1276, 310, { etiqueta: "Descripción profesional", placeholder: "Cuéntale a tus clientes sobre tu estilo de trabajo.", valor: "Especialista en degradados y perfilado de barba con productos premium.", alto: 96 })}
${boton(40, 1404, 310, "Adjuntar diploma o certificado", { tipo: "contorno", alto: 50, icono: "upload" })}
${texto(40, 1476, "Opcional. Si lo subes, la IA comprueba que sea un diploma real", { tam: 10.5, color: C.muted })}
${texto(40, 1492, "de barbería. Solo imágenes JPG, PNG o WEBP.", { tam: 10.5, color: C.muted })}
${tarjeta(40, 1512, 310, 96, { radio: 14, relleno: C.surface })}
${icono("file", 56, 1542, 22, C.primary)}
${texto(88, 1552, "diploma-marco.jpg", { tam: 12, peso: 500 })}
${texto(88, 1572, "Listo para subir · se guarda en Cloudinary", { tam: 10, color: C.muted })}
${insignia(280, 1534, "Adjunto", { tipo: "success" })}
${texto(40, 1636, "Fotos de portafolio (hasta 6)", { tam: 13, peso: 600 })}
${miniatura(40, 1650, { relleno: true })}
${miniatura(136, 1650, { relleno: true })}
${miniatura(232, 1650, { relleno: true })}
${miniatura(40, 1732)}
${miniatura(136, 1732)}
${miniatura(232, 1732)}
${boton(40, 1838, 310, "REGISTRARME COMO BARBERO", { icono: "check" })}
${texto(195, 1922, "Ya tengo una cuenta", { tam: 12.5, peso: 500, color: C.primary, ancla: "middle" })}
${texto(195, 1960, "Un administrador puede pedirte el diploma antes de darte el sello de verificado.", { tam: 10, color: C.muted, ancla: "middle" })}
`,
};
