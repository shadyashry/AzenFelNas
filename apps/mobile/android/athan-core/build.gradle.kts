// athan-core: native Athan layer (DESIGN.md §8.1). Reads SchedulePlan only; never calculates times (ADR-002).
// Wire models since S02, plan stores since S20, scheduling, receivers, playback, channels and probes since S21,
// the Glance prayer-times widget since S28 (§15 D88). §17.3.
plugins {
    id("com.android.library")
    // gradle.properties keeps android.builtInKotlin=false (Flutter template), so Kotlin is applied explicitly.
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.serialization")
    // Glance renders with the Compose runtime (S28 widget).
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "app.dailymuslim.athan"
    buildFeatures {
        compose = true
    }
    compileSdk =
        libs.versions.compile.sdk
            .get()
            .toInt()

    defaultConfig {
        minSdk =
            libs.versions.min.sdk
                .get()
                .toInt()
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    testOptions {
        unitTests.all {
            it.useJUnitPlatform()
            // Repository root, so tests can read schemas/fixtures and DESIGN.md (ADR-023 round-trip).
            it.systemProperty("dm.repoRoot", rootProject.projectDir.resolve("../../..").canonicalPath)
        }
    }
}

dependencies {
    implementation(libs.kotlinx.serialization.json)
    implementation(libs.androidx.glance.appwidget)
    testImplementation(libs.junit.jupiter)
    testRuntimeOnly(libs.junit.platform.launcher)
}

kotlin {
    explicitApi()
    compilerOptions {
        allWarningsAsErrors = true
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
