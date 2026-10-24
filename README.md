# Barber King

Aplicación de gestión para barbería con API REST en **Node.js + Express**, base de datos **PostgreSQL (Supabase)** y cliente **Flutter** para Android, iOS y web.

El sistema cubre el flujo completo: registro e inicio de sesión, reserva de citas, agenda del barbero, horarios de atención, servicios, reseñas, chat directo cliente-barbero, asistente con IA y panel administrativo.

---

## Funcionalidades

### Cliente

- Registro e inicio de sesión con correo o Google.
- Recuperación y cambio de contraseña.
- Catálogo de servicios y barberos.
- Reserva de citas según disponibilidad y horarios.
- Historial y estado de sus citas.
- Calificación de barberos.
- Chat directo con barberos, con envío de imágenes.
- Chat con IA y recomendación de cortes a partir de una foto.
- Edición de perfil y foto.

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
- Asistente virtual para consultas sobre servicios, precios y reservas.
- Recomendación de cortes con visión artificial a partir de la cámara o galería.

---

## Tecnologías

| Capa | Tecnologías |
| --- | --- |
| Backend | Node.js 20+, Express 5, Supabase JS, JWT, bcrypt, multer, nodemailer, Groq SDK, Helmet, Morgan, rate limiting |
| Frontend | Flutter 3.44+, Dart 3.12+, Material 3, Dio, flutter_secure_storage, image_picker, cached_network_image, Google Fonts |
| Base de datos | PostgreSQL en Supabase |
| IA | Groq (texto y visión) |
| Almacenamiento | Disco local (`backend/uploads`) |

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
| `GROQ_API_KEY` | No | Habilita el chat IA y la recomendación de cortes |
| `GOOGLE_CLIENT_ID` | No | Habilita el inicio de sesión con Google |
| `CLOUDINARY_*` | No | Configuración opcional de Cloudinary |

> `backend/.env` está excluido de Git. Nunca subas credenciales reales al repositorio.

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

### Permisos de cámara y galería

Ya están declarados en:

- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

En iOS, si cambias los textos de los permisos, vuelve a compilar la app.

---

## API principal

| Módulo | Endpoints |
| --- | --- |
| Autenticación | `POST /api/auth/registro`, `/login`, `/google`, `/forgot-password`, `/reset-password` |
| Usuarios | `GET/PUT /api/usuarios/me`, `PUT /me/foto`, `PUT /me/diploma`, CRUD administrativo en `/api/usuarios` |
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

---

## Autores

- Hernando Botello Vargas
- Yonanderson Marroquin
