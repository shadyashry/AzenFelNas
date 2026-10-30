import 'package:flutter/foundation.dart';

/// A command from the reader's buttons or keys to the viewport.
enum ViewportCommand {
  /// The next page in reading order (to the left).
  next,

  /// The previous page (to the right).
  previous,

  /// Zoom in one step around the centre.
  zoomIn,

  /// Zoom out one step.
  zoomOut,

  /// Back to the fit size.
  reset,
}

/// Sends [ViewportCommand]s to a mounted `MushafViewport` and reports its
/// zoom, so buttons can be enabled only when they do something.
final class MushafViewportController extends ChangeNotifier {
  /// The controller.
  new();

  void Function(ViewportCommand command)? _handler;
  double _scale = 1;

  /// The viewport's current zoom (1 = fit).
  double get scale => _scale;

  /// Sends [command]; ignored when no viewport is mounted.
  void send(ViewportCommand command) => _handler?.call(command);

  /// Called by the viewport when it mounts or unmounts.
  void attach(void Function(ViewportCommand command)? handler) =>
      _handler = handler;

  /// Called by the viewport when its zoom changes.
  void reportScale(double scale) {
    if (scale == _scale) return;
    _scale = scale;
    notifyListeners();
  }
}
