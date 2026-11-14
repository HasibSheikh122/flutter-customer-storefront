import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val dartDefines = mutableMapOf<String, String>()
if (project.hasProperty("dart-defines")) {
    val rawDefines = project.property("dart-defines") as String
    rawDefines.split(",").forEach { entry ->
        try {
            val decoded = String(Base64.getDecoder().decode(entry), Charsets.UTF_8)
            val parts = decoded.split("=", limit = 2)
            if (parts.size == 2) {
                dartDefines[parts[0]] = parts[1]
            }
        } catch (_: Exception) {}
    }
}

val resolvedBundleId = dartDefines["BUNDLE_ID"]?.takeIf { it.isNotBlank() } ?: "com.xylosaas.bestbdbazar.store"
val resolvedAppName = dartDefines["APP_NAME"]?.takeIf { it.isNotBlank() } ?: "BestBdBazar"

android {
    namespace = "com.xylosaas.xylo_customer_storefront"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = resolvedBundleId
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appName"] = resolvedAppName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            isCrunchPngs = false
        }
    }
}

flutter {
    source = "../.."
}
