package app.azenfelnas.athan.notify

import app.azenfelnas.athan.plan.LocalizedText
import app.azenfelnas.athan.plan.PlanLocale
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

internal class PlanTextTest {
    @Test
    fun `REQ-DOM-040 locale changes only which pre-rendered text native shows, falling back to en`() {
        assertEquals("أذان الفجر", LocalizedText(ar = "أذان الفجر", en = "Fajr Athan").render(PlanLocale.AR))
        assertEquals("Fajr Athan", LocalizedText(ar = "أذان الفجر", en = "Fajr Athan").render(PlanLocale.EN))
        assertEquals("Fajr Athan", LocalizedText(ar = " ", en = "Fajr Athan").render(PlanLocale.AR))
    }
}
