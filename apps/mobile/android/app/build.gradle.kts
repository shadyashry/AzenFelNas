import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// The Play upload key (DESIGN.md §20, §15 D95): `android/key.properties` (git-ignored) names the keystore and
// its passwords. Without it, release builds are signed with the debug key: installable for testing, never
// uploadable.
val uploadKey =
    rootProject.file("key.properties").takeIf { it.isFile }?.let { file ->
        Properties().apply { file.inputStream().use { load(it) } }
    }

android {
    namespace = "app.azenfelnas"
    // SDK levels come from the version catalog, shared with athan-core
    // (DESIGN.md §5.4, §8.1, §15 D92).
    compileSdk = libs.versions.compile.sdk.get().toInt()
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "app.azenfelnas"
        minSdk = libs.versions.min.sdk.get().toInt()
        targetSdk = libs.versions.target.sdk.get().toInt()
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (uploadKey != null) {
            create("upload") {
                storeFile = rootProject.file(uploadKey.getProperty("storeFile"))
                storePassword = uploadKey.getProperty("storePassword")
                keyAlias = uploadKey.getProperty("keyAlias")
                keyPassword = uploadKey.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (uploadKey != null) "upload" else "debug")
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
    // Native Athan layer (DESIGN.md §8.1); its S19 spike sources stay in athan-core/src/debug (D79, D81).
    implementation(project(":athan-core"))
    // Pigeon's Kotlin host runs @async calls as suspend functions (§15 D83).
    implementation(libs.kotlinx.coroutines.android)
    // Quran radio: one player in a media session service (DESIGN.md section 15 D122). Apache-2.0.
    implementation(libs.androidx.media3.exoplayer)
    implementation(libs.androidx.media3.session)
}
