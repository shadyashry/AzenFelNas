import java.security.MessageDigest
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

// The Quran ships inside the app (DESIGN.md §15 D117, D128): `assets/quran/` is not in git, and
// `tool/bundle_quran.py` copies the pinned package there. Without it the app silently falls back to the CDN
// download, so a release build stops here unless the bundle is the one `QuranEditionPin` pins and every file
// the manifest lists is present at its size. Debug builds only warn. A build that is meant to have no Quran
// (CI, which never holds the package) says so with the environment variable DM_QURAN_BUNDLE=optional.
val appRoot = rootProject.projectDir.parentFile
val quranDir = File(appRoot, "assets/quran")
val quranPin = File(appRoot, "lib/features/quran/domain/quran_edition_pin.dart")
val quranOptional = System.getenv("DM_QURAN_BUNDLE") == "optional"

fun quranBundleProblem(): String? {
    val manifest = File(quranDir, "manifest.json")
    if (!manifest.isFile) return "assets/quran/manifest.json is missing"
    val pin = quranPin.readText()
    val sha = Regex("""manifestSha256 =\s*'([0-9a-f]{64})'""").find(pin)?.groupValues?.get(1)
        ?: return "cannot read manifestSha256 in ${quranPin.name}"
    val actual = MessageDigest.getInstance("SHA-256").digest(manifest.readBytes())
        .joinToString("") { "%02x".format(it) }
    if (actual != sha) return "assets/quran/manifest.json is $actual, the pin is $sha"
    val entry = Regex(""""path":\s*"([^"]+)",\s*"bytes":\s*(\d+)""")
    for (file in entry.findAll(manifest.readText())) {
        val (path, bytes) = file.destructured
        val local = File(quranDir, path)
        if (local.length() != bytes.toLong()) return "assets/quran/$path is missing or not $bytes bytes"
    }
    return null
}

val checkQuranBundle = tasks.register("checkQuranBundle") {
    description = "Fails a release build whose bundled Quran is missing or not the pinned package (D128)."
    doLast {
        val problem = quranBundleProblem() ?: return@doLast
        if (quranOptional) {
            logger.warn("No bundled Quran ($problem); DM_QURAN_BUNDLE=optional, so the app will download it.")
        } else {
            throw GradleException(
                "No bundled Quran: $problem.\nRun `uv run --no-project python -I tool/bundle_quran.py " +
                    "<package dir>` in apps/mobile first, or set DM_QURAN_BUNDLE=optional for a build that " +
                    "downloads the Quran (DESIGN.md §15 D128).",
            )
        }
    }
}

val warnQuranBundle = tasks.register("warnQuranBundle") {
    description = "Warns when a debug build has no bundled Quran (D128)."
    doLast {
        quranBundleProblem()?.let { logger.warn("No bundled Quran ($it); this build will offer the download.") }
    }
}

tasks.matching { it.name == "preReleaseBuild" }.configureEach { dependsOn(checkQuranBundle) }
tasks.matching { it.name == "preDebugBuild" }.configureEach { dependsOn(warnQuranBundle) }

dependencies {
    // Native Athan layer (DESIGN.md §8.1); its S19 spike sources stay in athan-core/src/debug (D79, D81).
    implementation(project(":athan-core"))
    // Pigeon's Kotlin host runs @async calls as suspend functions (§15 D83).
    implementation(libs.kotlinx.coroutines.android)
    // Quran radio: one player in a media session service (DESIGN.md section 15 D122). Apache-2.0.
    implementation(libs.androidx.media3.exoplayer)
    implementation(libs.androidx.media3.session)
}
