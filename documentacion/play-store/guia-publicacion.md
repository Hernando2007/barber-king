# Guía de publicación en Google Play

Checklist completo para publicar **Barber King** (`com.barberking.app`) en Google
Play. Está pensada para ejecutarse en orden, de la firma del AAB hasta el
lanzamiento en producción.

---

## 1. Requisitos previos

| Requisito | Estado |
| --- | --- |
| Cuenta de Google Play Developer (25 USD, pago único) | Pendiente |
| Verificación de identidad del desarrollador | Pendiente |
| `applicationId` definitivo `com.barberking.app` | ✅ |
| `targetSdk` 36 (Play exige 35+) | ✅ Flutter 3.47.1 |
| Backend en producción con HTTPS | ✅ `https://barber-king.onrender.com` |
| Política de privacidad pública | ✅ `https://barber-king.onrender.com/public/politica-privacidad.html` |
| Página de eliminación de cuenta | ✅ `https://barber-king.onrender.com/public/eliminar-cuenta.html` |
| Borrado de cuenta dentro de la app | ✅ Mi perfil → Eliminar cuenta |
| Icono 512×512 y gráfico destacado 1024×500 | ✅ `documentacion/play-store/` |

> Si la cuenta de desarrollador es **personal y nueva**, Play exige una prueba
> cerrada con **12 testers durante 14 días** antes de habilitar producción. Una
> cuenta de organización no tiene ese requisito.

---

## 2. Generar el keystore de release

El keystore es la identidad criptográfica de la app: si se pierde, no se pueden
publicar actualizaciones. Guárdalo fuera del repositorio y con copia de
seguridad.

Este proyecto ya tiene su llave de subida (nov-2026):

- Archivo: `%USERPROFILE%\upload-keystore.jks` (fuera del repositorio)
- Alias: `upload`
- Formato: JKS
- Credenciales: `%USERPROFILE%\upload-keystore-credenciales.txt`

Si hay que recrearla en otro equipo, este es el comando:

```powershell
keytool -genkeypair -v -storetype JKS -alias upload `
  -keystore "$USERPROFILE\upload-keystore.jks" `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -dname "CN=Hernando Botello Vargas, OU=Barber King, O=Barber King, L=Garzon, ST=Huila, C=CO"
```

`keytool` pide la contraseña del almacén y la de la clave (pueden ser la misma).
Avisa que recomienda PKCS12: ignóralo, la guía pide JKS y cambiar de formato no
cambia la llave.

> **Nunca** subas el `.keystore` ni `key.properties` al repositorio. Ambos ya
> están cubiertos por `frontend/barber_king_app/android/.gitignore`.

### Crear `android/key.properties`

```properties
storePassword=TU_CONTRASEÑA
keyPassword=TU_CONTRASEÑA
keyAlias=upload
storeFile=C:/Users/TU_USUARIO/upload-keystore.jks
```

`build.gradle.kts` lee ese archivo automáticamente y firma el release con él.
Si el archivo falta o no tiene todos los datos, el build de release se detiene
con un mensaje claro. Tampoco se firma si el keystore indicado no existe. En el
PC de desarrollo ya está creado, así que no hay que repetirlo.

---

## 3. Huellas SHA-1

Con **Play App Signing** hay dos claves distintas:

| Clave | Para qué sirve | Dónde se obtiene |
| --- | --- | --- |
| Upload key (tu keystore) | Firmar el AAB que subes | `keytool` local |
| App signing key (Google) | Firmar los APK que descargan los usuarios | Play Console → Integridad de la app |

### Huella de tu upload key

```powershell
keytool -list -v -keystore "$USERPROFILE\upload-keystore.jks" -alias upload
```

Copia la línea `SHA1:`.

Huella del keystore creado para este proyecto (nov-2026):

```text
9A:6C:C5:89:DE:75:35:19:5F:C9:1C:51:BE:43:36:3E:DA:58:F3:82
```

Su SHA-256 es
`CE:23:3A:90:42:8C:C2:53:CD:AE:69:84:27:CB:47:B1:83:F7:13:32:15:A5:C2:AB:15:6E:80:62:C8:81:18:F8`.

Las contraseñas del keystore están en
`%USERPROFILE%\upload-keystore-credenciales.txt`, fuera del repositorio.
Haz una copia de seguridad de ese archivo y del `.jks`: sin ellos no se
pueden publicar actualizaciones.

### Huella de Play App Signing

1. Sube el primer AAB a Play Console.
2. Ve a **Integridad de la app → Firma de la app**.
3. Copia el **SHA-1 del certificado de firma de la app**.

### Registrar ambas en Google Cloud

En **Google Cloud Console → Google Auth Platform → Credenciales**, edita el
cliente OAuth de tipo **Android** (`com.barberking.app`) y agrega la huella
SHA-1. La consola nueva admite **una sola huella por cliente**, así que cada
huella necesita su propio cliente con el mismo paquete. Registrados para este
proyecto:

| Cliente | Huella | Uso |
| --- | --- | --- |
| `Barber King Android (depuracion SISTEMAS)` | `7C:8D:9A:B0:71:55:48:E3:4F:19:16:E4:92:EC:DB:3E:5F:33:B1:E5` | APK de depuración de este PC |
| `Barber King Android (upload key)` | `9A:6C:C5:89:DE:75:35:19:5F:C9:1C:51:BE:43:36:3E:DA:58:F3:82` | AAB que subes a Play |

Falta el cliente de Play App Signing. Sin esa huella, el inicio de sesión con
Google falla en las instalaciones descargadas desde Play.

---

## 4. Compilar el AAB de release

```powershell
cd frontend/barber_king_app
flutter clean
flutter pub get
flutter build appbundle --release
```

Si quieres símbolos para leer reportes de fallos, agrega
`--obfuscate --split-debug-info=build/symbols`.

El archivo queda en:

```text
frontend/barber_king_app/build/app/outputs/bundle/release/app-release.aab
```

### Verificar la firma

```powershell
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

Debe decir `jar verified` y mostrar el certificado
`CN=Hernando Botello Vargas, OU=Barber King`, con SHA-1
`9A:6C:C5:89:DE:75:35:19:5F:C9:1C:51:BE:43:36:3E:DA:58:F3:82`. Ese es el alias
`upload`, no `androiddebugkey`. También puedes confirmarlo con:

```powershell
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

### Guardar los símbolos de ofuscación

La carpeta `build/symbols` permite leer los stack traces ofuscados. Guárdala
junto al AAB de cada versión; **no** la subas al repositorio.

> Si Gradle falla por memoria en un equipo con poca RAM, sube `-Xmx` en
> `android/gradle.properties` o compila en una máquina con más memoria/CI.

---

## 5. Configurar la ficha en Play Console

### 5.1 Crear la app

- Nombre: **Barber King**
- Idioma predeterminado: **Español (Latinoamérica)**
- Tipo: **Aplicación**
- Gratis
- Declaraciones: cumple las políticas y las leyes de exportación de EE. UU.

### 5.2 Ficha de Play Store

Usa los textos de [`textos-listing.md`](textos-listing.md). Necesitas:

| Elemento | Especificación | Archivo |
| --- | --- | --- |
| Icono | 512×512 PNG, sin transparencia | `icono-play-512.png` |
| Gráfico destacado | 1024×500 PNG/JPG | `grafico-destacado-1024x500.png` |
| Capturas de teléfono | Mínimo 2, máximo 8 (1080×1920 o similar) | `documentacion/_prueba/png/` |
| Descripción corta | Máximo 80 caracteres | `textos-listing.md` |
| Descripción completa | Máximo 4000 caracteres | `textos-listing.md` |
| Correo de contacto | Obligatorio | `hernandobotellovargas2007@gmail.com` |
| Política de privacidad | URL pública | `https://barber-king.onrender.com/public/politica-privacidad.html` |

### 5.3 Seguridad de los datos (Data Safety)

Declara exactamente lo que recoge la app. Tabla lista para copiar en
[`textos-listing.md`](textos-listing.md#seguridad-de-los-datos-data-safety). Puntos clave:

- Datos recogidos: información personal, fotos, ubicación aproximada y precisa,
  actividad en la app y datos técnicos del dispositivo.
- Datos compartidos con terceros: **sí** (Supabase, Render, Cloudinary, Groq,
  Google, Sentry, Resend, Brevo o SMTP y OpenStreetMap).
- Cifrado en tránsito: **sí**.
- Eliminación de datos: **sí**, desde la app y por solicitud web.
- No se venden datos ni se usan para publicidad.

La URL de la política va en la tabla anterior y también debe pegarse en
**Política y programas → Política de privacidad** de Play Console. La app abre
esa misma URL desde el login, el registro y Mi perfil.

### 5.4 Acceso a la app (App access)

La app es 100 % login-gated. Play necesita credenciales de prueba:

```text
Usuario cliente:  cliente.demo@barberking.com  /  Demo1234*
Usuario barbero:  barbero.demo@barberking.com  /  Demo1234*
Usuario admin:    admin.demo@barberking.com    /  Demo1234*
```

> Crea esas cuentas en producción antes de enviar a revisión y verifica que
> puedan iniciar sesión. Si cambias las contraseñas, actualiza esta sección en
> Play Console.

### 5.5 Clasificación de contenido

- Cuestionario IARC: categoría **Estilo de vida**.
- Sin violencia, sin contenido sexual, sin drogas, sin apuestas.
- Interacción entre usuarios (chat): **sí**, con moderación por parte de los
  barberos/administradores.
- Público objetivo: **13+**.
- Sin anuncios.

### 5.6 Anuncios y cumplimiento

- **No contiene anuncios.**
- **No** es una app dirigida a niños.
- Cumple la política de eliminación de cuentas (implementada).

---

## 6. Prueba cerrada (cuentas personales nuevas)

1. Sube el AAB a **Prueba cerrada**.
2. Agrega al menos **12 testers** (correos de Google).
3. Mantén la prueba **14 días consecutivos**.
4. Recoge comentarios y corrige bloqueos.
5. Solicita el acceso a producción desde Play Console.

---

## 7. Publicación en producción

1. Sube el AAB a **Producción**.
2. Revisa el resumen: errores, advertencias y cambios.
3. Envía a revisión. La primera revisión puede tardar de 3 a 7 días.
4. Una vez aprobada, publica el release (o usa publicación gestionada).

### Después de publicar

- Registra la SHA-1 de Play App Signing en Google Cloud (paso 3).
- Verifica el login con Google desde la versión instalada de Play Store.
- Prueba el borrado de cuenta con una cuenta real.
- Monitorea **Android vitals** (crashes y ANR) y las reseñas.

---

## 8. Actualizaciones futuras

1. Sube `versionCode` en `pubspec.yaml` (`1.0.0+1` → `1.0.1+2`).
2. Vuelve a compilar el AAB con el **mismo keystore**.
3. Sube a Play Console y publica.
4. Conserva `build/symbols` de cada versión.

> El `versionCode` debe ser siempre mayor que el anterior. Play rechaza AAB con
> un código repetido o menor.

---

## 9. Checklist final

- [ ] Keystore generado y respaldado fuera del repositorio.
- [ ] `android/key.properties` creado y **no** versionado.
- [ ] AAB firmado con la llave de subida y verificado con `jarsigner`.
- [ ] `build/symbols` guardado.
- [ ] Icono 512×512 y gráfico 1024×500 listos.
- [ ] Al menos 2 capturas de teléfono.
- [ ] Textos de ficha cargados.
- [ ] Política de privacidad y página de eliminación accesibles por HTTPS.
- [ ] Data Safety completo.
- [ ] Credenciales demo de App access verificadas.
- [ ] Clasificación de contenido completada.
- [ ] SHA-1 de upload key y Play App Signing registradas en Google Cloud.
- [ ] Prueba cerrada de 12 testers × 14 días (cuenta personal).
- [ ] AAB enviado a producción y aprobado.
