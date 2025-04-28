plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    compileSdkVersion(35)
    ndkVersion = "27.0.12077973"  // Ensure the correct NDK version is used

    defaultConfig {
        minSdkVersion(23)
        targetSdkVersion(35)
        namespace = "com.example.hercycleplus"
        // Define versionCode and versionName here
        versionCode = 1  // Set your version code here
        versionName = "1.0.0"  // Set your version name here
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    buildFeatures {
        viewBinding = true
    }

    dependencies {
        // Add this line to enable core library desugaring
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.1.5")
    }

    buildTypes {
        getByName("release") {
            // Add your signing configuration here (if needed)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15") // Correct classpath syntax in Kotlin DSL
        classpath("com.android.tools.build:gradle:7.0.4") // Ensure correct Gradle plugin version
    }
}

flutter {
    source = "../.."
}

apply(plugin = "com.google.gms.google-services") // Correct apply syntax in Kotlin DSL
