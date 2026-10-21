package app.dailymuslim.athan.plan

import kotlinx.serialization.json.Json

/**
 * JSON configuration of every wire model (DESIGN.md §17.3, ADR-023): unknown keys are ignored so a reader
 * accepts schema N and N−1, and absent optional members are not written as null (§15 D21).
 */
internal val wireJson: Json =
    Json {
        ignoreUnknownKeys = true
        explicitNulls = false
    }
