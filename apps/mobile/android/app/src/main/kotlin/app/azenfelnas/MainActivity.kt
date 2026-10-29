package app.azenfelnas

import app.azenfelnas.athan.bridge.AthanCoreHost
import app.azenfelnas.pigeon.AthanSchedulerApi
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.Dispatchers
import java.io.FileNotFoundException

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    HeadingStreamHandler.register(flutterEngine.dartExecutor.binaryMessenger, applicationContext)
    val core = AthanCoreHost(applicationContext)
    AthanSchedulerApi.setUp(
      flutterEngine.dartExecutor.binaryMessenger,
      AthanSchedulerHost(core, Dispatchers.IO),
    )
    Thread({ installBundledAudio(core) }, "athan-audio-install").start()
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
