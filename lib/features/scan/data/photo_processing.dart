import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Photo work that must stay off the UI thread.
abstract final class PhotoProcessing {
  /// True when [bytes] is an image this app can read (US-11 error state).
  static Future<bool> canDecode(Uint8List bytes) =>
      Isolate.run(() => img.decodeImage(bytes) != null);

  /// Square 256 px JPEG, ≤ 30 KB (ADR-005). Applies EXIF orientation and
  /// centre-crops, so the thumbnail shows the middle of the photo, where the
  /// framing guide was.
  static Future<Uint8List> thumbnail(Uint8List bytes) =>
      Isolate.run(() => makeThumbnail(bytes));

  static Uint8List makeThumbnail(Uint8List bytes, {int size = 256}) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const FormatException('Not an image');
    final oriented = img.bakeOrientation(decoded);
    final side = oriented.width < oriented.height
        ? oriented.width
        : oriented.height;
    final square = img.copyCrop(
      oriented,
      x: (oriented.width - side) ~/ 2,
      y: (oriented.height - side) ~/ 2,
      width: side,
      height: side,
    );
    final small = img.copyResize(
      square,
      width: size,
      height: size,
      interpolation: img.Interpolation.average,
    );
    var quality = 80;
    var jpg = img.encodeJpg(small, quality: quality);
    while (jpg.length > 30 * 1024 && quality > 30) {
      quality -= 10;
      jpg = img.encodeJpg(small, quality: quality);
    }
    return jpg;
  }
}
