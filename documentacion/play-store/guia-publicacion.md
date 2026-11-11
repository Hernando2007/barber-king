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

```powershell
keytool -genkeypair -v -storetype PKCS12 -alias barber-king `
  -keystore "$USERPROFILE\keystores\barber-king-release.keystore" `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -dname "CN=Barber King, OU=Desarrollo, O=Barber King, L=Bogota, ST=Cundinamarca, C=CO"
```

`keytool` pide la contraseña del almacén y la de la clave (pueden ser la misma).

> **Nunca** subas el `.keystore` ni `key.properties` al repositorio. Ambos ya
> están cubiertos por `frontend/barber_king_app/android/.gitignore`.

### Crear `android/key.properties`

```properties
storePassword=TU_CONTRASEÑA
keyPassword=TU_CONTRASEÑA
keyAlias=barber-king
storeFile=C:/Users/TU_USUARIO/keystores/barber-king-release.keystore
```

`build.gradle.kts` lee ese archivo automáticamente y firma el release con él.
Sin el archivo, el build usa la clave de depuración (válido para probar, **no**
para Play).

---

## 3. Huellas SHA-1

Con **Play App Signing** hay dos claves distintas:

| Clave | Para qué sirve | Dónde se obtiene |
| --- | --- | --- |
| Upload key (tu keystore) | Firmar el AAB que subes | `keytool` local |
| App signing key (Google) | Firmar los APK que descargan los usuarios | Play Console → Integridad de la app |

### Huella de tu upload key

```powershell
keytool -list -v -keystore "$USERPROFILE\keystores\barber-king-release.keystore" -alias barber-king
```

Copia la línea `SHA1:`.

Huella del keystore creado para este proyecto (nov-2026):

```text
5A:A0:1F:64:E1:21:44:AC:44:0E:80:99:C6:30:17:49:45:26:7B:B8
```

Las contraseñas del keystore están en
`%USERPROFILE%\keystores\barber-king-credentials.txt`, fuera del repositorio.
Haz una copia de seguridad de ese archivo y del `.keystore`: sin ellos no se
pueden publicar actualizaciones.

### Huella de Play App Signing

1. Sube el primer AAB a Play Console.
2. Ve a **Integridad de la app → Firma de la app**.
3. Copia el **SHA-1 del certificado de firma de la app**.

### Registrar ambas en Google Cloud

En **Google Cloud Console → Google Auth Platform → Credenciales**, edita el
cliente OAuth de tipo **Android** (`com.barberking.app`) y agrega las dos huellas
SHA-1. Sin la huella de Play App Signing, el inicio de sesión con Google falla en
las instalaciones descargadas desde Play.

---

## 4. Compilar el AAB de release

```powershell
cd frontend/barber_king_app
flutter clean
flutter pub get
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

El archivo queda en:

```text
frontend/barber_king_app/build/app/outputs/bundle/release/app-release.aab
```

### Verificar la firma

```powershell
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

Debe decir `jar verified` y mostrar el alias `barber-king`, no
`androiddebugkey`.

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
  actividad en la app.
- Datos compartidos con terceros: **sí** (Supabase, Render, Cloudinary, Groq,
  Google).
- Cifrado en tránsito: **sí**.
- Eliminación de datos: **sí**, desde la app y por solicitud web.
- No se venden datos ni se usan para publicidad.

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
- [ ] AAB firmado con el alias `barber-king` y verificado con `jarsigner`.
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
