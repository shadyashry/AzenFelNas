package app.dailymuslim.athan.codes

import app.dailymuslim.athan.plan.repoRoot
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import java.io.File

internal class CodesMirrorTest {
    /** The backticked code list after [label] in DESIGN.md Appendix J. */
    private fun appendixJCodes(label: String): List<String> {
        val appendix =
            File(repoRoot, "DESIGN.md")
                .readText()
                .substringAfter("## Appendix J")
                .substringBefore("## Appendix K")
        val list =
            Regex("$label: `([^`]+)`")
                .find(appendix)
                ?.groupValues
                ?.get(1)
                .orEmpty()
        return list.split(", ")
    }

    @Test
    fun `failure codes mirror Appendix J in order (REQ-ERR-002)`() {
        assertEquals(appendixJCodes("Failures"), FailureCode.entries.map { it.name })
    }

    @Test
    fun `event codes mirror Appendix J in order (REQ-ERR-002)`() {
        assertEquals(appendixJCodes("Event-log codes"), EventCode.entries.map { it.name })
    }
}
