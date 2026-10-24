import Foundation
#if canImport(WidgetKit)
    import WidgetKit

    /// `WidgetReloader` over WidgetKit: the app wrote a new snapshot (a new plan, profile, context or locale).
    struct WidgetKitReloader: WidgetReloader {
        func reloadAll() {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
#endif

/// The live reloader: WidgetKit where it exists, none elsewhere.
func liveWidgetReloader() -> any WidgetReloader {
    #if canImport(WidgetKit)
        WidgetKitReloader()
    #else
        NoWidgetReloader()
    #endif
}
