package app.azenfelnas.athan.plan

import kotlinx.serialization.KSerializer
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.DynamicTest
import java.io.File

/** Repository root, passed by Gradle as the `dm.repoRoot` system property. */
internal val repoRoot: File =
    File(
        checkNotNull(System.getProperty("dm.repoRoot")) { "dm.repoRoot system property is not set" },
    )

/** `schemas/fixtures/<schema>/<kind>/<name>`. */
internal fun fixture(
    schema: String,
    kind: String,
    name: String,
): File = File(repoRoot, "schemas/fixtures/$schema/$kind/$name")

/**
 * One dynamic test per JSON file in `schemas/fixtures/<schema>/valid`: decode with [serializer], encode again
 * and expect the same JSON tree (ADR-023 round-trip). Fails when the schema has no valid fixture.
 */
internal fun <T> roundTripValidFixtures(
    schema: String,
    serializer: KSerializer<T>,
): List<DynamicTest> {
    val files =
        File(repoRoot, "schemas/fixtures/$schema/valid")
            .listFiles { file -> file.extension == "json" }
            .orEmpty()
            .sortedBy { it.name }
    check(files.isNotEmpty()) { "no valid fixtures for $schema" }
    return files.map { file ->
        DynamicTest.dynamicTest("$schema ${file.name} round-trips unchanged") {
            val original = file.readText()

            val encoded = wireJson.encodeToString(serializer, wireJson.decodeFromString(serializer, original))

            assertEquals(Json.parseToJsonElement(original), Json.parseToJsonElement(encoded))
        }
    }
}
