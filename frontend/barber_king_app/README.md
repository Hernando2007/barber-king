# Barber King - Aplicación Flutter

Cliente móvil y web del sistema de gestión de barbería Barber King.

## Requisitos

- Flutter 3.44 o superior.
- Dart 3.12 o superior.
- Backend de Barber King en ejecución.

## Ejecutar

```bash
flutter pub get
flutter run
```

## URL del backend

La aplicación elige la URL según la plataforma:

- Web: `http://localhost:3000`
- Emulador Android: `http://10.0.2.2:3000`
- Dispositivo físico: edita el valor por defecto en `lib/core/config/api_config.dart`

También puedes sobrescribirla sin modificar el código:

```bash
flutter run --dart-define=API_URL=http://192.168.1.50:3000
```

## Estructura

```text
lib/
├── core/      Tema, colores, formateadores y configuración de la API
├── models/    Modelos del cliente
├── routes/    Rutas de navegación
├── screens/   Pantallas por módulo
├── services/  Consumo de la API
└── widgets/   Componentes reutilizables
```

## Permisos

La cámara y la galería están configuradas en `android/app/src/main/AndroidManifest.xml` e `ios/Runner/Info.plist`.

## Verificación

```bash
flutter analyze
flutter test
```
