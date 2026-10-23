#if canImport(UserNotifications)
    import Foundation

    /// Bundled assets found by a lookup closure (Runner passes Flutter's asset key lookup).
    private struct LookupAssets: AssetSource {
        let lookup: @Sendable (String) -> URL?

        func url(ofAsset path: String) -> URL? {
            lookup(path)
        }
    }

    public extension AthanHost {
        /// The live host over `AthanGraph.live`; nil when the App Group entitlement or the bundled copy is
        /// missing. `assetURL` resolves a Flutter asset path (relative to `assets/`) to its file.
        static func live(assetURL: @escaping @Sendable (String) -> URL?) -> AthanHost? {
            AthanGraph.live(assets: LookupAssets(lookup: assetURL)).map { AthanHost(bridge: AthanBridge(graph: $0)) }
        }
    }
#endif
