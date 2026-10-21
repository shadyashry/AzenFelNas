# athan-core (Kotlin)

Native Athan layer for Android (`DESIGN.md` §8.1, ADR-002, ADR-012). It reads the `SchedulePlan` only, works with no Dart isolate alive, and never calculates times.

Empty until slice S21. The compiler bar is fixed now: `explicitApi()`, warnings as errors, JVM 17, minSdk 26, compileSdk 36. Versions come from `../gradle/libs.versions.toml`. detekt and ktlint are wired in S21 with the first Kotlin source.
