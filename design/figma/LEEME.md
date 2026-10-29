# Barber King · Pantallas para Figma

21 pantallas de la app y una hoja de sistema de diseño, en SVG editables.
Tamaño base 390 × 844. Las pantallas de formularios largos usan un marco más alto
para mostrar todo el contenido (03 = 1180, 16 = 940).

## Cómo importar a Figma

1. Instala la fuente **Poppins** (Google Fonts) en tu equipo. Figma usa la fuente
   instalada para las capas de texto; si no está, sustituye la tipografía.
2. Abre un archivo nuevo en Figma y arrastra los `.svg` de `salida/` al lienzo.
   También puedes usar *Menú → File → Place image* y elegir el SVG.
3. Cada archivo entra como un frame de 390 px de ancho con capas separadas:
   fondos, tarjetas, iconos y textos. Selecciona el frame y usa
   `Ctrl + Shift + G` para desagrupar y editar.
4. Los textos son capas de texto reales (no vectores): puedes cambiar el copy,
   el tamaño y el color desde el panel derecho.
5. Para reutilizar botones, campos o tarjetas, conviértelos en componentes con
   `Ctrl + Alt + K` y reemplaza las copias existentes.

## Contenido

| Archivo | Pantalla | Rol |
| --- | --- | --- |
| `00-sistema-diseno.svg` | Sistema de diseño (color, tipografía, componentes) | — |
| `01-splash.svg` | Splash | Acceso |
| `02-login.svg` | Iniciar sesión | Acceso |
| `03-registro.svg` | Crear cuenta | Acceso |
| `04-recuperar.svg` | Recuperar contraseña | Acceso |
| `05-restablecer.svg` | Nueva contraseña | Acceso |
| `06-cargando.svg` | Cargando sesión | Acceso |
| `07-cliente-home.svg` | Inicio cliente | Cliente |
| `08-barberos.svg` | Nuestros barberos | Cliente |
| `09-citas.svg` | Mis citas | Cliente |
| `10-crear-cita.svg` | Reservar cita | Cliente |
| `11-horarios.svg` | Mis horarios | Barbero |
| `12-servicios.svg` | Servicios | Cliente |
| `13-perfil.svg` | Mi perfil | Cliente |
| `14-admin-home.svg` | Panel administrador | Administrador |
| `15-admin-usuarios.svg` | Gestión de usuarios | Administrador |
| `16-admin-usuario-form.svg` | Editar usuario | Administrador |
| `17-servicio-form.svg` | Editar servicio | Administrador |
| `18-barbero-home.svg` | Panel del barbero | Barbero |
| `19-chat-contactos.svg` | Chat · contactos | Cliente |
| `20-chat-conversacion.svg` | Chat · conversación | Cliente |
| `21-chat-ia.svg` | Asistente IA | Cliente |

## Regenerar

```bash
cd design/figma
node generar.js
```

- `salida/` contiene los 22 SVG listos para Figma.
- `index.html` es una vista previa local de todas las pantallas (ábrelo en el navegador).
- `_verificacion/` guarda capturas de control; no forma parte de la entrega.

## Código fuente

- `sistema/tokens.js` — colores, tipografía y degradados de la app.
- `sistema/texto.js` — texto, párrafos y medición aproximada.
- `sistema/iconos.js` — set de iconos de trazo 24 × 24.
- `sistema/base.js` — fondo, barra de estado, app bar y elementos comunes.
- `sistema/componentes.js` — botones, campos, chips, insignias, tarjetas, avatar.
- `sistema/chat.js` — burbujas, separador de fecha y compositor de mensajes.
- `sistema/hoja.js` — hoja de sistema de diseño.
- `pantallas/` — una función `render()` por pantalla.
