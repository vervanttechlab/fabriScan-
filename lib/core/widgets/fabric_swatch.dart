import 'dart:math' as math;

import 'package:fabriscan/features/catalog/domain/catalog.dart';
import 'package:material_ui/material_ui.dart';

/// Fabric picture. Uses the researchers' photo when the catalog has one;
/// until then draws a placeholder texture from the catalog `swatch`.
/// With [scrim], a dark gradient at the bottom keeps white text readable
/// (`tokens.json` photoScrim).
class FabricSwatch extends StatelessWidget {
  const new({
    required this.fabric,
    super.key,
    this.radius = 22,
    this.scrim = false,
    this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Fabric fabric;
  final double radius;
  final bool scrim;
  final Widget? child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final image = fabric.images.isNotEmpty
        ? DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(fabric.images.first),
                fit: BoxFit.cover,
              ),
            ),
          )
        : CustomPaint(painter: _SwatchPainter(fabric.swatch));
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(child: ExcludeSemantics(child: image)),
          if (scrim)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.25, 1],
                    colors: [Color(0x0017130F), Color(0xD917130F)],
                  ),
                ),
              ),
            ),
          if (child != null)
            Padding(
              padding: padding,
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white),
                child: IconTheme.merge(
                  data: const IconThemeData(color: Colors.white),
                  child: child!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SwatchPainter extends CustomPainter {
  new(this.s);
  final Swatch s;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Color(s.base);
    final accent = Color(s.accent);
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = base);
    final thin = Paint()
      ..color = accent.withValues(alpha: 0.28)
      ..strokeWidth = 1;
    switch (s.pattern) {
      case 'twill':
        for (var x = -size.height; x < size.width; x += 5) {
          canvas.drawLine(
            Offset(x, size.height),
            Offset(x + size.height, 0),
            thin..color = accent.withValues(alpha: 0.35),
          );
        }
      case 'stripe':
        for (var x = 0.0; x < size.width; x += 2) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), thin);
        }
        final band = Paint()..color = accent.withValues(alpha: 0.75);
        for (var x = 18.0; x < size.width; x += 26) {
          canvas.drawRect(Rect.fromLTWH(x, 0, 4, size.height), band);
        }
      case 'net':
        final ring = Paint()
          ..color = accent.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        for (var y = 0.0; y < size.height; y += 7) {
          for (var x = (y ~/ 7).isEven ? 0.0 : 3.5; x < size.width; x += 7) {
            canvas.drawCircle(Offset(x, y), 2.6, ring);
          }
        }
      case 'lace':
        final ring = Paint()
          ..color = accent.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        for (var y = 0.0; y < size.height + 22; y += 22) {
          for (var x = 0.0; x < size.width + 22; x += 22) {
            canvas
              ..drawCircle(Offset(x, y), 6, ring)
              ..drawCircle(
                Offset(x + 11, y + 11),
                1.6,
                Paint()..color = accent.withValues(alpha: 0.35),
              );
          }
        }
      case 'dots':
        final dot = Paint()..color = accent.withValues(alpha: 0.35);
        for (var y = 0.0; y < size.height; y += 4) {
          for (var x = (y ~/ 4).isEven ? 0.0 : 2.0; x < size.width; x += 4) {
            canvas.drawCircle(Offset(x, y), 0.8, dot);
          }
        }
      case 'check':
        final a = Paint()..color = accent;
        final red = Paint()..color = const Color(0xFFB2332C);
        for (var x = 0.0; x < size.width; x += 15) {
          canvas
            ..drawRect(
              Rect.fromLTWH(x, 0, 7, size.height),
              a..color = accent.withValues(alpha: 0.55),
            )
            ..drawRect(Rect.fromLTWH(x + 10, 0, 2, size.height), red);
        }
        for (var y = 0.0; y < size.height; y += 15) {
          canvas.drawRect(
            Rect.fromLTWH(0, y, size.width, 7),
            Paint()..color = accent.withValues(alpha: 0.45),
          );
        }
      case 'crinkle':
        final rnd = math.Random(7);
        for (var i = 0; i < size.width * size.height / 120; i++) {
          final p = Offset(
            rnd.nextDouble() * size.width,
            rnd.nextDouble() * size.height,
          );
          final d = Offset(rnd.nextDouble() * 10 - 5, rnd.nextDouble() * 4 - 2);
          canvas.drawLine(p, p + d, thin..strokeWidth = 1.5);
        }
      default: // plain + sheen: fine plain weave
        for (var y = 0.0; y < size.height; y += 3) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), thin);
        }
        for (var x = 0.0; x < size.width; x += 4) {
          canvas.drawLine(
            Offset(x, 0),
            Offset(x, size.height),
            thin..color = accent.withValues(alpha: 0.2),
          );
        }
    }
    if (s.pattern == 'sheen' || s.pattern == 'plain') {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: s.pattern == 'sheen' ? 0.45 : 0.2),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const [0.3, 0.5, 0.7],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(_SwatchPainter old) => old.s != s;
}
