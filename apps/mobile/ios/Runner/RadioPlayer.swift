import AVFoundation
import Flutter
import MediaPlayer

/// Quran radio's one player on iOS (DESIGN.md §15 D122): `dm/radio` commands and `dm/radio/state`
/// events, the same contract as Android's `RadioService`.
///
/// - Audio session `.playback` with the Background Audio mode, so a station keeps playing with the
///   screen locked; Now Playing information with `isLiveStream`, and lock-screen / Control Center
///   Play, Pause, toggle and Stop. Seeking and skipping are disabled: a live stream has no position.
/// - An interruption (a call, an alarm) or the headphones going pauses for good: nothing resumes by
///   itself (REQ-RADIO-011).
/// - A failed or ended stream is tried again 3 times, after 2, 5 and 10 s, then the station is
///   unavailable (REQ-RADIO-008). A new station, Pause or Stop cancels a pending retry; a callback
///   from an older attempt is ignored by its generation.
/// - The sleep timer stops playback at its deadline, retries included (REQ-RADIO-009).
/// - Nothing plays until Dart asks after a tap; nothing starts after the app is relaunched.
final class RadioPlayer: NSObject, FlutterStreamHandler {
  static let shared = RadioPlayer()

  private static let retryDelays: [TimeInterval] = [2, 5, 10]

  private let player = AVPlayer()
  private var sink: FlutterEventSink?
  private var phase = "ready"
  private var stationId: String?
  private var url: URL?
  private var title = ""
  private var subtitle = ""
  private var wantsPlay = false
  private var attempt = 0
  private var generation = 0
  private var retry: DispatchWorkItem?
  private var sleepMinutes = 0
  private var sleepDeadline: Date?
  private var sleepTimer: Timer?
  private var itemStatus: NSKeyValueObservation?
  private var controlStatus: NSKeyValueObservation?
  private var itemEnded: NSObjectProtocol?
  private var commandsReady = false

  private override init() {
    super.init()
    player.automaticallyWaitsToMinimizeStalling = true
    controlStatus = player.observe(\.timeControlStatus, options: [.new]) { [weak self] _, _ in
      DispatchQueue.main.async { self?.followControlStatus() }
    }
    let center = NotificationCenter.default
    center.addObserver(
      self, selector: #selector(interrupted(_:)),
      name: AVAudioSession.interruptionNotification, object: nil)
    center.addObserver(
      self, selector: #selector(routeChanged(_:)),
      name: AVAudioSession.routeChangeNotification, object: nil)
  }

  /// Registers both channels on [messenger].
  static func register(messenger: FlutterBinaryMessenger) {
    FlutterMethodChannel(name: "dm/radio", binaryMessenger: messenger)
      .setMethodCallHandler { call, result in shared.handle(call, result: result) }
    FlutterEventChannel(name: "dm/radio/state", binaryMessenger: messenger)
      .setStreamHandler(shared)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    switch call.method {
    case "state":
      result(stateMap())
    case "play":
      guard let id = args?["stationId"] as? String,
        let raw = args?["url"] as? String,
        let stream = URL(string: raw), stream.scheme == "https"
      else {
        result(FlutterError(code: "bad-request", message: "a station id and an https url are required", details: nil))
        return
      }
      play(id: id, url: stream, title: args?["title"] as? String ?? "", subtitle: args?["subtitle"] as? String ?? "")
      result(nil)
    case "pause":
      pause()
      result(nil)
    case "resume":
      resume()
      result(nil)
    case "stop":
      stop()
      result(nil)
    case "sleep":
      setSleep(minutes: args?["minutes"] as? Int ?? 0)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    events(stateMap())
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  // MARK: Commands

  private func play(id: String, url stream: URL, title: String, subtitle: String) {
    generation += 1
    cancelRetry()
    attempt = 0
    stationId = id
    url = stream
    self.title = title
    self.subtitle = subtitle
    wantsPlay = true
    activateSession()
    setUpRemoteCommands()
    load(stream)
    player.play()
    phase = "connecting"
    publish()
  }

  private func pause() {
    wantsPlay = false
    cancelRetry()
    player.pause()
    if stationId != nil, phase != "unavailable" { phase = "paused" }
    publish()
  }

  private func resume() {
    guard let stream = url else { return }
    wantsPlay = true
    activateSession()
    if phase == "unavailable" || player.currentItem == nil || player.currentItem?.status == .failed {
      generation += 1
      attempt = 0
      load(stream)
      phase = "connecting"
    }
    player.play()
    publish()
  }

  private func stop() {
    generation += 1
    cancelRetry()
    cancelSleep()
    wantsPlay = false
    player.pause()
    player.replaceCurrentItem(with: nil)
    unobserveItem()
    stationId = nil
    url = nil
    attempt = 0
    phase = "stopped"
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    publish()
  }

  private func setSleep(minutes: Int) {
    cancelSleep()
    if minutes > 0 {
      sleepMinutes = minutes
      let deadline = Date().addingTimeInterval(TimeInterval(minutes * 60))
      sleepDeadline = deadline
      sleepTimer = Timer.scheduledTimer(withTimeInterval: deadline.timeIntervalSinceNow, repeats: false) {
        [weak self] _ in self?.stop()
      }
    }
    publish()
  }

  private func cancelSleep() {
    sleepTimer?.invalidate()
    sleepTimer = nil
    sleepMinutes = 0
    sleepDeadline = nil
  }

  // MARK: Stream and retries

  private func load(_ stream: URL) {
    unobserveItem()
    let item = AVPlayerItem(url: stream)
    item.preferredForwardBufferDuration = 10
    let run = generation
    itemStatus = item.observe(\.status, options: [.new]) { [weak self] item, _ in
      if item.status == .failed {
        DispatchQueue.main.async { self?.failed(run) }
      }
    }
    itemEnded = NotificationCenter.default.addObserver(
      forName: .AVPlayerItemFailedToPlayToEndTime, object: item, queue: .main
    ) { [weak self] _ in self?.failed(run) }
    player.replaceCurrentItem(with: item)
  }

  private func unobserveItem() {
    itemStatus?.invalidate()
    itemStatus = nil
    if let ended = itemEnded { NotificationCenter.default.removeObserver(ended) }
    itemEnded = nil
  }

  private func failed(_ run: Int) {
    guard run == generation, wantsPlay, let stream = url else { return }
    if attempt >= Self.retryDelays.count {
      phase = "unavailable"
      publish()
      return
    }
    let delay = Self.retryDelays[attempt]
    attempt += 1
    phase = "reconnecting"
    let work = DispatchWorkItem { [weak self] in
      guard let self, run == self.generation, self.wantsPlay else { return }
      self.generation += 1
      self.load(stream)
      self.player.play()
    }
    retry = work
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    publish()
  }

  private func cancelRetry() {
    retry?.cancel()
    retry = nil
  }

  private func followControlStatus() {
    guard stationId != nil, phase != "stopped" else { return }
    switch player.timeControlStatus {
    case .playing:
      attempt = 0
      phase = "playing"
    case .waitingToPlayAtSpecifiedRate:
      if phase != "reconnecting" { phase = attempt > 0 ? "reconnecting" : "connecting" }
    case .paused:
      if !wantsPlay, phase != "unavailable" { phase = "paused" }
    @unknown default:
      break
    }
    publish()
  }

  // MARK: Session, interruptions, system controls

  private func activateSession() {
    let session = AVAudioSession.sharedInstance()
    try? session.setCategory(.playback, mode: .default, options: [])
    try? session.setActive(true)
  }

  @objc private func interrupted(_ note: Notification) {
    guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
      AVAudioSession.InterruptionType(rawValue: raw) == .began
    else { return }
    // Paused for good: the listener resumes (REQ-RADIO-011).
    DispatchQueue.main.async { if self.wantsPlay { self.pause() } }
  }

  @objc private func routeChanged(_ note: Notification) {
    guard let raw = note.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
      AVAudioSession.RouteChangeReason(rawValue: raw) == .oldDeviceUnavailable
    else { return }
    DispatchQueue.main.async { if self.wantsPlay { self.pause() } }
  }

  private func setUpRemoteCommands() {
    guard !commandsReady else { return }
    commandsReady = true
    let center = MPRemoteCommandCenter.shared()
    center.playCommand.addTarget { [weak self] _ in
      self?.resume()
      return .success
    }
    center.pauseCommand.addTarget { [weak self] _ in
      self?.pause()
      return .success
    }
    center.togglePlayPauseCommand.addTarget { [weak self] _ in
      guard let self else { return .commandFailed }
      if self.wantsPlay { self.pause() } else { self.resume() }
      return .success
    }
    center.stopCommand.addTarget { [weak self] _ in
      self?.stop()
      return .success
    }
    for command in [
      center.nextTrackCommand, center.previousTrackCommand, center.skipForwardCommand,
      center.skipBackwardCommand, center.seekForwardCommand, center.seekBackwardCommand,
      center.changePlaybackPositionCommand,
    ] {
      command.isEnabled = false
    }
  }

  private func updateNowPlaying() {
    guard stationId != nil else {
      MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
      return
    }
    MPNowPlayingInfoCenter.default().nowPlayingInfo = [
      MPMediaItemPropertyTitle: title,
      MPMediaItemPropertyArtist: subtitle,
      MPNowPlayingInfoPropertyIsLiveStream: true,
      MPNowPlayingInfoPropertyPlaybackRate: phase == "playing" ? 1.0 : 0.0,
    ]
  }

  // MARK: State

  private func stateMap() -> [String: Any?] {
    [
      "phase": phase,
      "stationId": stationId,
      "attempt": phase == "reconnecting" ? attempt : 0,
      "sleepMinutes": sleepMinutes,
      "sleepDeadlineUtcMs": sleepDeadline.map { Int($0.timeIntervalSince1970 * 1000) },
    ]
  }

  private func publish() {
    updateNowPlaying()
    sink?(stateMap())
  }
}
