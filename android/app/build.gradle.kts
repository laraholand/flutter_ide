<<<<<<< HEAD
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.ide"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
=======
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.vault.fide"
    compileSdk = 36
    ndkVersion = "27.1.12297006"
    buildToolsVersion = "35.0.0"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
>>>>>>> 777f43b (Auto commit from automation tool)
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
<<<<<<< HEAD
        applicationId = "com.example.ide"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
=======
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.vault.fide"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = 28
>>>>>>> 777f43b (Auto commit from automation tool)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

<<<<<<< HEAD
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }

        //create("debug") {
     //       keyAlias = keystoreProperties["keyAlias"] as String?
       //     keyPassword = keystoreProperties["keyPassword"] as String?
       //     storeFile = keystoreProperties["storeFile"]?.let { file(it) }
     //       storePassword = keystoreProperties["storePassword"] as String?
    //    }
    }

    buildTypes {
   //     getByName("debug") {
     //       signingConfig = signingConfigs.getByName("debug")
   //     }
        getByName("release") {
           // isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
=======
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}
dependencies {
    implementation(libs.androidx.core)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.constraintlayout)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.1.5")
    implementation(libs.androidx.preference)
    implementation(project(":termux:app"))
    implementation ("com.google.guava:listenablefuture:9999.0-empty-to-avoid-conflict-with-guava")

}

>>>>>>> 777f43b (Auto commit from automation tool)

flutter {
    source = "../.."
}
