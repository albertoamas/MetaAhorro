plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Plugin para Firebase
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.metaahorro"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true // Habilitar desugarización
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.metaahorro"
        minSdk = 23 // Cambiado de 21 a 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // Actualizar a 2.1.4
    implementation(platform("com.google.firebase:firebase-bom:32.2.0")) // Firebase BOM
    implementation("com.google.firebase:firebase-auth-ktx") // Firebase Auth
    implementation("com.google.firebase:firebase-firestore-ktx") // Firebase Firestore
}

flutter {
    source = "../.."
}