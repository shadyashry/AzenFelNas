import Flutter
import UIKit
#if DEBUG && canImport(AthanKit)
    import AthanKit
#endif

class SceneDelegate: FlutterSceneDelegate {
    #if DEBUG && canImport(AthanKit)
        // S19 native spike (docs/adr/ADR-025-s19-native-spike.md): `azenfelnas://spike/...` URLs drive the
        // AlarmKit and notification-budget probes in debug builds once AthanKit is linked; all others go to Flutter.
        override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
            let rest = URLContexts.filter { !S19Spike.handle(url: $0.url) }
            if !rest.isEmpty {
                super.scene(scene, openURLContexts: rest)
            }
        }
    #endif
}
