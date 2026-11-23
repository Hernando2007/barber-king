# Barber King

Aplicación de gestión para barbería con API REST en **Node.js + Express**, base de datos **PostgreSQL (Supabase)** y cliente **Flutter** para Android, iOS y web.

El sistema cubre el flujo completo: registro e inicio de sesión, reserva de citas, agenda del barbero, horarios de atención, servicios, reseñas, chat directo cliente-barbero, asistente con IA y panel administrativo.

---

## Funcionalidades

### Cliente

- Registro e inicio de sesión con correo o Google.
- Recuperación y cambio de contraseña.
- Catálogo de servicios y barberos.
- Reserva de citas según disponibilidad y horarios. Las horas que ya pasaron
  aparecen en gris y no se pueden elegir.
- Historial y estado de sus citas.
- Calificación de barberos.
- Chat directo con barberos, con envío de imágenes.
- Chat con IA y recomendación de cortes a partir de una foto.
- Edición de perfil y foto.
- Eliminación de la propia cuenta desde la app (Mi perfil → Eliminar cuenta),
  con borrado de citas, reseñas, mensajes y demás datos asociados.

### Barbero

- Panel con resumen de su agenda.
- Gestión de horarios semanales (jornadas, activación y eliminación).
- Gestión de sus servicios y citas.
- Perfil profesional, foto y carga de diploma o certificado.
- Chat directo con sus clientes.

### Administrador

- Dashboard con métricas generales.
- CRUD completo de usuarios (clientes y barberos).
- CRUD completo de servicios.
- Gestión de barberos, citas y reseñas.
- Eliminación segura: si un usuario o servicio tiene registros asociados, el sistema solicita una confirmación adicional y elimina la información relacionada.

### Chat e IA

- Chat directo entre clientes y barberos con historial persistente.
- Sesiones deterministas por pareja de usuarios para evitar duplicados.
- Mensajes de texto e imágenes.
- Asistente virtual para consultas sobre servicios, precios y reservas: solo
  responde temas de la barbería y usa el catálogo real para precios y duraciones.
- Recomendación de cortes con visión artificial a partir de la cámara o galería.

El asistente de texto solo responde temas de barbería: toma precios y duraciones
del catálogo real, no confirma disponibilidad de un barbero (remite a la sección
"Citas"), corrige precios inventados y rechaza temas ajenos o diagnósticos
médicos. Si le piden algo que en una barbería no aplica, por ejemplo "cortes
para calvos", contesta con lógica: rapado a cero, perfilado de barba o cuidado
del cuero cabelludo. Las reglas están en `backend/services/chatPrompt.js`.

---

## Tecnologías

| Capa | Tecnologías |
| --- | --- |
| Backend | Node.js 20+, Express 5, Supabase JS, JWT, bcrypt, multer, nodemailer, Groq SDK, Helmet, Morgan, rate limiting |
| Frontend | Flutter 3.44+, Dart 3.12+, Material 3, Dio, flutter_secure_storage, image_picker, cached_network_image, Google Fonts |
| Base de datos | PostgreSQL en Supabase |
| IA | Groq (texto y visión) |
| Almacenamiento | Cloudinary (`barber-king/perfil`, `/portafolio`, `/documentos`, `/chat`) |

---

## Estructura del repositorio

```text
barber-king/
├── backend/                  API REST
│   ├── config/               Supabase, multer y servicios externos
│   ├── controllers/          Controladores HTTP
│   ├── middlewares/          Autenticación, roles, uploads y errores
│   ├── models/               Acceso a datos (Supabase)
│   ├── routes/               Definición de endpoints
│   ├── services/             Lógica de negocio
│   ├── uploads/              Archivos cargados en tiempo de ejecución
│   ├── utils/                Utilidades compartidas
│   ├── validators/           Validaciones
│   └── app.js / index.js     Configuración y arranque del servidor
├── frontend/barber_king_app/ Cliente Flutter
│   └── lib/
│       ├── core/             Tema, colores, formateadores y configuración
│       ├── models/           Modelos del cliente
│       ├── routes/           Rutas de navegación
│       ├── screens/          Pantallas por módulo
│       ├── services/         Consumo de la API
│       └── widgets/          Componentes reutilizables
├── database/                 Scripts SQL por módulo
└── README.md
```

---

## Documentación

- Manual de usuario de la aplicación (8 secciones, 27 tareas, mapa de navegación,
  interfaz señalizada, solución de problemas y FAQ):  
  [`documentacion/manual-usuario.html`](documentacion/manual-usuario.html) ·
  [`documentacion/pdf/manual-usuario.pdf`](documentacion/pdf/manual-usuario.pdf)
- Guía de publicación en Google Play (firma, AAB, Data Safety, prueba cerrada):  
  [`documentacion/play-store/guia-publicacion.md`](documentacion/play-store/guia-publicacion.md)
- Textos para la ficha de Play Store y formulario de seguridad de datos:  
  [`documentacion/play-store/textos-listing.md`](documentacion/play-store/textos-listing.md)
- Política de privacidad pública:  
  <https://barber-king.onrender.com/public/politica-privacidad.html>
- Cómo eliminar la cuenta:  
  <https://barber-king.onrender.com/public/eliminar-cuenta.html>
- Cómo solicitar la eliminación de datos:  
  <https://barber-king.onrender.com/public/eliminar-datos.html>
- El enlace de la política aparece dentro de la app en el login, el registro y
  Mi perfil.

---

## Requisitos

- Node.js 20 o superior.
- Flutter 3.44 o superior (Dart 3.12+).
- Proyecto de Supabase con la base de datos creada.
- Opcional: claves de Groq, SMTP y Google OAuth para IA, correo e inicio de sesión social.

---

## Base de datos

Ejecuta los scripts de `database/` en el editor SQL de Supabase, en orden:

| Archivo | Contenido |
| --- | --- |
| `01_roles.sql` | Tabla de roles y datos iniciales |
| `02_usuarios.sql` | Usuarios del sistema |
| `03_barberos.sql` | Perfil profesional de barberos |
| `04_servicios.sql` | Catálogo de servicios |
| `05_horarios.sql` | Horarios semanales por barbero |
| `06_citas.sql` | Citas |
| `07_resenas.sql` | Reseñas y calificaciones |
| `08_mensajes_chat.sql` | Chat directo e historial de IA |
| `09_datos_prueba.sql` | Datos de ejemplo (opcional) |

El script de datos de prueba requiere que existan usuarios con id `2` (barbero) y `3` (cliente). Revisa [database/README.md](database/README.md) para más detalle.

---

## Backend

1. Entra a la carpeta e instala dependencias:

   ```bash
   cd backend
   npm install
   ```

2. Crea el archivo de entorno:

   ```bash
   cp .env.example .env
   ```

3. Completa las variables en `.env` (ver tabla siguiente).

4. Inicia el servidor en desarrollo:

   ```bash
   npm run dev
   ```

   La API queda disponible en `http://localhost:3000` y el estado del servicio en `GET /health`.

### Variables de entorno

| Variable | Obligatoria | Descripción |
| --- | --- | --- |
| `PORT` | No | Puerto del servidor (por defecto `3000`) |
| `NODE_ENV` | No | `development` o `production` |
| `APP_NAME` | No | Nombre usado en correos |
| `FRONTEND_URL` | Sí | URL del cliente para enlaces de recuperación |
| `SUPABASE_URL` | Sí | URL del proyecto Supabase |
| `SUPABASE_KEY` | Sí | Service role key de Supabase |
| `JWT_SECRET` | Sí | Secreto para firmar tokens |
| `SMTP_HOST`, `SMTP_PORT`, `SMTP_SECURE` | No | Servidor de correo saliente |
| `EMAIL_USER`, `EMAIL_PASS` | No | Credenciales de correo |
| `EMAIL_FROM` | No | Remitente (`Barber King <no-reply@tudominio.com>`) |
| `EMAIL_LOGO_URL` | No | Logo de los correos; por defecto `https://barber-king.onrender.com/public/logo-blanco.png` |
| `RESEND_API_KEY` o `BREVO_API_KEY` | No | API de correo; necesaria en Render, que bloquea SMTP |
| `GROQ_API_KEY` | No | Habilita el chat IA y la recomendación de cortes |
| `GROQ_MODELO_TEXTO` | No | Modelo del chat de texto; por defecto `openai/gpt-oss-20b` |
| `BARBERIA_ZONA_HORARIA` | No | Zona horaria de la barbería para validar reservas; por defecto `America/Bogota` |
| `GOOGLE_CLIENT_ID` | No | Habilita el inicio de sesión con Google |
| `CLOUDINARY_*` | No | Configuración opcional de Cloudinary |

> `backend/.env` está excluido de Git. Nunca subas credenciales reales al repositorio.

### La agenda se mide en la hora de la barbería

Los horarios de los barberos son horas de pared (`08:00`–`18:00`), así que para
saber si una hora ya pasó hay que comparar contra la hora **local de la
barbería**, nunca contra la del servidor. Render corre en UTC, cinco horas por
delante de Colombia, y con la hora del servidor se aceptaban reservas de horas
que ya habían pasado.

- Backend: `backend/utils/horaBarberia.js` expone `instanteLocal()`,
  `hoyEnBarberia()` y `yaPasó(fecha, hora)`. `registrarCita` rechaza cualquier
  cita cuya hora ya corra, con `BARBERIA_ZONA_HORARIA` como zona configurable.
- App: `lib/core/hora_local.dart` pinta de gris y desactiva las horas que ya
  pasaron según el reloj del teléfono, y vuelve a comprobar antes de enviar.
- La API de disponibilidad **sí** devuelve las horas pasadas: la app las
  necesita para mostrarlas en gris en lugar de esconderlas.

---

## Frontend

1. Instala dependencias:

   ```bash
   cd frontend/barber_king_app
   flutter pub get
   ```

2. Ejecuta la aplicación:

   ```bash
   flutter run
   ```

La URL de la API se selecciona automáticamente:

- Web: `http://localhost:3000`
- Emulador Android: `http://10.0.2.2:3000`
- Dispositivo físico: valor por defecto en `lib/core/config/api_config.dart`

Para usar una IP distinta sin tocar el código:

```bash
flutter run --dart-define=API_URL=http://192.168.1.50:3000
```

Android solo acepta HTTP en `localhost`, `127.0.0.1` y `10.0.2.2` (ver
`android/app/src/main/res/xml/network_security_config.xml`). Si pruebas contra la
IP de tu PC, agrega esa IP exacta a ese archivo o usa HTTPS; si no, las peticiones
fallan con `CLEARTEXT communication to ... not permitted`.

### Identificador de la app

El paquete es `com.barberking.app` en Android (`applicationId` y `namespace`) y en
iOS (`PRODUCT_BUNDLE_IDENTIFIER`). Es el nombre que ve Google Cloud, la Play
Store y el propio teléfono, así que ya no se puede cambiar sin consecuencias: una
app con otro `applicationId` se instala como programa distinto y no actualiza la
anterior. Si venías usando el viejo `com.example.barber_king_app`, desinstálalo
antes de instalar este APK.

### Permisos de cámara y galería

Ya están declarados en:

- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

En iOS, si cambias los textos de los permisos, vuelve a compilar la app.

### Marca e iconos

El logo real está en `design/logo/original.png`. De él se generan los iconos de
Android (clásico, adaptativo y monocromo), los de iOS y web, las marcas de
`assets/logo/`, los PNG que sirven los correos y las marcas del paquete de Figma:

```bash
python tools/generar_logo.py                  # regenera desde design/logo/original.png
python tools/generar_logo.py ruta-del-logo.png  # sustituye el original y regenera
```

El icono nuevo no aparece sobre un APK ya instalado hasta que lo reinstales.

### Inicio de sesión con Google

La app no usa `google-services.json`: lee el `GOOGLE_CLIENT_ID` en tiempo real
de `GET /api/auth/google/config` y lo pasa como `serverClientId`. Para que
Google muestre el selector de cuentas y entregue un `idToken` hay que registrar
la app en Google Cloud Console (una sola vez, con tu cuenta):

Todo vive en el proyecto **`micro-handler-415020`** (número `607283190256`), que
es al que esta cuenta tiene acceso. `GOOGLE_CLIENT_ID` es el cliente Web
llamado **backend** y el cliente **Barber King Android** es el que autoriza el
APK; ambos deben quedar en el mismo proyecto. Antes se usaba el proyecto
`271099574115`, al que ya no hay acceso: si ves ese prefijo en alguna variable,
está vieja.

1. **Google Auth Platform → Público → Usuarios de prueba**: agrega el Gmail que
   vas a usar (o publica la app en modo *En producción*). Con el estado en
   *Prueba* y la lista vacía, Google rechaza el acceso.
2. **Credenciales → Crear credenciales → ID de cliente OAuth → tipo Android** con:
   - Nombre del paquete: `com.barberking.app`
   - Huella SHA-1 **del keystore que firma el APK instalado**. Léela siempre del
     APK real, porque el `debug.keystore` se regenera si borras
     `%USERPROFILE%\.android` y la huella cambia:
     ```bash
     # la huella del APK que tienes instalado (la que Google exige registrar)
     ~/AppData/Local/Android/Sdk/build-tools/37.0.0/apksigner.bat \
       verify --print-certs build/app/outputs/flutter-apk/app-release.apk

     # la huella del keystore de depuración de esta máquina
     keytool -list -v -keystore "$USERPROFILE/.android/debug.keystore" \
       -storepass android -alias androiddebugkey
     ```
     En PowerShell la ruta se escribe `%USERPROFILE%\.android\debug.keystore`.
     Huellas verificadas en este equipo (nov-2026):
     - `debug.keystore` de este PC:
       `7C:8D:9A:B0:71:55:48:E3:4F:19:16:E4:92:EC:DB:3E:5F:33:B1:E5`
     - En este PC ya existe `android/key.properties` apuntando a la llave de
       subida, así que **el AAB de release se firma con esa llave y no con la de
       depuración**. Compruébalo siempre en el archivo real antes de registrarla.

     Si compilas en depuración y en release, registra las dos huellas. Cada
     cliente de Android de la consola nueva admite una sola, así que van en
     clientes separados con el mismo paquete. Si regeneras el `debug.keystore`,
     su huella cambia y hay que registrar la nueva.

     En la consola nueva cada cliente de Android admite **una sola huella**, así
     que si la app se firma con más de una clave hace falta un cliente por
     huella (mismo paquete `com.barberking.app`, distinta huella). Clientes
     registrados (nov-2026):
     - `Barber King Android`: release de otra máquina,
       `5A:A0:1F:64:E1:21:44:AC:44:0E:80:99:C6:30:17:49:45:26:7B:B8`.
     - `Barber King Android (depuracion)`: depuración de otra máquina,
       `F0:06:96:71:69:5A:DA:9A:08:EF:A1:2F:08:06:1B:12:E5:82:C4:B2`.
     - `Barber King Android (depuracion SISTEMAS)`: este PC,
       `7C:8D:9A:B0:71:55:48:E3:4F:19:16:E4:92:EC:DB:3E:5F:33:B1:E5`.
     - `Barber King Android (upload key)`: llave de subida de este PC,
       `9A:6C:C5:89:DE:75:35:19:5F:C9:1C:51:BE:43:36:3E:DA:58:F3:82`.
3. Deja en Render la variable `GOOGLE_CLIENT_ID` con el cliente de tipo **Web**
   llamado **backend**: `607283190256-1ilbmorioqnhv2f6fgjpsc23mf2h8if0.apps.googleusercontent.com`.
   El cliente de tipo Android no se pone en la app ni en el backend.
4. Reinstala el APK. Si cambias de keystore, registra la nueva huella SHA-1.
   Cambiar `GOOGLE_CLIENT_ID` no exige recompilar: la app lo vuelve a leer.

Para la versión de Play Store hay que registrar **dos** huellas más en ese mismo
cliente Android: la del keystore de release y la de **Play App Signing**. Google
firma los APK descargados desde Play con su propia clave, así que sin esa huella
el login con Google falla solo en las instalaciones de la tienda. Los comandos
para leerlas están en
[`documentacion/play-store/guia-publicacion.md`](documentacion/play-store/guia-publicacion.md#3-huellas-sha-1).

Síntoma típico de faltar el paso 1 o 2: se abre el selector, eliges la cuenta y
la app vuelve sin sesión; Google lo reporta como *cancelado* y la app muestra
"Google no completó el acceso". El plugin `google_sign_in` 7.x no distingue el
motivo en Android, así que un SHA-1 viejo, un paquete mal escrito o un correo que
no está en *Usuarios de prueba* producen el mismo resultado. Comprueba la huella
del APK instalado con el comando de arriba y regístrala en el cliente Android;
`GET /api/auth/google/config` confirma el paso 3: si devuelve un `clientId`,
Render sí lo tiene.

Si en cambio la app muestra "El token de Google expiró" o "El token de Google
pertenece a otra aplicación", el `idToken` sí llegó al backend y el problema está
en la fecha del teléfono o en el `GOOGLE_CLIENT_ID`. Cuando el fallo es del
servidor (base de datos, por ejemplo) la app muestra "No fue posible completar el
inicio de sesión con Google"; en ese caso revisa los logs de Render.

### Firmar el release con tu propia llave de subida

La llave de subida de este proyecto ya está creada (nov-2026). Vive **fuera** del
repositorio, en `%USERPROFILE%\upload-keystore.jks`, con alias `upload` y formato
JKS. `android/key.properties` ya existe en este PC y está ignorado por Git, así
que `flutter build appbundle --release` firma con esa llave sin tocar nada más.
Las contraseñas están en `%USERPROFILE%\upload-keystore-credenciales.txt`. Haz
copia del `.jks` y de ese archivo en dos lugares seguros: sin ellos no se pueden
publicar actualizaciones.

Si necesitas recrear la llave en otro equipo, usa los mismos datos:

```bash
keytool -genkeypair -v -storetype JKS -alias upload \
  -keystore "$USERPROFILE/upload-keystore.jks" \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Hernando Botello Vargas, OU=Barber King, O=Barber King, L=Garzon, ST=Huila, C=CO"
```

El formato JKS es el que pide la guía del SENA. `keytool` recomienda PKCS12, pero
cambiar de formato cambia el archivo, no la llave, y aquí no hace falta.

Luego crea `android/key.properties` (tampoco se sube, ya está en `.gitignore`):

```properties
storePassword=LA_CONTRASEÑA
keyPassword=LA_CONTRASEÑA
keyAlias=upload
storeFile=C:/Users/TU_USUARIO/upload-keystore.jks
```

Huellas de esta llave de subida:

```text
SHA-1:   9A:6C:C5:89:DE:75:35:19:5F:C9:1C:51:BE:43:36:3E:DA:58:F3:82
SHA-256: CE:23:3A:90:42:8C:C2:53:CD:AE:69:84:27:CB:47:B1:83:F7:13:32:15:A5:C2:AB:15:6E:80:62:C8:81:18:F8
```

Registra la SHA-1 en el cliente OAuth de Android. Un APK firmado con otra clave no
actualiza al anterior: hay que desinstalar primero. Eso no aplica a Google Play,
donde la actualización la firma Play App Signing.

Para Play Store compila un **AAB**, no un APK:

```bash
flutter build appbundle --release
```

El resultado queda en `build/app/outputs/bundle/release/app-release.aab`.
Verifícalo con `jarsigner -verify -verbose -certs <aab>`: debe decir `jar
verified` y mostrar el alias `upload`, nunca `androiddebugkey`. Si además quieres
símbolos para leer reportes de fallos, agrega
`--obfuscate --split-debug-info=build/symbols` y guarda esa carpeta junto al AAB.

Con Play App Signing hay **dos** huellas SHA-1: la de tu upload key, que ya
tienes, y la que genera Google, que solo aparece después de subir el primer AAB a
Play Console, en **Integridad de la app → Firma de la app**. Registra también esa
segunda huella en Google Cloud, o el login con Google fallará en las
instalaciones descargadas desde Play (ver
[`documentacion/play-store/guia-publicacion.md`](documentacion/play-store/guia-publicacion.md)).

### Notificaciones con la app cerrada

Al iniciar sesión, la app programa una tarea en **WorkManager** (no requiere
Firebase): revisa el chat unos segundos después de pasar a segundo plano,
repasa cada minuto mientras la cadena siga viva y conserva un respaldo
periódico cada 15 minutos. Los avisos usan el canal `chat_mensajes`.

En esa misma pasada la tarea pide `GET /citas/proximas` y avisa de las citas
pendientes o confirmadas de las próximas 72 horas por el canal
`citas_recordatorios`: una vez dentro de las 24 horas y otra dentro de las 2.
El aviso sale para el cliente ("tu cita mañana a las 14:30 con X") y para el
barbero ("llega un cliente en menos de 2 horas"). Cada pareja cita+ventana se
marca en `SharedPreferences` (`recordatorio_cita_<id>_<24h|2h>`) para no
repetirse, y esas marcas se borran a los 15 días. El administrador no recibe
avisos de citas.

La tarea se crea la primera vez que entras al panel después de iniciar sesión.
El permiso `RECEIVE_BOOT_COMPLETED` es lo que permite que ese respaldo sobreviva
a un reinicio del teléfono; sin él, el trabajo se pierde hasta volver a abrir
la app.

Android puede posponer esas revisiones; si aún así no llegan:

- Permite las notificaciones cuando la app lo pida (Android 13+).
- Ajustes → Aplicaciones → Barber King → Batería: **Sin restricciones**
  (Samsung, Xiaomi, Huawei y OPPO cierran el segundo plano por defecto).

Con el teléfono conectado por USB puedes comprobar que el trabajo está agendado:

```bash
adb shell dumpsys jobscheduler | grep -i barber-king
```

---

## API principal

| Módulo | Endpoints |
| --- | --- |
| Autenticación | `POST /api/auth/registro`, `/login`, `/google`, `/forgot-password`, `/reset-password` |
| Usuarios | `GET/PUT/DELETE /api/usuarios/me` (el `DELETE` elimina la propia cuenta), `PUT /me/foto`, `PUT /me/diploma`, CRUD administrativo en `/api/usuarios` |
| Servicios | `GET /api/servicios/obtener`, CRUD en `/api/servicios` |
| Barberos | `GET /api/barberos/obtener`, detalle y gestión en `/api/barberos` |
| Citas | `POST /api/citas/crear`, consulta y actualización en `/api/citas` |
| Horarios | CRUD en `/api/horarios` |
| Disponibilidad | `GET /api/disponibilidad/consultarDisponibilidad` |
| Reseñas | CRUD en `/api/resenas` |
| Chat | `GET /api/chat/directo/contactos`, `GET/POST /api/chat/directo/mensajes`, `POST /api/chat/chatear`, `POST /api/chat/recomendar-corte` |
| Dashboard | `GET /api/dashboard`, `GET /api/dashboard/barbero` |
| Uploads | `POST /api/uploads` |
| Salud | `GET /health` |

Los endpoints protegidos requieren el encabezado `Authorization: Bearer <token>`.

---

## Seguridad

- Contraseñas cifradas con bcrypt.
- Autenticación mediante JWT y verificación de roles.
- Helmet, CORS configurado y límite de peticiones.
- Validación de tipo y tamaño en las cargas de archivos.
- Variables sensibles fuera del repositorio.
- Eliminaciones masivas solo para administradores y con confirmación explícita.
- Row Level Security (RLS) activada en todas las tablas de Supabase
  (`database/21_rls.sql`): sin políticas, se deniega por defecto y solo la
  clave **secreta** (`service_role`) tiene acceso.

  **Orden obligatorio:** el backend debe usar la clave secreta de Supabase
  (Project Settings → API keys → *Secret key*) como `SUPABASE_KEY` en
  `backend/.env` y en Render **antes** de ejecutar `21_rls.sql`. Si se corre
  primero, la clave publicable actual queda sin permisos y la app deja de
  responder. Comprueba `/health` y el inicio de sesión y solo entonces aplica
  el script. Detalles en `database/README.md`.

---

## Tests y CI

Los tests usan las herramientas que ya vienen, sin dependencias nuevas:

```bash
# Backend (runner nativo de Node 20+)
cd backend
npm test

# App Flutter
cd frontend/barber_king_app
flutter test
dart analyze lib test
```

En cada push y en cada pull request, GitHub Actions
(`.github/workflows/ci.yml`) revisa la sintaxis de todos los archivos del
backend, corre sus tests y en la app ejecuta `dart analyze` y `flutter test`
con la misma versión de Flutter que se usa en desarrollo (3.47.1).

---

## Monitoreo de errores (Sentry)

El proyecto está cableado a [Sentry](https://sentry.io) para ver los errores
de producción que hoy solo aparecen en los logs de Render o en el dispositivo.
Está **apagado por defecto**: si una variable queda vacía, esa parte se
comporta igual que antes, sin llamadas de red ni servicios externos.

| Parte | Dónde se configura | Qué reporta |
| --- | --- | --- |
| Backend | `SENTRY_DSN` en `backend/.env` y en Render | Excepciones no controladas, promesas rechazadas y cualquier error que se responda como 500. Los 4xx no se envían: son respuestas deliberadas a datos del cliente. |
| App Android | `dsn` en `frontend/barber_king_app/lib/core/sentry_config.dart` | Excepciones no capturadas (widgets, plataforma y zonas), más las capturas manuales de errores ya manejados. |

Los proyectos en sentry.io ya están creados en la organización del equipo:

| Proyecto | Plataforma | DSN configurado en |
| --- | --- | --- |
| `node` (backend) | Node.js | `SENTRY_DSN` en `backend/.env` |
| `flutter` (app) | Flutter | `dsn` en `frontend/barber_king_app/lib/core/sentry_config.dart` |

Para mover cualquiera de los dos a otro proyecto: crearlo en sentry.io y
reemplazar el DSN correspondiente. Para apagarlo, basta con dejar la variable
vacía. En **Render** hace falta agregar `SENTRY_DSN` a mano en
Environment → Variables (el valor es el mismo de `backend/.env`).

La app solo empieza a enviar errores cuando se vuelve a compilar
(`flutter build apk`), porque el DSN se fija en tiempo de compilación.

El DSN no es un secreto: es un dato público que va embebido en el cliente y
solo sirve para enviar eventos. Lo que sí se mantiene fuera del repositorio es
el Auth Token de Sentry, que solo se usa para administrar el proyecto.

---

## Autores

- Hernando Botello Vargas
- Yonanderson Marroquin
