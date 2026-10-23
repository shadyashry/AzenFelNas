package app.dailymuslim.athan.plan

import kotlinx.serialization.KSerializer

/** Result of decoding a wire document with [wireJson]; a malformed document is a value, not an exception. */
internal sealed interface WireDecode<out T> {
    /** The document decoded to [value]. */
    data class Decoded<out T>(
        val value: T,
    ) : WireDecode<T>

    /** The document does not have the schema's shape, for [reason]. */
    data class Malformed(
        val reason: String,
    ) : WireDecode<Nothing>
}

/** Decodes [json] with [serializer]. */
internal fun <T> decodeWire(
    serializer: KSerializer<T>,
    json: String,
): WireDecode<T> =
    try {
        WireDecode.Decoded(wireJson.decodeFromString(serializer, json))
    } catch (e: IllegalArgumentException) {
        // kotlinx.serialization reports malformed input as SerializationException, an IllegalArgumentException.
        WireDecode.Malformed(e.message ?: e.javaClass.simpleName)
    }

/** The decoded value, or null when malformed. */
internal fun <T> WireDecode<T>.valueOrNull(): T? =
    when (this) {
        is WireDecode.Decoded -> value
        is WireDecode.Malformed -> null
    }
