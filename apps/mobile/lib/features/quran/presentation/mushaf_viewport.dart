import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_geometry.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Builds one item (a page or a spread) at [size] logical pixels.
typedef MushafItemBuilder = Widget Function(
  BuildContext context,
  int item,
  Size size,
);

/// The Mushaf's reading surface (§15 D106, REQ-QRN-020, REQ-QRN-030).
///
/// Items are laid out right to left whatever the interface language: the
/// next item lies to the left, a swipe to the right (or the left arrow key)
/// turns forward. One scale gesture recognizer decides what a touch means,
/// so the gestures never compete:
///
/// * two fingers zoom around their focal point (1..4×) and pan;
/// * one finger, when the page is no wider than the screen, turns the page
///   if the drag is mostly horizontal and pans vertically otherwise (fit
///   width);
/// * one finger on a zoomed page pans it, up to its edges;
/// * in drawing mode one finger draws a highlight area instead, and pages
///   turn only with the buttons;
/// * a double tap zooms to 2.5× there, or back to fit.
///
/// The zoom resets to fit when the page changes or the window is resized
/// (rotation, split screen), so the page stays whole and the reader keeps
/// their page. This is a leaf interaction widget: its gesture state is
/// local (`setState`), everything durable lives in providers.
final class MushafViewport extends StatefulWidget {
  /// The viewport showing [item] of [itemCount].
  const new({
    required this.itemCount,
    required this.item,
    required this.aspect,
    required this.fit,
    required this.itemBuilder,
    required this.onItemChanged,
    required this.controller,
    required this.drawing,
    required this.onDraw,
    required this.onTap,
    required this.semanticLabel,
    super.key,
  });

  /// Pages, or spreads.
  final int itemCount;

  /// The item to show (0-based).
  final int item;

  /// Width / height of one item.
  final double aspect;

  /// Fit mode.
  final PageFit fit;

  /// Builds an item.
  final MushafItemBuilder itemBuilder;

  /// Called when the reader turned to another item.
  final ValueChanged<int> onItemChanged;

  /// Receives commands from the reader's buttons.
  final MushafViewportController controller;

  /// Whether one finger draws a highlight area.
  final bool drawing;

  /// A finished area on [item], corners relative to the item (0..1).
  final void Function(int item, Offset a, Offset b) onDraw;

  /// A tap at a point relative to [item] (0..1).
  final void Function(int item, Offset point) onTap;

  /// What a screen reader announces for the surface.
  final String semanticLabel;

  @override
  State<MushafViewport> createState() => _MushafViewportState();
}

enum _Drag { undecided, turn, pan, zoom, draw }

final class _MushafViewportState extends State<MushafViewport> {
  late PageController _pages;
  late int _current;
  double _scale = 1;
  Offset? _offset;
  Size _lastSize = Size.zero;

  _Drag _drag = _Drag.undecided;
  Offset _startFocal = Offset.zero;
  Offset _startOffset = Offset.zero;
  double _startScale = 1;
  double _startPixels = 0;
  int _startItem = 0;
  Offset? _drawA;
  Offset? _drawB;
  Offset _doubleTapAt = Offset.zero;
  MushafGeometry? _geometry;

  @override
  void initState() {
    super.initState();
    _current = widget.item;
    _pages = PageController(initialPage: widget.item);
    widget.controller.handler = _command;
  }

  @override
  void didUpdateWidget(MushafViewport old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.handler = null;
      widget.controller.handler = _command;
    }
    if (old.itemCount != widget.itemCount) {
      _pages.dispose();
      _pages = PageController(initialPage: widget.item);
      _current = widget.item;
      _resetZoom();
    } else if (widget.item != _current && _pages.hasClients) {
      _current = widget.item;
      _resetZoom();
      _pages.jumpToPage(widget.item);
    }
  }

  @override
  void dispose() {
    widget.controller.handler = null;
    _pages.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _scale = 1;
    _offset = null;
    widget.controller.reportScale(1);
  }

  void _setZoom(double scale, Offset offset) {
    final geometry = _geometry;
    if (geometry == null) return;
    setState(() {
      _scale = MushafGeometry.clampScale(scale);
      _offset = geometry.clampOffset(offset, _scale);
    });
    widget.controller.reportScale(_scale);
  }

  void _command(ViewportCommand command) {
    final geometry = _geometry;
    if (geometry == null) return;
    final centre = geometry.viewport.center(Offset.zero);
    final offset = _offset ?? geometry.baseOffset;
    switch (command) {
      case ViewportCommand.next:
        _turnTo(_current + 1);
      case ViewportCommand.previous:
        _turnTo(_current - 1);
      case ViewportCommand.zoomIn:
        final to = MushafGeometry.clampScale(_scale * 1.5);
        _setZoom(to, geometry.zoomAround(centre, offset, _scale, to));
      case ViewportCommand.zoomOut:
        final to = MushafGeometry.clampScale(_scale / 1.5);
        _setZoom(to, geometry.zoomAround(centre, offset, _scale, to));
      case ViewportCommand.reset:
        setState(_resetZoom);
    }
  }

  void _turnTo(int item) {
    if (item < 0 || item >= widget.itemCount || !_pages.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(item);
    } else {
      _pages.animateToPage(
        item,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int item) {
    _current = item;
    setState(_resetZoom);
    widget.onItemChanged(item);
  }

  void _onScaleStart(ScaleStartDetails d) {
    final geometry = _geometry;
    if (geometry == null) return;
    _startFocal = d.localFocalPoint;
    _startScale = _scale;
    _startOffset = _offset ?? geometry.baseOffset;
    _startPixels = _pages.hasClients ? _pages.position.pixels : 0;
    _startItem = _current;
    _drag = d.pointerCount >= 2
        ? _Drag.zoom
        : widget.drawing
        ? _Drag.draw
        : _Drag.undecided;
    if (_drag == _Drag.draw) {
      _drawA = geometry.relative(d.localFocalPoint, _startOffset, _scale);
      _drawB = _drawA;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final geometry = _geometry;
    if (geometry == null) return;
    if (d.pointerCount >= 2) {
      _drag = _Drag.zoom;
      final to = MushafGeometry.clampScale(_startScale * d.scale);
      final point = (_startFocal - _startOffset) / _startScale;
      _setZoom(to, d.localFocalPoint - point * to);
      return;
    }
    final delta = d.localFocalPoint - _startFocal;
    switch (_drag) {
      case _Drag.draw:
        setState(
          () => _drawB = geometry.relative(
            d.localFocalPoint,
            _offset ?? geometry.baseOffset,
            _scale,
          ),
        );
      case _Drag.undecided:
        if (delta.distance < kTouchSlop) return;
        _drag = delta.dx.abs() > delta.dy.abs() && geometry.turnsPages(_scale)
            ? _Drag.turn
            : _Drag.pan;
        _onScaleUpdate(d);
      case _Drag.turn:
        if (!_pages.hasClients) return;
        final position = _pages.position;
        // Right to left: a drag to the right moves forward.
        position.jumpTo(
          (_startPixels + delta.dx).clamp(
            position.minScrollExtent,
            position.maxScrollExtent,
          ),
        );
      case _Drag.pan:
        _setZoom(_scale, _startOffset + delta);
      case _Drag.zoom:
        break;
    }
  }

  void _onScaleEnd(ScaleEndDetails d) {
    final geometry = _geometry;
    switch (_drag) {
      case _Drag.turn when geometry != null && _pages.hasClients:
        final moved = _pages.position.pixels - _startPixels;
        final velocity = d.velocity.pixelsPerSecond.dx;
        final threshold = geometry.viewport.width * 0.18;
        // One page per swipe, counted from where the swipe started: the
        // page view may already report the next page halfway through.
        var target = _startItem;
        if (moved > threshold || velocity > 500) target = _startItem + 1;
        if (moved < -threshold || velocity < -500) target = _startItem - 1;
        target = target.clamp(0, widget.itemCount - 1);
        if (target == _current) {
          _pages.animateToPage(
            target,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
          );
        } else {
          _turnTo(target);
        }
      case _Drag.zoom when _scale < 1.03:
        setState(_resetZoom);
      case _Drag.draw:
        final a = _drawA;
        final b = _drawB;
        if (a != null && b != null) widget.onDraw(_current, a, b);
        setState(() => _drawA = _drawB = null);
      case _Drag.turn || _Drag.zoom || _Drag.pan || _Drag.undecided:
        break;
    }
    _drag = _Drag.undecided;
  }

  void _onDoubleTap() {
    final geometry = _geometry;
    if (geometry == null || widget.drawing) return;
    if (_scale > 1.05) {
      setState(_resetZoom);
    } else {
      final offset = _offset ?? geometry.baseOffset;
      _setZoom(2.5, geometry.zoomAround(_doubleTapAt, offset, _scale, 2.5));
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final command = switch (event.logicalKey) {
      // The Mushaf reads right to left in every interface language.
      LogicalKeyboardKey.arrowLeft ||
      LogicalKeyboardKey.pageDown => ViewportCommand.next,
      LogicalKeyboardKey.arrowRight ||
      LogicalKeyboardKey.pageUp => ViewportCommand.previous,
      LogicalKeyboardKey.equal ||
      LogicalKeyboardKey.add ||
      LogicalKeyboardKey.numpadAdd => ViewportCommand.zoomIn,
      LogicalKeyboardKey.minus ||
      LogicalKeyboardKey.numpadSubtract => ViewportCommand.zoomOut,
      LogicalKeyboardKey.digit0 => ViewportCommand.reset,
      _ => null,
    };
    if (command == null) return KeyEventResult.ignored;
    _command(command);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.biggest;
      final geometry = _geometry = MushafGeometry(
        viewport: size,
        aspect: widget.aspect,
        fit: widget.fit,
      );
      if (size != _lastSize) {
        _lastSize = size;
        _scale = 1;
        _offset = null;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.controller.reportScale(1),
        );
      }
      return Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: Semantics(
          label: widget.semanticLabel,
          container: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            onTapUp: (d) => widget.onTap(
              _current,
              geometry.relative(
                d.localPosition,
                _offset ?? geometry.baseOffset,
                _scale,
              ),
            ),
            onDoubleTapDown: (d) => _doubleTapAt = d.localPosition,
            onDoubleTap: _onDoubleTap,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: PageView.builder(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.itemCount,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, item) => _item(context, item, geometry),
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _item(BuildContext context, int item, MushafGeometry geometry) {
    final current = item == _current;
    final scale = current ? _scale : 1.0;
    final offset = current
        ? (_offset ?? geometry.baseOffset)
        : geometry.baseOffset;
    final size = geometry.baseSize * scale;
    final a = _drawA;
    final b = _drawB;
    return ClipRect(
      child: Stack(
        children: [
          Positioned(
            left: offset.dx,
            top: offset.dy,
            width: size.width,
            height: size.height,
            child: widget.itemBuilder(context, item, size),
          ),
          if (current && a != null && b != null)
            Positioned(
              left: offset.dx + size.width * (a.dx < b.dx ? a.dx : b.dx),
              top: offset.dy + size.height * (a.dy < b.dy ? a.dy : b.dy),
              width: size.width * (a.dx - b.dx).abs(),
              height: size.height * (a.dy - b.dy).abs(),
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
