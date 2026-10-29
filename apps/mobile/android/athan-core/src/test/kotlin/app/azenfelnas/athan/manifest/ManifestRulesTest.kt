package app.azenfelnas.athan.manifest

import app.azenfelnas.athan.plan.repoRoot
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.w3c.dom.Element
import java.io.File
import javax.xml.parsers.DocumentBuilderFactory

/** Static rules over `athan-core`'s manifest and sources; the device suite proves the behaviour (D81). */
internal class ManifestRulesTest {
    private val module = File(repoRoot, "apps/mobile/android/athan-core/src/main")
    private val manifest: Element =
        DocumentBuilderFactory
            .newInstance()
            .apply { isNamespaceAware = true }
            .newDocumentBuilder()
            .parse(File(module, "AndroidManifest.xml"))
            .documentElement

    private fun elements(tag: String): List<Element> =
        manifest.getElementsByTagName(tag).let { list -> (0 until list.length).map { list.item(it) as Element } }

    private fun Element.android(name: String): String = getAttributeNS(ANDROID_NS, name)

    private fun actionsOf(receiver: Element): List<String> =
        receiver.getElementsByTagName("action").let { list ->
            (0 until list.length).map { (list.item(it) as Element).android("name") }
        }

    @Test
    fun `REQ-ALM-021 every receiver and the service are exported=false`() {
        val components = elements("receiver") + elements("service")

        assertEquals(7, components.size)
        components.forEach { assertEquals("false", it.android("exported"), it.android("name")) }
    }

    @Test
    fun `REQ-ALM-022 a directBootAware receiver handles LOCKED_BOOT_COMPLETED`() {
        val boot = elements("receiver").single { "android.intent.action.LOCKED_BOOT_COMPLETED" in actionsOf(it) }

        assertEquals("true", boot.android("directBootAware"))
        assertTrue("android.intent.action.BOOT_COMPLETED" in actionsOf(boot))
        // Every Athan component runs before the first unlock; the widget receiver does not (§15 D88): Glance keeps
        // its session state in credential-encrypted storage, and a widget redrawn after unlock loses no Athan.
        (elements("receiver") + elements("service"))
            .filterNot { it.android("name") == WIDGET_RECEIVER }
            .forEach { assertEquals("true", it.android("directBootAware")) }
        assertEquals(
            "false",
            elements("receiver").single { it.android("name") == WIDGET_RECEIVER }.android("directBootAware"),
        )
    }

    @Test
    fun `REQ-ALM-002 receivers listen for time, zone, package-replaced and exact-permission changes`() {
        val actions = elements("receiver").flatMap(::actionsOf).toSet()

        assertTrue(
            actions.containsAll(
                listOf(
                    "android.intent.action.TIME_SET",
                    "android.intent.action.TIMEZONE_CHANGED",
                    "android.intent.action.MY_PACKAGE_REPLACED",
                    "android.app.action.SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED",
                ),
            ),
        )
    }

    @Test
    fun `REQ-ALM-023 playback is a mediaPlayback foreground service`() {
        val service = elements("service").single()
        val permissions = elements("uses-permission").map { it.android("name") }

        assertEquals("mediaPlayback", service.android("foregroundServiceType"))
        assertTrue("android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" in permissions)
    }

    @Test
    fun `REQ-ALM-020 exact alarms come from SCHEDULE_EXACT_ALARM only, never USE_EXACT_ALARM or full-screen intents`() {
        val permissions = elements("uses-permission").map { it.android("name") }

        assertTrue("android.permission.SCHEDULE_EXACT_ALARM" in permissions)
        assertFalse("android.permission.USE_EXACT_ALARM" in permissions)
        assertFalse("android.permission.USE_FULL_SCREEN_INTENT" in permissions)
    }

    @Test
    fun `REQ-ALM-021 every PendingIntent is created with the immutable flags`() {
        val calls =
            module
                .walkTopDown()
                .filter { it.extension == "kt" }
                .flatMap { file ->
                    Regex("""PendingIntent\.get\w+\(([^()]|\([^()]*\))*\)""").findAll(file.readText()).map { it.value }
                }.toList()

        assertTrue(calls.size >= 5)
        calls.forEach { assertTrue(it.contains("PENDING_FLAGS"), it) }
        assertTrue(
            File(
                module,
                "kotlin/app/azenfelnas/athan/receive/TriggerIntents.kt",
            ).readText().contains("FLAG_IMMUTABLE"),
        )
    }

    private companion object {
        const val ANDROID_NS: String = "http://schemas.android.com/apk/res/android"
        const val WIDGET_RECEIVER: String = "app.azenfelnas.athan.widget.glance.PrayerTimesWidgetReceiver"
    }
}
