package app.azenfelnas.athan.spike

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import app.azenfelnas.athan.codes.EventCode
import app.azenfelnas.athan.plan.EventAttrs
import java.security.SecureRandom

/**
 * Debug-only adb entry point of the S19 spike (plan: `docs/adr/ADR-025-s19-native-spike.md`):
 *
 * - `--es cmd schedule --es scenario doze --ei inSeconds 120 [--ei count 1 --ei spacingSeconds 60]`
 * - `--es cmd heard|not_heard --es entryId <id>` (the tester's answer, REQ-ALM-040)
 * - `--es cmd exact_settings` (opens the exact-alarm settings page)
 */
public class SpikeActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 0)
        }
        SpikeNotifications(this).ensureChannels()
        when (intent.getStringExtra("cmd")) {
            "schedule" -> {
                schedule()
            }

            SpikeLabels.HEARD, SpikeLabels.NOT_HEARD -> {
                answer(intent.getStringExtra("cmd"))
            }

            "exact_settings" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    startActivity(
                        Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, Uri.parse("package:$packageName")),
                    )
                }
            }
        }
        finish()
    }

    private fun schedule() {
        val scenario = intent.getStringExtra("scenario") ?: "foreground"
        val inMs = intent.getIntExtra("inSeconds", DEFAULT_IN_SECONDS) * MS_PER_SECOND
        val spacingMs = intent.getIntExtra("spacingSeconds", DEFAULT_SPACING_SECONDS) * MS_PER_SECOND
        val scheduler = SpikeScheduler(this)
        val now = System.currentTimeMillis()
        repeat(intent.getIntExtra("count", 1)) { n ->
            scheduler.schedule(newEntryId(), now + inMs + n * spacingMs, scenario)
        }
    }

    private fun answer(reason: String?) {
        val entryId = intent.getStringExtra(SpikeLabels.EXTRA_ENTRY_ID) ?: return
        SpikeEventLog(this).append(EventCode.TEST_RESULT, EventAttrs(entryId = entryId, reason = reason))
    }

    private fun newEntryId(): String {
        val bytes = ByteArray(ID_BYTES).also { SecureRandom().nextBytes(it) }
        return bytes.joinToString("") { "%02x".format(it) }
    }

    private companion object {
        const val DEFAULT_IN_SECONDS: Int = 120
        const val DEFAULT_SPACING_SECONDS: Int = 60
        const val MS_PER_SECOND: Long = 1000L
        const val ID_BYTES: Int = 8
    }
}
