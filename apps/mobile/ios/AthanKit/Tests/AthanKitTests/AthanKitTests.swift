import Testing
@testable import AthanKit

@Test func packageBuildsWithStrictConcurrency() {
    // S01 runway check: the module compiles in Swift 6 language mode.
    #expect(String(describing: AthanKit.self) == "AthanKit")
}
