const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto, anchoTexto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, campo, chip, avatar, insignia, fab } = require("../sistema/componentes");

const FILTROS = [
  { t: "Todos", on: true },
  { t: "Clientes" },
  { t: "Barberos" },
  { t: "Admins" },
];

const filaChips = () => {
  let x = 20;
  return FILTROS.map((f) => {
    const ancho = anchoTexto(f.t, 11.5) + 22;
    const svg = chip(x, 178, f.t, { activo: f.on, ancho });
    x += ancho + 8;
    return svg;
  }).join("");
};

const usuario = (y, iniciales, nombre, rol, tipo, correo, extra, telefono, activo) => `
<g>
  ${tarjeta(20, y, 350, 104, { radio: 18 })}
  ${avatar(34, y + 16, 50, { iniciales })}
  ${texto(96, y + 31, nombre, { tam: 15, peso: 600 })}
  ${texto(96, y + 50, correo, { tam: 11.5, color: C.subtitle })}
  ${texto(96, y + 66, extra, { tam: 10, color: C.muted })}
  ${insignia(346 - anchoTexto(rol, 9.5) - 20, y + 14, rol, { tipo })}
  ${icono("more", 340, y + 38, 18, C.muted)}
  ${icono(activo ? "checkCircle" : "alert", 34, y + 82, 12, activo ? C.success : C.error)}
  ${texto(52, y + 92, activo ? "Cuenta activa" : "Cuenta desactivada", { tam: 10, color: activo ? C.success : C.error })}
  ${texto(346, y + 92, telefono || "Sin teléfono", { tam: 10, color: telefono ? C.subtitle : C.muted, ancla: "end" })}
</g>`;

module.exports = {
  id: "15-admin-usuarios",
  nombre: "Gestión de usuarios",
  rol: "Administrador",
  render: () => `
${fondo()}
${barraEstado()}
${appBar({ titulo: "Gestión de usuarios", atras: false, acciones: ["refresh"] })}
${campo(20, 112, 350, { placeholder: "Buscar por nombre o correo", icono: "search" })}
${filaChips()}
${texto(20, 236, "4 usuarios", { tam: 12.5, color: C.subtitle })}
${texto(370, 236, "Total: 4", { tam: 11.5, color: C.muted, ancla: "end" })}
${usuario(256, "CM", "Carlos Mendoza", "Administrador", "gold", "carlos@barberking.com", "Acceso total", "+57 300 123 4567", true)}
${usuario(370, "MR", "Marco Ruiz", "Barbero", "info", "marco@barberking.com", "Especialidad: Fade", "+57 310 555 8899", true)}
${usuario(484, "LP", "Luis Pérez", "Cliente", "neutral", "luis@correo.com", "Cliente", "+57 320 444 1122", true)}
${usuario(598, "AT", "Ana Torres", "Cliente", "neutral", "ana@correo.com", "Cliente", "", false)}
${fab("Nuevo usuario", "user")}
`,
};
