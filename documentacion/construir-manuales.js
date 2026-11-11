// Construye los manuales en HTML listos para imprimir en A4.
//   node documentacion/construir-manuales.js
// Cada .hoja del HTML es exactamente una página A4: el índice y el pie
// usan números de página reales, no estimados.
const fs = require("fs");
const path = require("path");
const MARCAS = require("./marcas");

const LOGO_EMBLEM_DORADO = fs.readFileSync(
  path.join(__dirname, "..", "design", "figma", "marca", "emblema-dorado.png"),
  "base64",
);

const CSS = `
@page { size: A4; margin: 0; }
* { box-sizing: border-box; }
body { margin: 0; background: #dfe3e8; font-family: "Segoe UI", Arial, sans-serif; color: #182230; }
.hoja { width: 210mm; height: 297mm; margin: 0 auto; background: #fff; padding: 12mm 16mm 14mm; position: relative; page-break-after: always; overflow: hidden; }
.hoja:last-child { page-break-after: auto; }
.cuerpo { height: 271mm; overflow: hidden; }
.pie { position: absolute; left: 16mm; right: 16mm; bottom: 6mm; display: flex; justify-content: space-between; border-top: .35mm solid #d8dde5; padding-top: 2mm; font-size: 8pt; color: #7a8698; }
.kicker { margin: 0 0 1.5mm; font-size: 8pt; font-weight: 700; letter-spacing: 1.1pt; text-transform: uppercase; color: #a07c2c; }
h1 { margin: 0 0 4mm; font-size: 24pt; line-height: 1.1; color: #0d1529; }
h2 { margin: 0 0 3mm; padding-bottom: 2mm; border-bottom: .8mm solid #d6b25e; font-size: 15pt; color: #0d1529; }
h3 { margin: 4mm 0 2mm; font-size: 11pt; color: #0d1529; }
p, li { font-size: 9.5pt; line-height: 1.45; }
p { margin: 0 0 2.5mm; }
table { width: 100%; border-collapse: collapse; font-size: 9pt; }
th { padding: 2mm 2.5mm; background: #0d1529; color: #fff; text-align: left; font-size: 8.5pt; letter-spacing: .3pt; }
td { padding: 2mm 2.5mm; border: .3mm solid #d8dde5; vertical-align: top; }
tbody tr:nth-child(even) td { background: #f5f7fa; }
.ruta { margin: 0 0 3mm; padding: 2mm 3mm; border-left: 1mm solid #d6b25e; background: #faf6ec; font-size: 9pt; }
.ruta b { color: #7a5c17; }
.fila { display: flex; gap: 6mm; }
.fig { flex: none; width: 76mm; }
.recorte { overflow: hidden; border: .3mm solid #26324a; border-radius: 3mm; background: #070a12; }
.fig img { display: block; width: 76mm; }
.fig .nota { margin: 1.5mm 0 0; font-size: 7.5pt; color: #7a8698; line-height: 1.35; }
.pasos { flex: 1; margin: 0; padding: 0; list-style: none; }
.pasos li { position: relative; margin: 0 0 2.6mm; padding-left: 8mm; font-size: 9.3pt; line-height: 1.4; }
.pasos li::before { content: counter(p); counter-increment: p; position: absolute; left: 0; top: .2mm; display: flex; align-items: center; justify-content: center; width: 5.6mm; height: 5.6mm; border-radius: 50%; background: #d6b25e; color: #0b0e19; font-size: 8.5pt; font-weight: 700; }
.resultado { margin-top: 3mm; padding: 2mm 3mm; border: .3mm solid #bfe3cb; background: #eef7f0; font-size: 9pt; }
.resultado b { color: #1d6b3a; }
.aviso { margin: 0 0 3mm; padding: 2mm 3mm; border: .3mm solid #f0d9a8; background: #fdf6e6; font-size: 9pt; }
.indice { list-style: none; margin: 0; padding: 0; }
.indice li { display: flex; align-items: baseline; gap: 2mm; margin: 0 0 1.6mm; font-size: 9.5pt; }
.indice li.n2 { padding-left: 6mm; font-size: 9pt; color: #3c4a5e; }
.indice li.n3 { padding-left: 12mm; font-size: 8.5pt; color: #5b6a80; }
.indice .linea { flex: 1; border-bottom: .3mm dotted #b9c2cf; }
.indice .pag { font-weight: 700; color: #0d1529; }
.marca { display: inline-flex; align-items: center; justify-content: center; width: 5.6mm; height: 5.6mm; border-radius: 50%; background: #d6b25e; color: #0b0e19; font-size: 8.5pt; font-weight: 700; vertical-align: middle; }
.firma { margin-top: 6mm; display: flex; gap: 10mm; }
.firma div { flex: 1; border-top: .4mm solid #182230; padding-top: 2mm; font-size: 8.5pt; color: #3c4a5e; }
.portada { margin: -12mm -16mm 6mm; padding: 10mm 16mm 8mm; background: #ffffff; color: #182230; }
.portada .oro { color: #a9832f; font-size: 10pt; font-weight: 700; letter-spacing: 2pt; }
.portada h1 { color: #0d1529; margin: 2mm 0 1mm; }
.portada p { color: #5b6a80; margin: 0; }
.logo-portada { display: block; margin: 0 auto 3mm; width: 30mm; height: auto; }
svg text { font-family: "Segoe UI", Arial, sans-serif; }
`;

const MM_PX = 76 / 390;
const ALTO_FIG = 232;

const alturas = {};
for (const id of Object.keys(MARCAS)) {
  const svg = fs.readFileSync(path.join(__dirname, "imagenes", `${id}.svg`), "utf8");
  alturas[id] = Number((svg.match(/height="(\d+)"/) || [])[1] || 844);
}

const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

function libro(titulo, paginas) {
  const total = paginas.length;
  const html = paginas
    .map(
      (p, i) => `<div class="hoja"><div class="cuerpo">${p.c}</div>
<div class="pie"><span>Barber King · ${titulo}</span><span>Página ${i + 1} de ${total}</span></div></div>`
    )
    .join("\n");
  return `<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8"><title>${titulo} · Barber King</title><style>${CSS}</style></head>
<body>${html}</body></html>`;
}

// ---------------------------------------------------------------- usuario
const TAREAS = [
  {
    id: "02-login", titulo: "Iniciar sesión", rol: "Acceso",
    ruta: "Splash → <b>Iniciar sesión</b> (se abre sola cuando no hay una sesión guardada en el equipo).",
    pasos: [
      "Escribe el correo con el que te registraste; tiene que coincidir tal cual, sin espacios.",
      "Escribe la contraseña. El ojo del campo la muestra mientras escribes y la esconde cuando la tapas.",
      "Si la olvidaste, toca <b>¿Olvidaste tu contraseña?</b> y sigue la tarea 6.4.",
      "Pulsa <b>Iniciar sesión</b>: la app revisa tus datos y te lleva al panel de tu rol.",
      "O usa <b>Continuar con Google</b>: elige tu cuenta de Google y entra sin contraseña.",
      "Si aún no tienes cuenta, toca <b>Crear cuenta</b> y sigue la tarea 6.2 o la 6.3.",
    ],
    resultado: "Entras al panel de tu rol y la sesión se guarda en el dispositivo.",
  },
  {
    id: "03-registro", titulo: "Crear cuenta de cliente", rol: "Acceso",
    ruta: "Iniciar sesión → <b>Crear cuenta</b> → tipo de cuenta <b>Cliente</b>.",
    pasos: [
      "En <b>Tipo de cuenta</b> deja seleccionado <b>Cliente</b>; es el valor con el que nace la cuenta.",
      "Escribe tus nombres tal como quieres que te vea el barbero el día de la cita.",
      "Escribe un correo válido: será tu usuario para entrar y para recuperar la contraseña.",
      "Escribe tu teléfono para que el negocio pueda escribirte si hay un cambio.",
      "Toca <b>Fecha de nacimiento</b> y elige el día en el calendario que se abre.",
      "Crea una contraseña con mínimo 6 caracteres.",
      "Repite la contraseña exactamente igual; si no coincide, la app te avisa antes de enviarla.",
      "Pulsa <b>CREAR CUENTA</b>: se crea el usuario y entras directo al Inicio del cliente.",
      "Si ya tenías cuenta, <b>Ya tengo una cuenta</b> te devuelve al inicio de sesión.",
    ],
    resultado: "Cuenta de cliente creada y sesión iniciada: ya puedes reservar tu primera cita.",
  },
  {
    id: "30-registro-barbero", titulo: "Crear cuenta de barbero", rol: "Acceso",
    ruta: "Iniciar sesión → <b>Crear cuenta</b> → tipo de cuenta <b>Barbero</b>.",
    pasos: [
      "Cambia <b>Tipo de cuenta</b> a <b>Barbero</b>: el formulario agrega la parte profesional.",
      "Completa nombres y apellidos reales; así los verá el cliente y el administrador.",
      "Escribe el correo con el que ejercerás; será tu usuario de acceso.",
      "Define la contraseña y confírmala (mínimo 6 caracteres).",
      "Escribe tu <b>especialidad</b> (por ejemplo “Fade y barba”); es obligatoria.",
      "Indica tus años de experiencia, entre 0 y 70.",
      "Redacta la descripción profesional: es el texto que el cliente leerá en tu perfil.",
      "Pulsa <b>Adjuntar diploma o certificado</b> y elige el PDF o la imagen; sin documento no hay verificación.",
      "Confirma que el documento aparece cargado y listo para subir antes de enviar.",
      "Agrega fotos de tu trabajo: hasta 6 por envío; forman tu portafolio público.",
      "Pulsa <b>REGISTRARME COMO BARBERO</b>: la cuenta se crea y la revisión del diploma sigue el proceso.",
    ],
    resultado: "Cuenta creada. Si el diploma es válido, el sello de verificado se activa al instante; si falta o la revisión no lo reconoce, queda en la bandeja del administrador (tarea 6.27).",
  },
  {
    id: "04-recuperar", titulo: "Recuperar contraseña: pedir el código", rol: "Acceso",
    ruta: "Iniciar sesión → <b>¿Olvidaste tu contraseña?</b>",
    pasos: [
      "Escribe el correo de la cuenta que quieres recuperar.",
      "Pulsa <b>ENVIAR CÓDIGO</b>: el código llega a ese correo en unos minutos.",
      "Si ya tienes el código, <b>Ya tengo un código</b> te lleva directo a la pantalla de cambio (tarea 6.5).",
    ],
    resultado: "El código fue enviado. Revisa también la carpeta de spam o correo no deseado.",
  },
  {
    id: "05-restablecer", titulo: "Restablecer la contraseña", rol: "Acceso",
    ruta: "Recuperar contraseña → <b>Ya tengo un código</b>.",
    pasos: [
      "Confirma que el correo mostrado corresponde a tu cuenta.",
      "Escribe el código de 6 dígitos que llegó al correo.",
      "Escribe la nueva contraseña, con mínimo 6 caracteres.",
      "Repite la nueva contraseña en <b>Confirmar contraseña</b> para validar que se escribió bien.",
      "Pulsa <b>CAMBIAR CONTRASEÑA</b>: la anterior deja de valer de inmediato.",
    ],
    resultado: "Contraseña actualizada; usa la nueva la próxima vez que inicies sesión.",
  },
  {
    id: "07-cliente-home", titulo: "Inicio del cliente", rol: "Cliente",
    ruta: "Barra inferior → pestaña <b>Inicio</b>.",
    pasos: [
      "El icono de perfil abre <b>Mi perfil</b> (tarea 6.15).",
      "El icono de salir cierra la sesión en este dispositivo.",
      "<b>Ver mis citas</b>, en la tarjeta de la próxima cita, abre la lista completa (tarea 6.11).",
      "Los contadores resumen tus citas, las completadas y los servicios del catálogo.",
      "La tarjeta <b>Servicios</b> abre el catálogo con precios y duración (tarea 6.13).",
      "La tarjeta <b>Mi perfil</b> es un segundo camino hacia tus datos.",
      "<b>Asesor de estilo con IA</b> abre el chat que recomienda cortes (tarea 6.14).",
      "El botón flotante <b>Reservar</b> inicia una reserva nueva (tarea 6.10).",
      "La barra inferior cambia entre <b>Inicio, Citas y Barberos</b> sin perder tu lugar.",
    ],
    resultado: "Desde aquí alcanzas en un toque todas las tareas del cliente.",
  },
  {
    id: "08-barberos", titulo: "Buscar y elegir barbero", rol: "Cliente",
    ruta: "Barra inferior → pestaña <b>Barberos</b>.",
    pasos: [
      "El panel <b>Mejor calificados</b> muestra a los barberos con mejores reseñas; toca uno para abrir su perfil.",
      "Escribe un nombre o una zona en el buscador para filtrar la lista.",
      "<b>Cerca de mí</b> filtra los barberos a menos de 15 km de tu ubicación actual.",
      "Toca la tarjeta del barbero para abrir su perfil con fotos y reseñas (tarea 6.8).",
      "<b>Reservar</b> lleva directo a crear la cita con ese barbero; si está inactivo, el botón aparece desactivado.",
      "La pestaña <b>Barberos</b> de la barra inferior te devuelve a esta lista cuando quieras.",
    ],
    resultado: "Barbero elegido: puedes reservar de inmediato o revisar primero su perfil.",
  },
  {
    id: "22-perfil-barbero", titulo: "Perfil público del barbero", rol: "Cliente",
    ruta: "Barberos → <b>tarjeta del barbero</b>.",
    pasos: [
      "El sello indica si el barbero está <b>verificado</b> y si está disponible ahora.",
      "Aquí ves su zona, la distancia a tu posición y sus años de experiencia.",
      "<b>Reservar cita</b> abre la reserva con el barbero ya elegido (tarea 6.10).",
      "<b>Ubicación</b> abre el mapa con su punto actual (tarea 6.9).",
      "<b>Calificar mi cita</b> aparece solo si ya tienes una cita completada con él (tarea 6.12).",
      "<b>Reseñas</b> muestra los comentarios de otros clientes; el enlace <b>Ver las N reseñas</b> abre la lista completa.",
    ],
    resultado: "Con fotos, reseñas y sello de verificación decides si reservas con ese barbero.",
  },
  {
    id: "29-cliente-mapa", titulo: "Ver la ubicación del barbero", rol: "Cliente",
    ruta: "Perfil del barbero → <b>Ubicación</b>.",
    pasos: [
      "El mapa marca el punto que el barbero publicó desde su panel.",
      "Debajo del mapa aparecen su nombre, la distancia y la zona.",
      "<b>Actualizar</b> vuelve a leer la ubicación publicada por si se movió.",
      "La hora de la última actualización te dice qué tan reciente es el punto; si es vieja, el barbero no está compartiendo.",
    ],
    resultado: "Sabes dónde atenderá tu cita antes de salir de casa.",
  },
  {
    id: "10-crear-cita", titulo: "Reservar una cita", rol: "Cliente",
    ruta: "Inicio → <b>Reservar</b> (también Barberos → Reservar o Servicios → Reservar este servicio).",
    pasos: [
      "Elige el <b>servicio</b>: define el precio y la duración de la cita.",
      "Elige el <b>barbero</b>; solo aparecen los que atienden ese servicio y están activos.",
      "Toca <b>Fecha</b> y elige un día dentro de los próximos 90 días.",
      "Toca un chip de hora: solo se muestran los horarios libres según la jornada del barbero.",
      "Pulsa <b>CONFIRMAR RESERVA</b>: la app valida el horario y deja la cita <b>Confirmada</b> al instante, sin esperar que el barbero la apruebe.",
    ],
    resultado: "Cita confirmada: la ves en Mis citas y el barbero la ve en su Agenda del día.",
  },
  {
    id: "09-citas", titulo: "Gestionar mis citas", rol: "Cliente",
    ruta: "Barra inferior → pestaña <b>Citas</b>.",
    pasos: [
      "Filtra por <b>Todas, Pendiente, Confirmada, Completada o Cancelada</b>.",
      "Cada tarjeta muestra fecha, hora, servicio, barbero y precio de la cita.",
      "<b>Reprogramar</b> abre la reserva con el mismo barbero y servicio; al guardar la nueva cita, la anterior se cancela automáticamente.",
      "<b>Cancelar</b> pide confirmación y deja la cita en <b>Cancelada</b>; el historial no se borra.",
      "<b>Calificar</b> aparece solo en citas completadas y abre la hoja de reseña (tarea 6.12).",
      "El botón flotante <b>Nueva cita</b> crea otra reserva sin salir de la lista.",
      "La pestaña <b>Citas</b> de la barra inferior siempre te trae de vuelta a esta pantalla.",
    ],
    resultado: "Control total de tu historial: reprogramas, cancelas y calificas sin llamar al negocio.",
  },
  {
    id: "23-resena", titulo: "Calificar una cita", rol: "Cliente",
    ruta: "Mis citas → <b>Calificar</b> (o perfil del barbero → <b>Calificar mi cita</b>).",
    pasos: [
      "Toca de 1 (<b>Muy mal</b>) a 5 (<b>Excelente</b>) estrellas según tu experiencia.",
      "Escribe un comentario opcional de hasta 300 caracteres contando qué te gustó.",
      "Pulsa <b>Publicar reseña</b>: tu calificación aparece en el perfil del barbero y en su panel.",
    ],
    resultado: "Una reseña por cita. Cuando ya calificaste, el botón Calificar desaparece de esa cita.",
  },
  {
    id: "12-servicios", titulo: "Consultar el catálogo de servicios", rol: "Cliente",
    ruta: "Inicio → tarjeta <b>Servicios</b>.",
    pasos: [
      "Busca por nombre en el buscador (por ejemplo “barba” o “fade”).",
      "Cada tarjeta muestra el precio y la duración definidos por el negocio.",
      "<b>Reservar este servicio</b> abre la reserva con el servicio ya elegido (tarea 6.10).",
    ],
    resultado: "Comparas precios y duración antes de reservar.",
  },
  {
    id: "21-chat-ia", titulo: "Asesor de estilo con IA", rol: "Cliente",
    ruta: "Inicio → <b>Asesor de estilo con IA</b>.",
    pasos: [
      "<b>Nueva conversación</b> limpia el historial y empieza el chat de cero.",
      "Toca una de las sugerencias listas para enviarla tal cual.",
      "O escribe tu pregunta en el campo <b>Pregunta o sube una foto...</b>: el asistente responde con el catálogo real de servicios y precios.",
      "El botón de cámara abre la galería o la cámara y analiza la foto para recomendarte un corte.",
      "Pulsa el botón dorado de enviar; la respuesta llega en segundos.",
    ],
    resultado: "Recomendaciones de corte y barba antes de decidir qué reservar.",
  },
  {
    id: "13-perfil", titulo: "Mi perfil (cliente)", rol: "Cliente",
    ruta: "Inicio → <b>icono de perfil</b> (o tarjeta Mi perfil).",
    pasos: [
      "La cámara sobre el avatar cambia tu foto de perfil.",
      "<b>Editar</b> abre la hoja para corregir nombres, apellidos, teléfono y fecha de nacimiento.",
      "<b>Contraseña</b> abre el cambio de contraseña escribiendo la actual.",
      "Revisa tu información personal antes de cerrar la hoja.",
      "<b>CERRAR SESIÓN</b> termina la sesión en este dispositivo; tus datos quedan en la nube.",
    ],
    resultado: "Datos al día y sesión cerrada de forma segura cuando prestas el teléfono.",
  },
  {
    id: "18-barbero-home", titulo: "Panel del barbero", rol: "Barbero",
    ruta: "Barra inferior → pestaña <b>Inicio</b> (con rol Barbero).",
    pasos: [
      "El icono de perfil abre tu perfil profesional (tarea 6.22).",
      "El icono de salir cierra la sesión en este dispositivo.",
      "La tarjeta <b>Agenda de hoy</b> resume las citas del día.",
      "<b>Gestionar</b> abre la Agenda completa con la línea de tiempo (tarea 6.17).",
      "El interruptor de <b>ubicación en tiempo real</b> comparte tu punto con los clientes.",
      "Los contadores muestran citas, pendientes, completadas y tu calificación promedio.",
      "<b>Servicios que atiendo</b>: activa servicios y ajusta tu precio y minutos (tarea 6.20).",
      "<b>Mis fotos</b>: administra tu portafolio (tarea 6.21).",
      "<b>Mi perfil</b>: datos profesionales y diploma (tarea 6.22).",
      "<b>Asesor IA</b>: el mismo chat de estilo, también disponible para el barbero.",
      "La barra inferior cambia entre <b>Inicio, Agenda y Horarios</b>.",
    ],
    resultado: "Un solo tablero con todo lo que el barbero necesita para trabajar el día.",
  },
  {
    id: "24-barbero-agenda", titulo: "Agenda del día (línea de tiempo)", rol: "Barbero",
    ruta: "Barra inferior → <b>Agenda</b> (o Inicio → <b>Gestionar</b>).",
    pasos: [
      "El icono de actualizar recarga la agenda; el de calendario salta a cualquier fecha.",
      "La semana se mueve con las flechas; toca un día para abrirlo y <b>Hoy</b> vuelve al día actual.",
      "El resumen del día trae reservas, ingreso esperado y conteo por estado.",
      "<b>Ocultar cerradas</b> esconde completadas y canceladas para ver solo lo vivo.",
      "Toca la tarjeta de una cita para abrir el detalle con horario y observaciones.",
      "Si una reserva antigua aparece en <b>Pendiente</b>, <b>Confirmar</b> la pasa a Confirmada; las reservas nuevas ya llegan confirmadas.",
      "El menú de la cita permite cancelarla o reabrir una cita completada.",
      "<b>Completar</b> cierra la cita cuando el cliente ya fue atendido y habilita su calificación.",
      "La línea <b>Ahora</b> marca la hora actual; entre citas verás los minutos libres.",
      "La barra inferior te lleva a Inicio, Agenda u Horarios sin perder el día abierto.",
    ],
    resultado: "El día se lee como una línea de tiempo: atiendes, completas y cancelas sin salir de la pantalla.",
  },
  {
    id: "11-horarios", titulo: "Mis horarios (jornadas)", rol: "Barbero",
    ruta: "Barra inferior → pestaña <b>Horarios</b>.",
    pasos: [
      "El resumen indica cuántos días tienen jornada y cuántas están activas.",
      "El botón <b>+</b> agrega una jornada nueva (tarea 6.19).",
      "Cada tarjeta del día muestra su horario y su estado.",
      "El menú de la tarjeta permite <b>Editar, Activar, Desactivar o Eliminar</b> la jornada.",
      "El botón flotante <b>Agregar jornada</b> es el mismo camino que el +.",
      "La pestaña <b>Horarios</b> de la barra inferior te devuelve a esta lista.",
    ],
    resultado: "Sin jornada activa ese día, el cliente no ve horas libres para reservarte: tus horarios mandan sobre la reserva.",
  },
  {
    id: "28-barbero-jornada", titulo: "Crear una jornada de trabajo", rol: "Barbero",
    ruta: "Horarios → <b>+</b> (o <b>Agregar jornada</b>).",
    pasos: [
      "Elige el <b>día de trabajo</b> en el selector.",
      "Define la <b>hora de inicio</b> de la jornada.",
      "Define la <b>hora de fin</b>; debe ser posterior a la de inicio.",
      "El interruptor <b>Jornada activa</b> define si el día acepta reservas desde ya.",
      "Pulsa <b>Crear jornada</b>: las horas libres de ese día aparecen al cliente al reservar.",
      "<b>Cancelar</b> cierra la hoja sin guardar nada.",
    ],
    resultado: "Jornada guardada: ese día ya ofrece horarios libres en la reserva del cliente.",
  },
  {
    id: "25-barbero-servicios", titulo: "Servicios que atiendo", rol: "Barbero",
    ruta: "Inicio → <b>Servicios que atiendo</b>.",
    pasos: [
      "El interruptor define si atiendes o no ese servicio del catálogo.",
      "La línea de catálogo muestra el precio y la duración base del negocio.",
      "<b>Tu precio</b>: déjalo vacío para usar el del catálogo o escribe el tuyo.",
      "<b>Tus minutos</b>: igual; vacío usa la duración base del catálogo.",
      "Pulsa <b>GUARDAR SERVICIOS</b>: los cambios aplican a tu perfil y a las reservas nuevas.",
    ],
    resultado: "Solo los servicios que atiendes aparecen como opción al reservar contigo.",
  },
  {
    id: "26-barbero-fotos", titulo: "Mis fotos (portafolio)", rol: "Barbero",
    ruta: "Inicio → <b>Mis fotos</b>.",
    pasos: [
      "El contador muestra las fotos usadas; el máximo es 24.",
      "<b>AGREGAR FOTOS</b> abre la galería; puedes elegir hasta 6 por envío.",
      "Las fotos publicadas se ven en tu perfil público, en la cuadrícula de trabajos.",
      "La papelera de cada foto publicada la borra de tu portafolio.",
      "Las fotos con la marca <b>NUEVA</b> quedan pendientes hasta que las publiques.",
      "<b>PUBLICAR FOTOS</b> sube las pendientes y las muestra en tu perfil.",
      "<b>Descartar la selección</b> quita las pendientes sin subir nada.",
    ],
    resultado: "Portafolio actualizado: el cliente reserva por lo que ve en tu perfil.",
  },
  {
    id: "31-barbero-perfil", titulo: "Perfil profesional del barbero", rol: "Barbero",
    ruta: "Inicio → <b>Mi perfil</b> (o icono de perfil).",
    pasos: [
      "La cámara sobre el avatar cambia tu foto de perfil.",
      "<b>Editar</b> abre la hoja con tus datos personales y profesionales.",
      "<b>Contraseña</b> abre el cambio de contraseña.",
      "Revisa la información personal: nombres, correo y teléfono.",
      "La información profesional (especialidad, experiencia y descripción) es la que ve el cliente.",
      "La tarjeta <b>Ubicación</b> muestra si estás compartiendo tu punto ahora.",
      "<b>Compartir ubicación actual</b> publica tu punto en este momento.",
      "El documento profesional y el sello indican tu estado de verificación.",
      "<b>Subir otro documento</b> reemplaza el diploma y lo envía de nuevo a revisión (IA y administrador).",
      "<b>CERRAR SESIÓN</b> termina la sesión en este dispositivo.",
    ],
    resultado: "Tu carta de presentación pública queda completa: foto, especialidad, diploma y ubicación.",
  },
  {
    id: "14-admin-home", titulo: "Panel del administrador", rol: "Administrador",
    ruta: "Iniciar sesión con una cuenta de rol <b>Admin</b> (este panel no usa barra inferior).",
    pasos: [
      "El icono de perfil abre los datos del administrador.",
      "El icono de salir cierra la sesión.",
      "Los indicadores <b>Usuarios, Barberos, Servicios y Citas</b> abren su gestión al tocarlos.",
      "El aviso de verificación avisa cuántos barberos esperan revisión de diploma.",
      "La distribución de citas por estado resume la operación; <b>Ver todas</b> abre la agenda general.",
      "<b>Usuarios</b>: crear, editar y desactivar cuentas (tarea 6.24).",
      "<b>Verificar barberos</b>: aprobar o rechazar diplomas; el número rojo son los pendientes (tarea 6.27).",
      "<b>Servicios</b>: catálogo, precios y duración (tarea 6.26).",
      "<b>Citas</b>: agenda general del negocio.",
      "<b>Barberos</b>: el equipo profesional y su estado.",
    ],
    resultado: "Toda la operación del negocio en un tablero: indicadores, avisos y accesos directos.",
  },
  {
    id: "15-admin-usuarios", titulo: "Gestión de usuarios", rol: "Administrador",
    ruta: "Panel → <b>Usuarios</b> (o indicador Usuarios).",
    pasos: [
      "Busca por nombre o correo en el buscador.",
      "Filtra por <b>Todos, Clientes, Barberos o Admins</b>.",
      "Cada tarjeta muestra el usuario con su rol.",
      "El menú de la tarjeta ofrece <b>Editar</b> o <b>Eliminar</b> (tarea 6.25 para editar).",
      "El estado indica si la cuenta está activa o desactivada.",
      "El botón flotante <b>Nuevo usuario</b> abre el formulario de creación (tarea 6.25).",
    ],
    resultado: "Altas, cambios y bajas de cuentas sin tocar la base de datos.",
  },
  {
    id: "16-admin-usuario-form", titulo: "Crear o editar un usuario", rol: "Administrador",
    ruta: "Usuarios → <b>Nuevo usuario</b> (o menú de la tarjeta → <b>Editar</b>).",
    pasos: [
      "Elige el <b>rol</b>: Cliente, Barbero o Admin.",
      "Escribe nombres y apellidos.",
      "Escribe el correo electrónico de la cuenta.",
      "Al editar, la <b>nueva contraseña</b> es opcional: vacía conserva la actual.",
      "El interruptor <b>Cuenta activa</b>: desactivar impide el acceso sin borrar el historial.",
      "Pulsa <b>GUARDAR CAMBIOS</b> (o <b>CREAR USUARIO</b> si es nuevo).",
    ],
    resultado: "Cuenta creada o actualizada al instante en la lista de usuarios.",
  },
  {
    id: "17-servicio-form", titulo: "Crear o editar un servicio", rol: "Administrador",
    ruta: "Panel → <b>Servicios</b> → nuevo servicio (o editar uno existente).",
    pasos: [
      "Escribe el <b>nombre</b> del servicio tal como lo verá el cliente.",
      "Redacta la descripción que explica qué incluye.",
      "Define el <b>precio</b> base del negocio.",
      "Define la <b>duración en minutos</b> que ocupa en la agenda.",
      "Define el <b>descanso</b> entre citas para limpiar y preparar la silla.",
      "El interruptor <b>Servicio activo</b> lo muestra u oculta del catálogo.",
      "Pulsa <b>CREAR SERVICIO</b> o <b>GUARDAR CAMBIOS</b>.",
    ],
    resultado: "El catálogo del cliente y los precios base de los barberos quedan actualizados.",
  },
  {
    id: "27-admin-revision", titulo: "Verificar barberos (diplomas)", rol: "Administrador",
    ruta: "Panel → <b>Verificar barberos</b> (o el aviso de verificación).",
    pasos: [
      "El contador indica cuántos barberos están pendientes de revisión.",
      "Cada tarjeta trae al barbero en revisión con su estado.",
      "Toca el <b>documento subido</b> para verlo completo antes de decidir.",
      "La nota de la IA con su porcentaje de confianza es un apoyo; la decisión final es tuya.",
      "<b>APROBAR</b> deja al barbero verificado y con sello visible para el cliente.",
      "<b>RECHAZAR</b> pide una nota con el motivo; el barbero la ve y puede subir otro documento.",
    ],
    resultado: "Solo barberos con documento aprobado muestran el sello de verificado en su perfil.",
  },
];

function paginaTarea(t, indice) {
  const marcas = MARCAS[t.id];
  if (marcas.length !== t.pasos.length) {
    throw new Error(`${t.id}: ${marcas.length} marcas pero ${t.pasos.length} pasos`);
  }
  const alto = alturas[t.id] * MM_PX;
  const partes = alto > ALTO_FIG ? 2 : 1;
  const paginas = [];
  for (let parte = 0; parte < partes; parte++) {
    const desde = parte * ALTO_FIG;
    const hasta = Math.min(alto, desde + ALTO_FIG);
    const indices = marcas.map((m, i) => i).filter((i) => {
      const y = marcas[i].y * MM_PX;
      return parte === 0 ? y <= desde + ALTO_FIG : y > desde;
    });
    const primero = indices[0];
    const lista = indices
      .map((i) => `<li>${t.pasos[i]}</li>`)
      .join("");
    const recorte = `<div class="recorte" style="height:${(hasta - desde).toFixed(1)}mm"><img src="imagenes/${t.id}.svg" style="margin-top:-${desde.toFixed(1)}mm" alt="Pantalla ${t.titulo}"></div>`;
    paginas.push({
      c: `
<p class="kicker">Sección 6 · Paso a paso · ${t.rol}${partes > 1 ? (parte === 0 ? " · pantalla completa, parte 1 de 2" : " · parte 2 de 2") : ""}</p>
<h2>6.${indice} · ${t.titulo}</h2>
<p class="ruta"><b>Ruta:</b> ${t.ruta}</p>
<div class="fila">
  <div class="fig">${recorte}
    <p class="nota">${parte === 0 ? "Pantalla de la app con los números de cada paso. La línea punteada une un número con su botón cuando el número vive en el margen." : "Continuación: parte inferior de la misma pantalla. Los números siguen el orden de los pasos."}</p>
  </div>
  <ol class="pasos" style="counter-reset:p ${primero}">${lista}</ol>
</div>
${parte === partes - 1 && t.resultado ? `<p class="resultado"><b>Al terminar:</b> ${t.resultado}</p>` : ""}`,
      rotulo: parte === 0 ? { n: 2, texto: `6.${indice} · ${t.titulo}` } : null,
    });
  }
  return paginas;
}

function construirUsuario() {
  const P = [];
  const add = (c, rotulo) => P.push({ c, rotulo });

  add(`
<div class="portada"><img class="logo-portada" src="data:image/png;base64,${LOGO_EMBLEM_DORADO}" alt="Logo Barber King" />
<span class="oro">BARBER KING</span>
<h1>Manual de usuario</h1>
<p>App móvil de reservas y gestión para barbería · versión 1.1</p></div>
<p class="kicker">Sección 1 · Hoja de control</p>
<h2>1 · Hoja de control</h2>
<table><tbody>
<tr><td style="width:38%"><b>Nombre del sistema</b></td><td>Barber King — reservas y gestión de barbería (app Android + API en la nube).</td></tr>
<tr><td><b>Cliente</b></td><td>Barber King (barbería). Proyecto formativo del programa de Análisis y Desarrollo de Software.</td></tr>
<tr><td><b>Autores</b></td><td>Hernando (Hernando2007) — análisis, desarrollo Flutter, backend, base de datos y despliegue.</td></tr>
<tr><td><b>Ficha del programa</b></td><td>____________________ (se completa a mano al entregar).</td></tr>
<tr><td><b>Fecha de elaboración</b></td><td>10 de noviembre de 2026.</td></tr>
<tr><td><b>Versión del documento</b></td><td>1.1 (oficial).</td></tr>
<tr><td><b>Documento</b></td><td>Manual de usuario · uno de los tres manuales del RA 03 (usuario, técnico e instalación).</td></tr>
</tbody></table>
<h3>Historial de revisiones</h3>
<table><thead><tr><th>Versión</th><th>Fecha</th><th>Tipo</th><th>Descripción del cambio</th></tr></thead><tbody>
<tr><td>0.1</td><td>2026-11-09</td><td>Borrador</td><td>Primera versión revisable: estructura de 8 secciones y tareas por rol.</td></tr>
<tr><td>1.0</td><td>2026-11-09</td><td>Oficial</td><td>Versión final con las 27 pantallas señalizadas, mapa de navegación, problemas y glosario.</td></tr>
<tr><td>1.1</td><td>2026-11-10</td><td>Ajuste</td><td>Reserva confirmada automática, verificación con IA, chat solo con asesor y textos de ayuda actualizados.</td></tr>
</tbody></table>
<h3>Aprobación del cliente</h3>
<p>Con mi firma acepto que este manual describe el sistema entregado en su versión 1.1 y que las tareas documentadas corresponden a la aplicación recibida.</p>
<div class="firma"><div>Firma del cliente · nombre y documento</div><div>Fecha de aprobación</div></div>
<div class="firma"><div>Elaboró: Hernando Botello Vargas y Yonanderson Marroquin</div><div>Revisó · instructor del programa</div></div>
`, { n: 1, texto: "1 · Hoja de control" });

  const indiceAqui = P.length;
  add("", { n: 1, texto: "2 · Índice" });

  add(`
<p class="kicker">Sección 3 · Objeto, alcance y funcionalidades</p>
<h2>3 · Objeto, alcance y funcionalidades</h2>
<h3>3.1 · Para qué sirve este manual y la app</h3>
<p>Este manual le enseña a cualquier persona a usar Barber King sin ayuda: entrar, reservar, atender y administrar. La app existe para que el cliente reserve su cita en segundos, el barbero organice su día como una línea de tiempo y el administrador controle el negocio completo desde un solo tablero.</p>
<h3>3.2 · Qué cubre el sistema</h3>
<p>Cubre el ciclo completo de una cita: el cliente elige servicio, barbero, fecha y hora libre; la app valida el horario y deja la cita <b>Confirmada</b> al instante; el barbero la atiende y la marca <b>Completada</b>; el cliente la <b>Califica</b>. Además cubre cuentas y roles, jornadas de trabajo, portafolio de fotos, ubicación del barbero en mapa, catálogo de servicios, verificación de diplomas con apoyo de la IA y un asesor de estilo con inteligencia artificial.</p>
<h3>3.3 · Qué NO incluye esta versión</h3>
<table><thead><tr><th>No incluye</th><th>Qué hacer mientras tanto</th></tr></thead><tbody>
<tr><td>Chat directo entre cliente y barbero.</td><td>El estado de la cita es el canal: si necesitas cambiarla, usa Reprogramar o Cancelar. El asesor IA resuelve dudas de estilo y catálogo, pero no es una persona.</td></tr>
<tr><td>Pagos en línea o pasarela de pago.</td><td>El precio se muestra en la cita y se paga en el negocio.</td></tr>
<tr><td>Notificaciones push del servidor.</td><td>La app programa un recordatorio local en el teléfono para la próxima cita.</td></tr>
<tr><td>Versión web o iOS publicada.</td><td>Esta versión se distribuye como APK para Android.</td></tr>
<tr><td>Inventario, facturación electrónica o multi-sucursal.</td><td>El sistema administra una sola barbería con su equipo de barberos.</td></tr>
</tbody></table>
`, { n: 1, texto: "3 · Objeto, alcance y funcionalidades" });

  add(`
<p class="kicker">Sección 3 · Objeto, alcance y funcionalidades</p>
<h2>3.4 · Lista de módulos</h2>
<table><thead><tr><th>Módulo</th><th>Rol</th><th>Qué hace</th><th>Tareas</th></tr></thead><tbody>
<tr><td>Acceso y sesión</td><td>Todos</td><td>Iniciar sesión, crear cuenta de cliente o barbero, recuperar y cambiar contraseña, acceso con Google.</td><td>6.1 a 6.5</td></tr>
<tr><td>Inicio del cliente</td><td>Cliente</td><td>Próxima cita, contadores y accesos a reservar, servicios, perfil y asesor IA.</td><td>6.6</td></tr>
<tr><td>Barberos y perfil público</td><td>Cliente</td><td>Lista con buscador, orden por calificación, perfil con fotos, reseñas y sello de verificado.</td><td>6.7, 6.8</td></tr>
<tr><td>Mapa de ubicación</td><td>Cliente / Barbero</td><td>El barbero comparte su punto; el cliente lo ve con distancia y hora de actualización.</td><td>6.9, 6.22</td></tr>
<tr><td>Reservas</td><td>Cliente</td><td>Crear cita con servicio, barbero, fecha y hora libre; reprogramar y cancelar.</td><td>6.10, 6.11</td></tr>
<tr><td>Reseñas</td><td>Cliente / Barbero</td><td>Calificar de 1 a 5 con comentario una cita completada; el barbero las recibe en su panel.</td><td>6.12</td></tr>
<tr><td>Catálogo de servicios</td><td>Cliente / Admin</td><td>Precios y duración del negocio; el barbero define cuáles atiende y su propio precio.</td><td>6.13, 6.20, 6.26</td></tr>
<tr><td>Asesor de estilo IA</td><td>Cliente / Barbero</td><td>Chat que recomienda cortes y analiza una foto del usuario.</td><td>6.14</td></tr>
<tr><td>Mi perfil</td><td>Todos</td><td>Foto, datos personales, contraseña y cierre de sesión.</td><td>6.15, 6.22</td></tr>
<tr><td>Panel del barbero</td><td>Barbero</td><td>Agenda de hoy, contadores, ubicación en tiempo real y herramientas de trabajo.</td><td>6.16</td></tr>
<tr><td>Agenda del barbero</td><td>Barbero</td><td>Semana navegable, resumen del día y línea de tiempo para confirmar, completar, cancelar o reabrir.</td><td>6.17</td></tr>
<tr><td>Horarios y jornadas</td><td>Barbero</td><td>Jornadas por día con hora de inicio y fin; definen los horarios libres que ve el cliente.</td><td>6.18, 6.19</td></tr>
<tr><td>Portafolio de fotos</td><td>Barbero</td><td>Hasta 24 fotos publicadas, 6 por envío, guardadas en Cloudinary.</td><td>6.21</td></tr>
<tr><td>Panel del administrador</td><td>Admin</td><td>Indicadores, distribución de citas por estado y accesos a toda la gestión.</td><td>6.23</td></tr>
<tr><td>Usuarios</td><td>Admin</td><td>Crear, editar, desactivar y eliminar cuentas de cualquier rol.</td><td>6.24, 6.25</td></tr>
<tr><td>Verificación de barberos</td><td>Admin</td><td>Revisar el diploma con apoyo de la IA y aprobar o rechazar con nota.</td><td>6.27</td></tr>
</tbody></table>
`, { n: 2, texto: "3.4 · Lista de módulos" });

  add(`
<p class="kicker">Sección 4 · Prerrequisitos</p>
<h2>4 · Prerrequisitos</h2>
<p>Antes de empezar, confirme que cumple lo siguiente. No necesita instalar nada más que la app.</p>
<table><thead><tr><th>Requisito</th><th>Detalle</th></tr></thead><tbody>
<tr><td><b>Dispositivo</b></td><td>Teléfono o tablet Android con pantalla táctil. Para el mapa y la ubicación, GPS activado.</td></tr>
<tr><td><b>Sistema operativo</b></td><td>Android con servicios de Google (necesarios para el acceso con Google y para el mapa).</td></tr>
<tr><td><b>Conexión</b></td><td>Internet estable (WiFi o datos móviles). Todo se guarda en la nube: sin conexión no se puede reservar ni iniciar sesión.</td></tr>
<tr><td><b>Cuenta</b></td><td>Una cuenta creada en la app (correo y contraseña) o una cuenta Google. El correo es el identificador de la cuenta.</td></tr>
<tr><td><b>Permisos</b></td><td>Ubicación: solo al usar el mapa o compartir su punto. Cámara y galería: solo al subir foto de perfil, portafolio o foto al asesor IA.</td></tr>
</tbody></table>
<h3>4.1 · El rol decide qué pantallas ve</h3>
<table><thead><tr><th>Rol</th><th>Quién es</th><th>Qué ve al entrar</th><th>Cómo se obtiene</th></tr></thead><tbody>
<tr><td><b>Cliente</b> (3)</td><td>Quien reserva citas.</td><td>Barra inferior con Inicio, Citas y Barberos.</td><td>Registro normal en la app o acceso con Google.</td></tr>
<tr><td><b>Barbero</b> (2)</td><td>Quien atiende las citas.</td><td>Barra inferior con Inicio, Agenda y Horarios.</td><td>Registro como Barbero con diploma; la IA lo revisa al instante y el administrador resuelve los casos dudosos.</td></tr>
<tr><td><b>Admin</b> (1)</td><td>Quien administra el negocio.</td><td>Panel de administración sin barra inferior.</td><td>Lo crea otro administrador desde Usuarios; no se elige en el registro público.</td></tr>
</tbody></table>
<p class="aviso"><b>Importante:</b> si entra con el rol equivocado no verá las pantallas de este manual para su tarea. Cierre sesión y entre con la cuenta correcta; el rol no se cambia desde el perfil.</p>
`, { n: 1, texto: "4 · Prerrequisitos" });

  add(`
<p class="kicker">Sección 5 · Mapa de navegación</p>
<h2>5 · Mapa de navegación (acceso y cliente)</h2>
<p>Cada caja es una pantalla y cada flecha un botón o enlace que la abre. La flecha punteada indica un regreso o el destino después de completar una acción.</p>
${mapaAccesoCliente()}
`, { n: 1, texto: "5 · Mapa de navegación" });

  add(`
<p class="kicker">Sección 5 · Mapa de navegación</p>
<h2>5 · Mapa de navegación (barbero y administrador)</h2>
${mapaBarberoAdmin()}
<p class="nota" style="font-size:8.5pt;color:#5b6a80">El administrador no usa barra inferior: todo se alcanza desde los indicadores y las filas de gestión de su panel. El barbero sí usa barra inferior con Inicio, Agenda y Horarios.</p>
`, { n: 2, texto: "5 · Mapa de navegación (barbero y admin)" });

  add(`
<p class="kicker">Sección 6 · Paso a paso con interfaz señalizada</p>
<h2>6 · Cómo leer esta sección</h2>
<p>Esta es la sección más importante del manual: cada tarea trae su <b>ruta</b> (cómo llegar), sus <b>pasos numerados</b> y la <b>pantalla de la app con los mismos números sobre cada botón</b>. Siga los números en orden: el círculo dorado <span class="marca">1</span> de la pantalla es el paso 1 de la lista.</p>
<table><thead><tr><th>Elemento</th><th>Qué significa</th></tr></thead><tbody>
<tr><td><span class="marca">n</span> sobre la pantalla</td><td>El paso número n de la lista de al lado. Cuando el número vive en el margen, una línea punteada dorada lo une con su botón.</td></tr>
<tr><td><b>Ruta</b></td><td>El camino de pantallas y toques para llegar: por ejemplo “Barra inferior → Citas”.</td></tr>
<tr><td><b>Al terminar</b></td><td>El resultado esperado; si no lo ve, revise la sección 7 de solución de problemas.</td></tr>
<tr><td>Pantalla en dos partes</td><td>Las pantallas más largas que una página se muestran en dos páginas consecutivas; los números continúan en orden.</td></tr>
</tbody></table>
<h3>Orden de las tareas</h3>
<p>Las tareas 6.1 a 6.5 son de acceso para todos los roles; 6.6 a 6.15 del cliente; 6.16 a 6.22 del barbero; 6.23 a 6.27 del administrador. Puede leer solo las de su rol: cada tarea es independiente y repite su ruta completa.</p>
<p class="aviso"><b>Nota sobre las capturas:</b> las pantallas muestran datos de ejemplo (nombres, precios y fechas de demostración). En su teléfono verá sus propios datos, con los mismos botones en los mismos lugares.</p>
`, { n: 1, texto: "6 · Paso a paso con interfaz señalizada" });

  TAREAS.forEach((t, i) => {
    for (const p of paginaTarea(t, i + 1)) P.push(p);
  });

  add(`
<p class="kicker">Sección 7 · Solución de problemas</p>
<h2>7 · Solución de problemas</h2>
<p>Busque lo que usted ve en la pantalla, lea la causa probable y aplique la solución. Si el problema sigue, contacte al administrador del negocio.</p>
<table><thead><tr><th style="width:30%">Problema (lo que usted ve)</th><th style="width:28%">Causa probable</th><th>Qué hacer</th></tr></thead><tbody>
<tr><td>“Correo o contraseña incorrectos” al iniciar sesión.</td><td>Un carácter de más, mayúsculas o la contraseña antigua tras un cambio.</td><td>Reescriba el correo sin espacios; use el ojo para ver la contraseña. Si la cambió hace poco, use la nueva o recupérela (tareas 6.4 y 6.5).</td></tr>
<tr><td>No llega el código de recuperación.</td><td>El correo quedó en spam o la dirección tiene un error.</td><td>Revise spam y correo no deseado; confirme que escribió el correo de la cuenta y pida el código de nuevo.</td></tr>
<tr><td>El botón Reservar de un barbero está desactivado.</td><td>El barbero está inactivo o no atiende el servicio elegido.</td><td>Elija otro barbero de la lista, o cambie el servicio; el sello de disponibilidad en su perfil indica si está activo.</td></tr>
<tr><td>No aparece ninguna hora libre al reservar.</td><td>Ese día no tiene jornada activa o ya está todo ocupado.</td><td>Pruebe otra fecha dentro de los 90 días; el barbero debe crear o activar su jornada (tareas 6.18 y 6.19).</td></tr>
<tr><td>Mi cita aparece en Pendiente.</td><td>Es una reserva antigua o el negocio la dejó pendiente.</td><td>Las reservas nuevas nacen Confirmadas. Si la suya está Pendiente, el barbero puede confirmarla desde su Agenda; mientras tanto puede reprogramar o cancelar.</td></tr>
<tr><td>No veo el botón Calificar en mi cita.</td><td>La cita no está Completada o ya la calificó.</td><td>Solo las citas completadas y sin reseña muestran Calificar; el barbero debe completarla tras atenderlo.</td></tr>
<tr><td>El mapa no muestra el punto del barbero o está viejo.</td><td>El barbero no está compartiendo ubicación o no tiene GPS activo.</td><td>Pulse Actualizar y mire la hora de la última actualización; si es vieja, el barbero debe activar su interruptor de ubicación.</td></tr>
<tr><td>No puedo subir fotos o el diploma.</td><td>Sin conexión, archivo muy pesado o formato no admitido.</td><td>Revise su conexión; use imagen JPG/PNG o PDF para el diploma; recuerde el máximo de 6 fotos por envío y 24 en total.</td></tr>
<tr><td>Entré y no veo las pantallas de mi rol.</td><td>La sesión abierta es de otra cuenta o de otro rol.</td><td>Cierre sesión desde el icono de salir y entre con la cuenta correcta; el rol lo define la cuenta, no el teléfono.</td></tr>
<tr><td>Mi cuenta de barbero no muestra el sello de verificado.</td><td>La IA no reconoció el diploma o el administrador lo rechazó con nota.</td><td>Revise el estado en su perfil y suba otro documento (tarea 6.22, paso 9); el sello llega tras la aprobación.</td></tr>
<tr><td>La app no abre o se queda en cargando.</td><td>Sin internet o sesión vencida.</td><td>Revise WiFi o datos, cierre la app por completo y vuelva a abrirla; si pide sesión, entre de nuevo.</td></tr>
<tr><td>No me llegó el recordatorio de mi cita.</td><td>El recordatorio es local del teléfono y requiere permisos de notificación.</td><td>Active las notificaciones de Barber King en los ajustes de Android y mantenga la app instalada; el recordatorio se programa en este dispositivo.</td></tr>
</tbody></table>
`, { n: 1, texto: "7 · Solución de problemas" });

  add(`
<p class="kicker">Sección 8 · Preguntas frecuentes y glosario</p>
<h2>8.1 · Preguntas frecuentes</h2>
<table><thead><tr><th style="width:42%">Pregunta</th><th>Respuesta</th></tr></thead><tbody>
<tr><td>¿Puedo reservar sin crear cuenta?</td><td>No. La cita necesita un dueño para avisarle y mostrarla en Mis citas; el registro toma un minuto y también puede entrar con Google.</td></tr>
<tr><td>¿Cuánto antes puedo reservar?</td><td>Hasta 90 días por adelantado, y solo en horarios libres de la jornada del barbero.</td></tr>
<tr><td>¿Puedo cancelar o cambiar mi cita?</td><td>Sí, mientras no esté completada ni cancelada: Reprogramar elige fecha y hora nuevas; Cancelar pide confirmación y deja la cita en Cancelada.</td></tr>
<tr><td>¿Quién confirma mi cita?</td><td>Nadie: al reservar, la app valida el horario y la deja Confirmada al instante. El barbero solo la marca Completada cuando te atiende.</td></tr>
<tr><td>¿Puedo calificar más de una vez?</td><td>No: una reseña por cita. Tras publicar, el botón Calificar desaparece de esa cita.</td></tr>
<tr><td>¿Qué significa el sello de verificado?</td><td>Que el diploma o certificado del barbero fue aprobado: la IA lo revisa al registrarse y el administrador decide los casos dudosos.</td></tr>
<tr><td>¿Puedo hablar por chat con mi barbero?</td><td>Esta versión no incluye chat directo: deje observaciones al reservar y siga el estado de la cita. El chat de la app es el asesor IA.</td></tr>
<tr><td>¿Se paga en la app?</td><td>No. La app muestra el precio; el pago se hace en el negocio el día de la cita.</td></tr>
<tr><td>¿Qué pasa si desactivo mi cuenta?</td><td>Un administrador puede desactivarla: no podrá entrar, pero su historial de citas se conserva.</td></tr>
<tr><td>¿Mis fotos y mi diploma son públicos?</td><td>Las fotos del portafolio sí, en su perfil. El diploma solo lo ven el administrador y la IA que lo revisa.</td></tr>
</tbody></table>
`, { n: 1, texto: "8 · Preguntas frecuentes y glosario" });

  add(`
<p class="kicker">Sección 8 · Preguntas frecuentes y glosario</p>
<h2>8.2 · Glosario</h2>
<table><thead><tr><th style="width:30%">Término</th><th>Qué significa en Barber King</th></tr></thead><tbody>
<tr><td><b>Cita</b></td><td>Reserva de un servicio con un barbero en una fecha y hora; tiene estado y precio.</td></tr>
<tr><td><b>Pendiente</b></td><td>Estado de una reserva antigua que aún espera confirmación; las reservas nuevas nacen Confirmadas.</td></tr>
<tr><td><b>Confirmada</b></td><td>La cita está reservada y validada; es el estado normal de toda cita nueva.</td></tr>
<tr><td><b>Completada</b></td><td>El cliente fue atendido; habilita la calificación con estrellas.</td></tr>
<tr><td><b>Cancelada</b></td><td>La cita no se atenderá; queda en el historial como registro.</td></tr>
<tr><td><b>Jornada</b></td><td>Bloque de trabajo de un barbero en un día (hora de inicio y fin); define los horarios libres.</td></tr>
<tr><td><b>Horario libre</b></td><td>Chip de hora que el cliente puede elegir porque cabe en la jornada y no choca con otra cita.</td></tr>
<tr><td><b>Rol</b></td><td>Tipo de cuenta: Admin (1), Barbero (2) o Cliente (3); decide las pantallas disponibles.</td></tr>
<tr><td><b>Verificado</b></td><td>Sello del barbero cuyo diploma fue aprobado por el administrador.</td></tr>
<tr><td><b>Portafolio</b></td><td>Cuadrícula de hasta 24 fotos de trabajos del barbero en su perfil público.</td></tr>
<tr><td><b>Reseña</b></td><td>Calificación de 1 a 5 estrellas con comentario opcional, ligada a una cita completada.</td></tr>
<tr><td><b>Agenda</b></td><td>Pantalla del barbero con semana navegable, resumen del día y línea de tiempo de citas.</td></tr>
<tr><td><b>Línea Ahora</b></td><td>Marca de la hora actual en la agenda; entre citas muestra los minutos libres.</td></tr>
<tr><td><b>Ubicación en tiempo real</b></td><td>Punto que el barbero comparte desde su panel y el cliente ve en el mapa.</td></tr>
<tr><td><b>Asesor IA</b></td><td>Chat con inteligencia artificial que recomienda estilos y analiza fotos; no es una persona.</td></tr>
<tr><td><b>Descanso</b></td><td>Minutos entre citas que el servicio reserva para limpiar y preparar la silla.</td></tr>
<tr><td><b>Barra inferior</b></td><td>Navegación de tres pestañas fija abajo: Inicio, Citas y Barberos (cliente) o Inicio, Agenda y Horarios (barbero).</td></tr>
<tr><td><b>APK</b></td><td>Archivo instalable de la app para Android; así se distribuye esta versión.</td></tr>
</tbody></table>
`, { n: 2, texto: "8.2 · Glosario" });

  const entradas = P.map((p, i) => ({ ...p.rotulo, pag: i + 1 })).filter((e) => e && e.texto);
  P[indiceAqui].c = `
<p class="kicker">Sección 2 · Índice</p>
<h2>2 · Índice</h2>
<ul class="indice">${entradas
    .map((e) => `<li class="n${e.n}"><span>${e.texto}</span><span class="linea"></span><span class="pag">${e.pag}</span></li>`)
    .join("")}</ul>
<p class="nota" style="font-size:8.5pt;color:#5b6a80">Los números de página corresponden a este documento impreso en A4. Las tareas de la sección 6 se listan en orden de lectura.</p>
`;
  return libro("Manual de usuario", P);
}

// ------------------------------------------------------- mapas de navegación
const caja = (x, y, w, h, label, color = "#0d1529") => `
<g><rect x="${x}" y="${y}" width="${w}" height="${h}" rx="7" fill="#fff" stroke="${color}" stroke-width="1.6"/>
<text x="${x + w / 2}" y="${y + h / 2 + 4}" font-size="11" font-weight="600" fill="${color}" text-anchor="middle">${label}</text></g>`;
const flecha = (x1, y1, x2, y2, punteada = false) => `
<path d="M${x1} ${y1} L${x2} ${y2}" fill="none" stroke="#8a94a6" stroke-width="1.4" ${punteada ? 'stroke-dasharray="4 3"' : ""} marker-end="url(#punta)"/>`;
const defsMapa = `<defs><marker id="punta" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" fill="#8a94a6"/></marker></defs>`;

function mapaAccesoCliente() {
  return `<svg viewBox="0 0 680 560" style="width:178mm">${defsMapa}
${caja(20, 10, 130, 36, "Splash")}
${caja(210, 10, 160, 36, "Iniciar sesión")}
${flecha(150, 28, 210, 28)}
${caja(20, 90, 150, 36, "Registro cliente", "#1d6b3a")}
${caja(190, 90, 150, 36, "Registro barbero", "#7a5c17")}
${caja(360, 90, 140, 36, "Recuperar")}
${caja(520, 90, 140, 36, "Nueva contraseña")}
${flecha(250, 46, 95, 90)}
${flecha(280, 46, 265, 90)}
${flecha(330, 46, 430, 90)}
${flecha(500, 108, 520, 108)}
${caja(250, 180, 180, 40, "Inicio cliente", "#1d6b3a")}
${flecha(95, 126, 300, 180)}
${flecha(265, 126, 330, 180, true)}
${caja(20, 270, 140, 36, "Mis citas", "#1d6b3a")}
${caja(180, 270, 140, 36, "Barberos", "#1d6b3a")}
${caja(340, 270, 140, 36, "Servicios", "#1d6b3a")}
${caja(500, 270, 160, 36, "Mi perfil", "#1d6b3a")}
${flecha(290, 220, 90, 270)}
${flecha(320, 220, 250, 270)}
${flecha(360, 220, 410, 270)}
${flecha(400, 220, 580, 270)}
${caja(20, 360, 150, 36, "Reservar cita", "#1d6b3a")}
${caja(190, 360, 150, 36, "Perfil del barbero", "#1d6b3a")}
${caja(360, 360, 140, 36, "Chat IA", "#1d6b3a")}
${caja(520, 360, 140, 36, "Editar perfil", "#1d6b3a")}
${flecha(60, 220, 60, 360)}
${flecha(250, 306, 265, 360)}
${flecha(430, 220, 430, 360)}
${flecha(580, 306, 590, 360)}
${caja(20, 450, 140, 36, "Dejar reseña", "#1d6b3a")}
${caja(190, 450, 150, 36, "Mapa ubicación", "#1d6b3a")}
${flecha(90, 306, 90, 450)}
${flecha(265, 396, 265, 450)}
${flecha(230, 396, 95, 450)}
${flecha(410, 306, 95, 360)}
${flecha(95, 396, 90, 270, true)}
<text x="20" y="530" font-size="10" fill="#5b6a80">Verde: pantallas del cliente. Dorado: registro de barbero. Flecha punteada: regreso tras completar la acción.</text>
</svg>`;
}

function mapaBarberoAdmin() {
  return `<svg viewBox="0 0 680 560" style="width:178mm">${defsMapa}
${caja(250, 10, 180, 40, "Inicio barbero", "#7a5c17")}
${caja(20, 100, 140, 36, "Agenda del día", "#7a5c17")}
${caja(180, 100, 140, 36, "Horarios", "#7a5c17")}
${caja(340, 100, 150, 36, "Servicios propios", "#7a5c17")}
${caja(510, 100, 150, 36, "Mis fotos", "#7a5c17")}
${flecha(290, 50, 90, 100)}
${flecha(320, 50, 250, 100)}
${flecha(360, 50, 415, 100)}
${flecha(400, 50, 585, 100)}
${caja(20, 190, 140, 36, "Detalle de cita", "#7a5c17")}
${caja(180, 190, 140, 36, "Nueva jornada", "#7a5c17")}
${caja(340, 190, 160, 36, "Perfil profesional", "#7a5c17")}
${caja(520, 190, 140, 36, "Chat IA", "#7a5c17")}
${flecha(90, 136, 90, 190)}
${flecha(250, 136, 250, 190)}
${flecha(430, 50, 420, 190)}
${flecha(470, 50, 590, 190)}
${caja(250, 300, 180, 40, "Panel administrador", "#8c2f2f")}
${caja(20, 390, 130, 36, "Usuarios", "#8c2f2f")}
${caja(170, 390, 130, 36, "Servicios", "#8c2f2f")}
${caja(320, 390, 120, 36, "Citas", "#8c2f2f")}
${caja(460, 390, 120, 36, "Barberos", "#8c2f2f")}
${flecha(290, 340, 85, 390)}
${flecha(320, 340, 235, 390)}
${flecha(360, 340, 380, 390)}
${flecha(400, 340, 520, 390)}
${caja(20, 480, 160, 36, "Verificar barberos", "#8c2f2f")}
${caja(200, 480, 150, 36, "Form. usuario", "#8c2f2f")}
${caja(370, 480, 150, 36, "Form. servicio", "#8c2f2f")}
${caja(540, 480, 120, 36, "Ver diploma", "#8c2f2f")}
${flecha(300, 340, 100, 480)}
${flecha(85, 426, 275, 480)}
${flecha(235, 426, 445, 480)}
${flecha(100, 516, 600, 516)}
<text x="20" y="548" font-size="10" fill="#5b6a80">Dorado: pantallas del barbero. Rojo: pantallas del administrador. La verificación abre el diploma antes de aprobar o rechazar.</text>
</svg>`;
}

const html = construirUsuario();
fs.writeFileSync(path.join(__dirname, "manual-usuario.html"), html);
console.log(`✓ manual-usuario.html (${(html.length / 1024).toFixed(0)} KB)`);