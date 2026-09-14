pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // 8.9.1+ is required by the AndroidX versions Firebase pulls in
    // (androidx.core 1.17, androidx.browser 1.9).
    id("com.android.application") version "8.9.1" apply false
    // 2.3.x is forced by the plugins: google_maps_flutter_android and
    // android-maps-utils 4.1.0 ship metadata at binary version 2.3.0, which a
    // 2.1.0 compiler refuses to read ("Module was compiled with an
    // incompatible version of Kotlin").
    id("org.jetbrains.kotlin.android") version "2.3.10" apply false
    // Reads android/app/google-services.json so Firebase can resolve this app.
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
