import 'package:material_ui/material_ui.dart';

/// FabriSCAN+ mark: a 3×3 over/under weave on an indigo tile (prototype logo).
class HiblaLogo extends StatelessWidget {
  const new({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Semantics(
      excludeSemantics: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _WeavePainter(
          bg: s.primary,
          weft: s.onPrimary,
          warp: s.secondaryContainer,
        ),
      ),
    );
  }
}

class _WeavePainter extends CustomPainter {
  new({required this.bg, required this.weft, required this.warp});
  final Color bg;
  final Color weft;
  final Color warp;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 48;
    canvas
      ..save()
      ..scale(k)
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 48, 48),
          const Radius.circular(15),
        ),
        Paint()..color = bg,
      );
    const p = [16.0, 24.0, 32.0];
    Paint line(Color c, {double w = 3.6, StrokeCap cap = StrokeCap.round}) =>
        Paint()
          ..color = c
          ..strokeWidth = w
          ..strokeCap = cap;
    for (final y in p) {
      canvas.drawLine(Offset(11, y), Offset(37, y), line(weft));
    }
    for (final x in p) {
      canvas.drawLine(Offset(x, 11), Offset(x, 37), line(warp));
    }
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        final x = p[i];
        final y = p[j];
        final horizontalOver = (i + j).isEven;
        final a = horizontalOver ? Offset(x - 4.5, y) : Offset(x, y - 4.5);
        final b = horizontalOver ? Offset(x + 4.5, y) : Offset(x, y + 4.5);
        canvas
          ..drawLine(a, b, line(bg, w: 7.5, cap: StrokeCap.butt))
          ..drawLine(
            a,
            b,
            line(horizontalOver ? weft : warp, cap: StrokeCap.butt),
          );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WeavePainter old) =>
      old.bg != bg || old.weft != weft || old.warp != warp;
}

/// "FabriSCAN+" with the green plus.
class Wordmark extends StatelessWidget {
  const new({super.key, this.style});
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final base = style ?? t.textTheme.displaySmall;
    return Text.rich(
      TextSpan(
        text: 'FabriSCAN',
        children: [
          TextSpan(
            text: '+',
            style: TextStyle(color: t.colorScheme.tertiary),
          ),
        ],
      ),
      style: base,
      semanticsLabel: 'FabriSCAN+',
    );
  }
}
