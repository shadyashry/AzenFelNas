package app.azenfelnas

import app.azenfelnas.athan.bridge.AthanCoreHost
import app.azenfelnas.pigeon.AthanSchedulerApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.Dispatchers

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    HeadingStreamHandler.register(flutterEngine.dartExecutor.binaryMessenger, applicationContext)
    AthanSchedulerApi.setUp(
      flutterEngine.dartExecutor.binaryMessenger,
      AthanSchedulerHost(AthanCoreHost(applicationContext), Dispatchers.IO),
    )
  }
}
