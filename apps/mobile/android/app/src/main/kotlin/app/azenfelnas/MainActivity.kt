package app.azenfelnas

import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import app.azenfelnas.athan.bridge.AthanCoreHost
import app.azenfelnas.athan.bridge.AthanVoiceHost
import app.azenfelnas.pigeon.AthanSchedulerApi
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import java.io.File
import java.io.FileNotFoundException
import java.util.TimeZone

class MainActivity : FlutterActivity() {
  private var voices: AthanVoiceHost? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    // Android 12+ keeps its splash, the bare ground, until Flutter's first frame, which is the same ground
    // (DESIGN.md section 15 D112); the splash goes at once rather than through its default exit fade.
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      splashScreen.setOnExitAnimationListener { it.remove() }
    }
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    HeadingStreamHandler.register(flutterEngine.dartExecutor.binaryMessenger, applicationContext)
    // The phone's time zone names the user's region with no permission (DESIGN.md section 15 D100).
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dm/device_zone").setMethodCallHandler { call, result ->
      if (call.method == "zoneId") result.success(TimeZone.getDefault().id) else result.notImplemented()
    }
    // Free space before the offline Quran download (DESIGN.md section 15 D107).
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dm/storage").setMethodCallHandler { call, result ->
      val path = call.arguments as? String
      if (call.method == "usableBytes" && path != null) {
        result.success(File(path).let { if (it.exists()) it else filesDir }.usableSpace)
      } else {
        result.notImplemented()
      }
    }
    val core = AthanCoreHost(applicationContext)
    AthanSchedulerApi.setUp(
      flutterEngine.dartExecutor.binaryMessenger,
      AthanSchedulerHost(core, Dispatchers.IO),
    )
    Thread({ installBundledAudio(core) }, "athan-audio-install").start()
    registerVoiceAudio(flutterEngine, AthanVoiceHost(applicationContext).also { voices = it })
  }

  /** A preview never outlives the screen that started it (DESIGN.md section 15 D111). */
  override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
    voices?.stopPreview()
    super.cleanUpFlutterEngine(flutterEngine)
  }

  /**
   * `dm/athan_audio` (DESIGN.md section 15 D111): downloaded voices are copied off the main thread to where the alarm
   * service plays them; previews start and stop on the main thread, and the end of one is reported back to Dart.
   */
  private fun registerVoiceAudio(
    flutterEngine: FlutterEngine,
    voices: AthanVoiceHost,
  ) {
    val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dm/athan_audio")
    val main = Handler(Looper.getMainLooper())
    channel.setMethodCallHandler { call, result ->
      val soundId = call.argument<String>("soundId")
      val path = call.argument<String>("path")
      val sha256 = call.argument<String>("sha256")
      when (call.method) {
        "install" ->
          if (soundId != null && path != null && sha256 != null) {
            Thread({
              val ok = voices.install(soundId, path, sha256)
              main.post { result.success(ok) }
            }, "athan-voice-install").start()
          } else {
            result.success(false)
          }
        "remove" ->
          if (soundId != null) {
            Thread({
              val ok = voices.remove(soundId)
              main.post { result.success(ok) }
            }, "athan-voice-remove").start()
          } else {
            result.success(false)
          }
        "preview" ->
          result.success(
            path != null && voices.preview(path) { main.post { channel.invokeMethod("previewEnded", null) } },
          )
        "stopPreview" -> {
          voices.stopPreview()
          result.success(true)
        }
        else -> result.notImplemented()
      }
    }
  }

  /**
   * Copies the Flutter-bundled Athan sounds (`assets/athan/`, `athan_audio_manifest.v1`) into athan-core's
   * device-protected directory, so alarms find them before the first unlock (DESIGN.md §15 D94).
   */
  private fun installBundledAudio(core: AthanCoreHost) {
    val loader = FlutterInjector.instance().flutterLoader()
    fun open(path: String) =
      try {
        assets.open(loader.getLookupKeyForAsset("assets/$path"))
      } catch (_: FileNotFoundException) {
        null
      }
    val manifest = open("athan/athan_audio_manifest.json")?.use { it.readBytes().toString(Charsets.UTF_8) } ?: return
    core.installBundledAudio(manifest, ::open)
  }
}
