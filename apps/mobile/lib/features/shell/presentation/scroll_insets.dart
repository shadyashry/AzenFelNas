import 'package:flutter/widgets.dart';

/// The padding of a page's scroll view (§15 D100): [horizontal], [top] and
/// [bottom] around the content, plus whatever covers the bottom of the
/// screen. The app is drawn edge to edge (required from Android 15), so the
/// system navigation bar, and on the tab pages the floating tab bar, lie
/// over the page; the last row must still scroll clear of them.
EdgeInsets scrollInsets(
  BuildContext context, {
  double horizontal = 0,
  double top = 0,
  double bottom = 24,
}) => EdgeInsets.fromLTRB(
  horizontal,
  top,
  horizontal,
  bottom + MediaQuery.paddingOf(context).bottom,
);
