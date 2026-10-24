#if canImport(AthanKit)
  import AthanKit
  import Flutter
  import Foundation

  /// The pigeon `AthanSchedulerApi` host over AthanKit (DESIGN.md §7.8, §15 D83). It only maps types; every
  /// decision stays in AthanKit. Unknown labels map to `unknown` or are dropped, never to `ready`.
  final class AthanSchedulerHost: AthanSchedulerApi {
    private let host: AthanHost

    init(host: AthanHost) {
      self.host = host
    }

    /// Registers the host on `messenger`; without a live AthanKit graph the channel stays unanswered and Dart
    /// reports Health `unknown` (§0.2 rule 10).
    static func register(messenger: FlutterBinaryMessenger, assetURL: @escaping @Sendable (String) -> URL?) {
      guard let host = AthanHost.live(assetURL: assetURL) else { return }
      AthanSchedulerApiSetup.setUp(binaryMessenger: messenger, api: AthanSchedulerHost(host: host))
    }

    func reconcile(schedulePlanJson: String) async throws {
      await host.reconcile(schedulePlanJson)
    }

    func cancelGenerationsBelow(generation: Int64) async throws {
      await host.cancelGenerationsBelow(Int(generation))
    }

    func health() async throws -> AthanHealthReport {
      let health = await host.health()
      return AthanHealthReport(
        state: Self.state(health.state),
        reasons: health.reasons.compactMap(Self.reason),
        probes: health.probes.map { ProbeResult(name: $0.name, positive: $0.positive, detail: $0.detail) },
        evaluatedAtUtcMs: health.evaluatedAtUtcMs,
        platformPath: health.platformPath
      )
    }

    func startTest(testId: String, fireInSeconds: Int64, soundId: String) async throws -> Bool {
      await host.startTest(testId: testId, fireInSeconds: Int(fireInSeconds), soundId: soundId)
    }

    func drainEvents() async throws -> [String] {
      host.drainEvents()
    }

    func writeSnapshot(snapshotJson: String) async throws -> Bool {
      host.writeSnapshot(snapshotJson)
    }

    private static func state(_ label: String) -> HealthState {
      switch label {
      case "ready": .ready
      case "limited": .limited
      case "notReady": .notReady
      default: .unknown
      }
    }

    private static func reason(_ label: String) -> HealthReason? {
      switch label {
      case "needsNotificationPermission": .needsNotificationPermission
      case "needsAlarmKitAuthorization": .needsAlarmKitAuthorization
      case "mutedChannel": .mutedChannel
      case "stalePlan": .stalePlan
      case "horizonEnding": .horizonEnding
      case "noSoundAsset": .noSoundAsset
      case "unverifiableDelivery": .unverifiableDelivery
      default: nil
      }
    }
  }
#endif
