import 'package:material_ui/material_ui.dart';

/// Padding for a scrolling page: 16 dp side gutters, and a bottom margin that
/// clears whatever covers the bottom of the screen (the phone's navigation
/// bar, and on tab pages the floating nav bar, which the shell reports
/// through MediaQuery padding because it uses `extendBody`).
EdgeInsets pagePadding(
  BuildContext context, {
  double top = 0,
  double bottom = 24,
}) => EdgeInsets.fromLTRB(
  16,
  top,
  16,
  bottom + MediaQuery.paddingOf(context).bottom,
);
