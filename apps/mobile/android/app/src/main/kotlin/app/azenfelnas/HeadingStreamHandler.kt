package app.azenfelnas

import android.content.Context
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.hardware.display.DisplayManager
import android.view.Display
import android.view.Surface
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/**
 * `HeadingApi` (DESIGN.md §7.8, §15 D78, D98) on the `dm/heading` event channel: listening starts
 * the orientation sensor, cancelling stops it. Each sample is
 * `{"heading": trueDegrees?, "accuracy": degrees?}`; no sensor is `{"unavailable": true}`.
 *
 * The sensor is the fused rotation vector, else the geomagnetic rotation vector (phones without a
 * gyroscope). The heading is the direction the top of the phone points when it lies flat, and the
 * direction its back faces when it is held upright (tilt over 45°); the screen's rotation is
 * compensated, so a landscape screen never reads 90° off. Successive headings are smoothed on the
 * unit circle (no jump at 0°/360°).
 *
 * True north = magnetic azimuth + `GeomagneticField.declination` (the OS's WMM) at the
 * observer's coordinates, passed as listen arguments `{"lat", "lon"}`; they are used only
 * for the declination and never stored or logged. Accuracy is the sensor status the system
 * calibrates (HIGH 10°, MEDIUM 20°, LOW 35°, UNRELIABLE unknown); the rotation vector's own
 * estimate (`values[4]`, radians) is used only while no status has arrived, and 0 means none.
 */
class HeadingStreamHandler(private val context: Context) :
    EventChannel.StreamHandler, SensorEventListener {

  private var sink: EventChannel.EventSink? = null
  private var declinationDeg = 0f
  private var statusAccuracyDeg: Double? = null
  private var smoothedSin = 0.0
  private var smoothedCos = 0.0
  private var hasSmoothed = false
  private val rotation = FloatArray(9)
  private val remapped = FloatArray(9)
  private val orientation = FloatArray(3)

  private val sensors: SensorManager?
    get() = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager

  override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
    val manager = sensors
    val sensor =
        manager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
            ?: manager?.getDefaultSensor(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR)
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
    statusAccuracyDeg = null
    hasSmoothed = false
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
    val magneticDeg = azimuthDeg()
    val heading =
        if (declinationDeg.isNaN()) null else smooth(((magneticDeg + declinationDeg) % 360 + 360) % 360)
    val estimated =
        statusAccuracyDeg
            ?: if (event.values.size > 4 && event.values[4] > 0) {
              Math.toDegrees(event.values[4].toDouble())
            } else {
              null
            }
    out.success(mapOf("heading" to heading, "accuracy" to estimated))
  }

  /** The magnetic azimuth of the phone's pointing direction, compensated for screen rotation and tilt. */
  private fun azimuthDeg(): Double {
    // Flat: the top edge points the way. Upright (tilt over 45°): the back faces the way, like a camera.
    // rotation[8] is the cosine of the angle between the screen's normal and the vertical, in any screen
    // orientation.
    val tiltDeg = Math.toDegrees(Math.acos(rotation[8].coerceIn(-1f, 1f).toDouble()))
    val upright = tiltDeg > UPRIGHT_TILT_DEG && tiltDeg < 180 - UPRIGHT_TILT_DEG
    val (axisX, axisY) =
        when (displayRotation()) {
          Surface.ROTATION_90 -> SensorManager.AXIS_Y to SensorManager.AXIS_MINUS_X
          Surface.ROTATION_180 -> SensorManager.AXIS_MINUS_X to SensorManager.AXIS_MINUS_Y
          Surface.ROTATION_270 -> SensorManager.AXIS_MINUS_Y to SensorManager.AXIS_X
          else -> SensorManager.AXIS_X to SensorManager.AXIS_Y
        }
    val (x, y) = if (upright) axisX to SensorManager.AXIS_Z else axisX to axisY
    SensorManager.remapCoordinateSystem(rotation, x, y, remapped)
    SensorManager.getOrientation(remapped, orientation)
    return Math.toDegrees(orientation[0].toDouble())
  }

  private fun displayRotation(): Int =
      (context.getSystemService(Context.DISPLAY_SERVICE) as? DisplayManager)
          ?.getDisplay(Display.DEFAULT_DISPLAY)
          ?.rotation ?: Surface.ROTATION_0

  /** Exponential smoothing on the unit circle, so the dial is steady and never spins at 0°/360°. */
  private fun smooth(deg: Double): Double {
    val rad = Math.toRadians(deg)
    if (hasSmoothed) {
      smoothedSin += SMOOTHING * (Math.sin(rad) - smoothedSin)
      smoothedCos += SMOOTHING * (Math.cos(rad) - smoothedCos)
    } else {
      smoothedSin = Math.sin(rad)
      smoothedCos = Math.cos(rad)
      hasSmoothed = true
    }
    return (Math.toDegrees(Math.atan2(smoothedSin, smoothedCos)) + 360) % 360
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

    /** Tilt from flat, degrees, beyond which the phone is read like a camera (its back faces the way). */
    private const val UPRIGHT_TILT_DEG = 45.0

    /** Weight of a new sample; at the ~16 Hz of SENSOR_DELAY_UI the dial settles in about half a second. */
    private const val SMOOTHING = 0.25

    fun register(messenger: BinaryMessenger, context: Context) {
      EventChannel(messenger, CHANNEL).setStreamHandler(HeadingStreamHandler(context))
    }
  }
}
