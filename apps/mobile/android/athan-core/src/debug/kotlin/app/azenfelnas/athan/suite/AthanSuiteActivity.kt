package app.azenfelnas.athan.suite

import android.Manifest
import android.app.Activity
import android.os.Build
import android.os.Bundle
import app.azenfelnas.athan.bridge.AthanBridge
import app.azenfelnas.athan.bridge.AthanGraph
import app.azenfelnas.athan.codes.EventCode
import app.azenfelnas.athan.plan.EventAttrs
import app.azenfelnas.athan.plan.EventLogEntry
import app.azenfelnas.athan.plan.wireJson
import java.io.File

/**
 * Debug-only adb driver of the S21 device suite (`docs/test-plans/s21-android-athan-device-suite.md`) until the
 * pigeon host exists (D81). Files go through the app's external files directory, which adb can push to and pull
 * from without root:
 *
 * - `--es cmd apply`: reconciles `suite_plan.json`
 * - `--es cmd health`: appends a `HEALTH_EVALUATED` line (state, reasons)
 * - `--es cmd test [--ei inSeconds 60] [--es soundId athan_makkah_v1]`: starts the Athan Test
 * - `--es cmd drain`: moves `events.jsonl` to `suite_events.jsonl`
 */
public class AthanSuiteActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 0)
        }
        val graph = AthanGraph(this)
        val bridge = AthanBridge(graph)
        val exchange = getExternalFilesDir(null) ?: return finish()
        when (intent.getStringExtra("cmd")) {
            "apply" -> apply(bridge, File(exchange, "suite_plan.json"))
            "health" -> health(graph, bridge)
            "test" -> test(bridge)
            "drain" -> drain(bridge, File(exchange, "suite_events.jsonl"))
        }
        finish()
    }

    private fun apply(
        bridge: AthanBridge,
        plan: File,
    ) {
        if (plan.isFile) bridge.reconcile(plan.readText())
    }

    private fun health(
        graph: AthanGraph,
        bridge: AthanBridge,
    ) {
        val report = bridge.health()
        graph.events.append(
            EventCode.HEALTH_EVALUATED,
            EventAttrs(
                state = report.state.label,
                reason = report.reasons.joinToString(",") { it.label },
                count = report.reasons.size.toLong(),
            ),
        )
    }

    private fun test(bridge: AthanBridge) {
        bridge.startTest(
            "suite-${System.currentTimeMillis()}",
            intent.getIntExtra("inSeconds", DEFAULT_TEST_SECONDS),
            intent.getStringExtra("soundId") ?: DEFAULT_SOUND,
        )
    }

    private fun drain(
        bridge: AthanBridge,
        out: File,
    ) {
        val lines = bridge.drainEvents().map { wireJson.encodeToString(EventLogEntry.serializer(), it) }
        out.appendText(lines.joinToString("") { "$it\n" })
    }

    private companion object {
        const val DEFAULT_TEST_SECONDS: Int = 60
        const val DEFAULT_SOUND: String = "athan_makkah_v1"
    }
}
