// athan-core: native Athan layer (DESIGN.md §8.1). Reads SchedulePlan only; never calculates times (ADR-002).
// Empty until slice S21; this file fixes the module's compiler bar (§17.3).
plugins {
    id("com.android.library")
    // gradle.properties keeps android.builtInKotlin=false (Flutter template), so Kotlin is applied explicitly.
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "app.dailymuslim.athan"
    compileSdk = libs.versions.compile.sdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.min.sdk.get().toInt()
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

kotlin {
    explicitApi()
    compilerOptions {
        allWarningsAsErrors = true
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
