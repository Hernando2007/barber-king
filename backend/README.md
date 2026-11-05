# Backend - Barber King

API REST del sistema de barbería, construida con Node.js, Express 5 y Supabase.

## Inicio rápido

```bash
npm install
cp .env.example .env
# Completa las credenciales en .env
npm run dev
```

La API queda disponible en `http://localhost:3000` y el estado del servicio en `GET /health`.

## Scripts

| Comando | Descripción |
| --- | --- |
| `npm start` | Ejecuta el servidor con Node.js |
| `npm run dev` | Ejecuta el servidor con recarga automática (nodemon) |
| `npm run prod` | Ejecuta el servidor en modo producción |

## Estructura

```text
backend/
├── config/       Supabase, multer y servicios externos
├── controllers/  Controladores HTTP
├── middlewares/  Autenticación, roles, uploads y errores
├── models/       Consultas a Supabase
├── routes/       Endpoints por módulo
├── services/     Lógica de negocio
├── uploads/      Archivos cargados en tiempo de ejecución
├── utils/        Utilidades compartidas
├── validators/   Validaciones
├── app.js        Configuración de Express
└── index.js      Arranque del servidor
```

## Variables de entorno

El detalle de cada variable está en [`.env.example`](.env.example) y en el [README principal](../README.md). El archivo `.env` nunca debe subirse al repositorio.

## Almacenamiento de archivos

Las fotos de perfil, el portafolio del barbero, los diplomas y las imágenes del chat se suben a Cloudinary con las credenciales `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY` y `CLOUDINARY_API_SECRET`. multer solo trabaja en memoria: en Render el disco es efímero, así que cualquier archivo guardado localmente deja de existir al volver a desplegar.
