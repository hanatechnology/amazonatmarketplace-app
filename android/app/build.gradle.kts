import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

// local.properties is git-ignored; it is where a developer keeps their own
// Maps key without it reaching the repository.
val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

// key.properties is git-ignored too, and holds the upload keystore for a
// Play Store build. Absent locally, so debug signing stays the fallback.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile") != null

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Must come after the Android plugin; generates Firebase config resources.
    id("com.google.gms.google-services")
}

android {
    namespace = "com.hanatech.marketplace"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.hanatech.marketplace"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Google Maps SDK key for the address location picker. Read from
        // android/local.properties (git-ignored) or the MAPS_API_KEY env var,
        // so no key is ever committed. An empty key renders a grey tile grid
        // rather than crashing, which keeps debug builds runnable without one.
        val mapsApiKey: String = localProperties.getProperty("MAPS_API_KEY")
            ?: System.getenv("MAPS_API_KEY")
            ?: ""
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    signingConfigs {
        // Only declared when android/key.properties exists — referencing a
        // missing keystore file would fail configuration for everyone else.
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Falls back to the debug keys so `flutter run --release` and a
            // local smoke-test APK still work without the upload keystore.
            // A Play Store artifact needs android/key.properties present.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

// Kotlin 2.3 removed the string-valued `kotlinOptions.jvmTarget`; the compiler
// options DSL is the replacement. Kept at 11 to match compileOptions above.
kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_11
    }
}
