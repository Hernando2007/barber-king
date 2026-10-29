const { C } = require("../sistema/tokens");
const { fondo, barraEstado, appBar } = require("../sistema/base");
const { texto } = require("../sistema/texto");
const { icono } = require("../sistema/iconos");
const { tarjeta, campo, selector, avatar, insignia, switchControl, boton } = require("../sistema/componentes");

module.exports = {
  id: "16-admin-usuario-form",
  nombre: "Editar usuario",
  rol: "Administrador",
  alto: 940,
  render: () => `
${fondo("", 940)}
${barraEstado()}
${appBar({ titulo: "Editar usuario" })}
${tarjeta(20, 112, 350, 104, { gradiente: "hero", borde: C.primary, opacidadBorde: 0.3 })}
${avatar(36, 136, 56, { iniciales: "MR", borde: C.primary })}
${texto(108, 158, "Marco Ruiz", { tam: 18, peso: 700 })}
${texto(108, 178, "Barbero · Cuenta activa", { tam: 11.5, color: C.subtitle })}
${insignia(298, 146, "Activa", { tipo: "success" })}
<g>
  ${icono("shield", 20, 230, 18, C.primary)}
  ${texto(46, 241, "Datos de la cuenta", { tam: 15.5, peso: 600 })}
</g>
${selector(20, 270, 350, { etiqueta: "Rol", valor: "Barbero", icono: "shield" })}
${campo(20, 340, 350, { etiqueta: "Nombres", valor: "Marco", icono: "user" })}
${campo(20, 410, 350, { etiqueta: "Apellidos", valor: "Ruiz", icono: "file" })}
${campo(20, 480, 350, { etiqueta: "Correo electrónico", valor: "marco@barberking.com", icono: "mail" })}
${campo(20, 550, 350, { etiqueta: "Teléfono", valor: "+57 310 555 8899", icono: "phone" })}
${campo(20, 620, 350, { etiqueta: "Fecha de nacimiento", valor: "1992-06-14", icono: "calendar", der: "down" })}
${campo(20, 690, 350, { etiqueta: "Nueva contraseña (opcional)", placeholder: "••••••••", icono: "lock", der: "eye" })}
${texto(22, 750, "Déjala vacía para conservar la actual.", { tam: 10, color: C.muted })}
${tarjeta(20, 766, 350, 60, { radio: 16 })}
${texto(36, 790, "Cuenta activa", { tam: 13.5, peso: 600 })}
${texto(36, 808, "Los usuarios desactivados no pueden iniciar sesión.", { tam: 9.5, color: C.muted })}
${switchControl(310, 783, { on: true })}
${boton(20, 848, 350, "GUARDAR CAMBIOS", { icono: "check" })}
${texto(195, 920, "Los cambios se aplican de inmediato.", { tam: 9.5, color: C.muted, ancla: "middle" })}
`,
};
