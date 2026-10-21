@testable import AthanKit
import Foundation
import Testing

/// The backticked code list after `label` in DESIGN.md Appendix J.
private func appendixJCodes(_ label: String) throws -> [String] {
    let design = try String(contentsOf: repositoryRoot().appendingPathComponent("DESIGN.md"), encoding: .utf8)
    guard
        let start = design.range(of: "## Appendix J"),
        let end = design.range(of: "## Appendix K", range: start.upperBound ..< design.endIndex)
    else {
        throw FixtureError.sectionNotFound("Appendix J")
    }
    let appendix = design[start.upperBound ..< end.lowerBound]
    guard
        let open = appendix.range(of: "\(label): `"),
        let close = appendix.range(of: "`", range: open.upperBound ..< appendix.endIndex)
    else {
        throw FixtureError.sectionNotFound(label)
    }
    return appendix[open.upperBound ..< close.lowerBound].components(separatedBy: ", ")
}

@Test("failure codes mirror Appendix J in order (REQ-ERR-002)")
func failureCodesMirrorAppendixJ() throws {
    let expected = try appendixJCodes("Failures")

    #expect(FailureCode.allCases.map(\.rawValue) == expected)
}

@Test("event codes mirror Appendix J in order (REQ-ERR-002)")
func eventCodesMirrorAppendixJ() throws {
    let expected = try appendixJCodes("Event-log codes")

    #expect(EventCode.allCases.map(\.rawValue) == expected)
}
