import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// La firma de release usa android/key.properties, que no se versiona.
// Si el archivo falta o está incompleto, el build de release se detiene.
val archivoClave = rootProject.file("key.properties")
val clavePropiedades = Properties()
val tieneKeystore = archivoClave.exists()

if (tieneKeystore) {
    FileInputStream(archivoClave).use { flujo -> clavePropiedades.load(flujo) }

    val requeridas = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
    val faltantes = requeridas.filter { clavePropiedades.getProperty(it).isNullOrBlank() }
    if (faltantes.isNotEmpty()) {
        throw GradleException(
            "Faltan datos en android/key.properties: ${faltantes.joinToString(", ")}"
        )
    }
}

val archivoAlmacen = if (tieneKeystore) {
    rootProject.file(requireNotNull(clavePropiedades.getProperty("storeFile")))
} else {
    null
}

if (archivoAlmacen != null && !archivoAlmacen.exists()) {
    throw GradleException(
        "No existe el keystore indicado en android/key.properties: ${archivoAlmacen.absolutePath}"
    )
}

// Un release firmado con la clave de depuración lo rechaza Play.
// El aviso solo aparece cuando se pide compilar el release, no en debug.
gradle.taskGraph.whenReady {
    val pideRelease = allTasks.any { it.name == "bundleRelease" || it.name == "assembleRelease" }
    if (pideRelease && !tieneKeystore) {
        throw GradleException(
            "Falta android/key.properties. Sin la llave de subida no se puede firmar el release."
        )
    }
}

android {
    namespace = "com.barberking.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.barberking.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (tieneKeystore) {
            create("release") {
                storeFile = archivoAlmacen
                storePassword = clavePropiedades.getProperty("storePassword")
                keyAlias = clavePropiedades.getProperty("keyAlias")
                keyPassword = clavePropiedades.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (tieneKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
