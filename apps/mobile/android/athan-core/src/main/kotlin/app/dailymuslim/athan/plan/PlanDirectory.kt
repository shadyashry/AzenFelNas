package app.dailymuslim.athan.plan

import android.content.Context
import java.io.File

/** Where plan, snapshot and events live: `<device-protected files>/plan/` (DESIGN.md §8.1, REQ-ALM-022). */
internal object PlanDirectory {
    /** The plan directory of [context], readable before the first unlock. */
    fun of(context: Context): File = File(context.createDeviceProtectedStorageContext().filesDir, "plan")
}
