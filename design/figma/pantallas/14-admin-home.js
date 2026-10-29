const { C } = require("../sistema/tokens");
const { fondo, barraEstado } = require("../sistema/base");
const { texto, parrafo } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, cuadroIcono } = require("../sistema/componentes");

const metrica = (x, y, valor, etiqueta, nombreIcono, color) => `
<g>
  ${tarjeta(x, y, 169, 88, { radio: 18 })}
  ${cuadroIcono(x + 14, y + 13, 32, { icono: nombreIcono, color })}
  ${texto(x + 14, y + 66, valor, { tam: 21, peso: 700 })}
  ${texto(x + 14, y + 82, etiqueta, { tam: 10.5, color: C.subtitle })}
</g>`;

const acceso = (y, titulo, subtitulo, nombreIcono, insignia) => `
<g>
  ${tarjeta(20, y, 350, 60, { radio: 16 })}
  ${cuadroIcono(34, y + 10, 40, { icono: nombreIcono })}
  ${texto(88, y + 27, titulo, { tam: 14, peso: 600 })}
  ${texto(88, y + 45, subtitulo, { tam: 11, color: C.subtitle })}
  ${insignia ? `<rect x="316" y="${y + 20}" width="22" height="20" rx="10" fill="${C.error}"/>${texto(327, y + 34, insignia, { tam: 9.5, peso: 700, color: C.white, ancla: "middle" })}` : ""}
  ${icono("forward", 340, y + 21, 18, C.muted)}
</g>`;

module.exports = {
  id: "14-admin-home",
  nombre: "Panel administrador",
  rol: "Administrador",
  render: () => `
${fondo()}
${barraEstado()}
${texto(20, 70, "Hola, Carlos", { tam: 26, peso: 700 })}
${texto(20, 92, "Control total de Barber King", { tam: 12, color: C.subtitle })}
${icono("user", 316, 58, 22, C.primary)}
${icono("logout", 352, 58, 22, C.primary)}
${tarjeta(20, 112, 350, 180, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.35 })}
<rect x="38" y="132" width="46" height="46" rx="14" fill="url(#gold)"/>
${icono("shield", 51, 145, 20, C.black)}
${texto(96, 154, "Panel de administración", { tam: 17, peso: 600 })}
${parrafo(96, 176, "Administra usuarios, barberos, servicios y citas desde un solo lugar.", { tam: 12, ancho: 250, color: C.subtitle })}
${texto(40, 254, "4", { tam: 20, peso: 700, color: C.primary })}
${texto(40, 271, "Reseñas", { tam: 10.5, color: C.subtitle })}
${texto(150, 254, "2", { tam: 20, peso: 700, color: C.primary })}
${texto(150, 271, "Pendientes", { tam: 10.5, color: C.subtitle })}
${texto(260, 254, "1", { tam: 20, peso: 700, color: C.primary })}
${texto(260, 271, "Completadas", { tam: 10.5, color: C.subtitle })}
${metrica(20, 304, "4", "Usuarios", "users", C.primary)}
${metrica(201, 304, "1", "Barberos", "scissors", C.info)}
${metrica(20, 400, "5", "Servicios", "tag", C.success)}
${metrica(201, 400, "3", "Citas", "calendar", C.warning)}
${texto(20, 526, "Accesos rápidos", { tam: 18, peso: 600 })}
${texto(20, 546, "Gestiona la operación del negocio", { tam: 12, color: C.subtitle })}
${acceso(564, "Usuarios", "Clientes, barberos y admins", "users")}
${acceso(632, "Servicios", "Catálogo y precios", "tag")}
${acceso(700, "Citas", "Agenda general", "calendar")}
${acceso(768, "Mensajes", "Conversaciones con clientes", "chat", "3")}
`,
};
