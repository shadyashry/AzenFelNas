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
