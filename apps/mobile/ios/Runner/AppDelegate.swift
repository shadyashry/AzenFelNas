import CoreLocation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DmBackupExclusion") {
      BackupExclusionChannel.register(messenger: registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DmHeading") {
      HeadingStreamHandler.register(messenger: registrar.messenger())
    }
  }
}

/// Excludes a directory from iCloud and device backups (REQ-PRIV-003, DESIGN.md §7.3):
/// `MethodChannelBackupExclusion` in Dart calls it for `Application Support/places/`
/// on every start. Moves to pigeon with the other platform APIs in S20 (§15 D76).
enum BackupExclusionChannel {
  static let name = "app.dailymuslim/backup_exclusion"
  static let method = "excludeFromBackup"

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: name, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == method,
        let arguments = call.arguments as? [String: String],
        let path = arguments["path"]
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(exclude(directoryPath: path))
    }
  }

  static func exclude(directoryPath: String) -> Bool {
    var url = URL(fileURLWithPath: directoryPath, isDirectory: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    do {
      try url.setResourceValues(values)
      return true
    } catch {
      return false
    }
  }
}

/// `HeadingApi` (DESIGN.md §7.8, §15 D78) on the `dm/heading` event channel: listening starts
/// `CLLocationManager` heading updates, cancelling stops them. Each sample is
/// `{"heading": trueHeading?, "accuracy": headingAccuracy?}`; `trueHeading` is reported only
/// while it is valid (≥ 0, which needs location authorization), `headingAccuracy` only when
/// ≥ 0. No magnetometer is `{"unavailable": true}`. Here, not in its own file, because adding
/// a file needs an Xcode project edit; moves to pigeon in S20.
final class HeadingStreamHandler: NSObject, FlutterStreamHandler, CLLocationManagerDelegate {
  static let name = "dm/heading"

  private let manager = CLLocationManager()
  private var sink: FlutterEventSink?

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterEventChannel(name: name, binaryMessenger: messenger)
    channel.setStreamHandler(HeadingStreamHandler())
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    guard CLLocationManager.headingAvailable() else {
      events(["unavailable": true])
      events(FlutterEndOfEventStream)
      return nil
    }
    sink = events
    manager.delegate = self
    manager.headingFilter = 1
    manager.startUpdatingHeading()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    manager.stopUpdatingHeading()
    sink = nil
    return nil
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    guard let sink else { return }
    let heading: Any = newHeading.trueHeading >= 0 ? newHeading.trueHeading : NSNull()
    let accuracy: Any = newHeading.headingAccuracy >= 0 ? newHeading.headingAccuracy : NSNull()
    sink(["heading": heading, "accuracy": accuracy])
  }

  func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    true
  }
}
