import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Si existe android/key.properties, el release se firma con tu propio keystore.
// Sin ese archivo se usa la clave de depuración, como hasta ahora.
val clavePropiedades = Properties()
val archivoClave = rootProject.file("key.properties")
val tieneKeystore = archivoClave.exists()
if (tieneKeystore) {
    FileInputStream(archivoClave).use { flujo -> clavePropiedades.load(flujo) }
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
        create("release") {
            if (tieneKeystore) {
                keyAlias = clavePropiedades["keyAlias"] as String
                keyPassword = clavePropiedades["keyPassword"] as String
                storeFile = file(clavePropiedades["storeFile"] as String)
                storePassword = clavePropiedades["storePassword"] as String
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
