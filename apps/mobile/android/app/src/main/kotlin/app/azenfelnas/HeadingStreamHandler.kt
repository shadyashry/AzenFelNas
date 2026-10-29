package app.azenfelnas

import android.content.Context
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/**
 * `HeadingApi` (DESIGN.md §7.8, §15 D78) on the `dm/heading` event channel: listening starts
 * the rotation-vector sensor, cancelling stops it. Each sample is
 * `{"heading": trueDegrees?, "accuracy": degrees?}`; no sensor is `{"unavailable": true}`.
 *
 * True north = magnetic azimuth + `GeomagneticField.declination` (the OS's WMM) at the
 * observer's coordinates, passed as listen arguments `{"lat", "lon"}`; they are used only
 * for the declination and never stored or logged. Accuracy is the sensor's estimated heading
 * accuracy (`values[4]`, radians) when it reports one, otherwise the sensor status mapped to
 * HIGH 10°, MEDIUM 20°, LOW 35°, UNRELIABLE unknown. Moves to pigeon in S20.
 */
class HeadingStreamHandler(private val context: Context) :
    EventChannel.StreamHandler, SensorEventListener {

  private var sink: EventChannel.EventSink? = null
  private var declinationDeg = 0f
  private var statusAccuracyDeg: Double? = null
  private val rotation = FloatArray(9)
  private val orientation = FloatArray(3)

  private val sensors: SensorManager?
    get() = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager

  override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
    val manager = sensors
    val sensor = manager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
    if (manager == null || sensor == null) {
      events.success(mapOf("unavailable" to true))
      events.endOfStream()
      return
    }
    val args = arguments as? Map<*, *>
    val lat = (args?.get("lat") as? Double)?.toFloat()
    val lon = (args?.get("lon") as? Double)?.toFloat()
    declinationDeg =
        if (lat != null && lon != null) {
          GeomagneticField(lat, lon, 0f, System.currentTimeMillis()).declination
        } else {
          Float.NaN
        }
    sink = events
    manager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI)
  }

  override fun onCancel(arguments: Any?) {
    sensors?.unregisterListener(this)
    sink = null
  }

  override fun onSensorChanged(event: SensorEvent) {
    val out = sink ?: return
    SensorManager.getRotationMatrixFromVector(rotation, event.values)
    SensorManager.getOrientation(rotation, orientation)
    val magneticDeg = Math.toDegrees(orientation[0].toDouble())
    val heading =
        if (declinationDeg.isNaN()) null else ((magneticDeg + declinationDeg) % 360 + 360) % 360
    val estimated =
        // A zero estimate is "no estimate" on many phones (and the emulator), never a perfect compass
        // (DESIGN.md §15 D97); the sensor status is used instead.
        if (event.values.size > 4 && event.values[4] > 0) {
          Math.toDegrees(event.values[4].toDouble())
        } else {
          statusAccuracyDeg
        }
    out.success(mapOf("heading" to heading, "accuracy" to estimated))
  }

  override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {
    statusAccuracyDeg =
        when (accuracy) {
          SensorManager.SENSOR_STATUS_ACCURACY_HIGH -> 10.0
          SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM -> 20.0
          SensorManager.SENSOR_STATUS_ACCURACY_LOW -> 35.0
          else -> null
        }
  }

  companion object {
    const val CHANNEL = "dm/heading"

    fun register(messenger: BinaryMessenger, context: Context) {
      EventChannel(messenger, CHANNEL).setStreamHandler(HeadingStreamHandler(context))
    }
  }
}
