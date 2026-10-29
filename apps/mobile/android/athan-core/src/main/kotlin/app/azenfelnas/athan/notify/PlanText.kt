package app.azenfelnas.athan.notify

import app.azenfelnas.athan.plan.LocalizedText
import app.azenfelnas.athan.plan.PlanLocale

/** Pre-rendered plan text in [locale], falling back to `en` (DESIGN.md §7.7); native never composes copy. */
internal fun LocalizedText.render(locale: PlanLocale): String =
    when (locale) {
        PlanLocale.AR -> ar.ifBlank { en }
        PlanLocale.EN -> en
    }
