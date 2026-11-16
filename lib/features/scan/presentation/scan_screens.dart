import 'dart:async';

import 'package:camera/camera.dart';
import 'package:fabriscan/core/widgets/hibla_logo.dart';
import 'package:fabriscan/features/catalog/data/catalog_repository.dart';
import 'package:fabriscan/features/history/data/history_repository.dart';
import 'package:fabriscan/features/scan/presentation/scan_session.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

/// S07 Camera permission primer and denied state (US-10).
class PermissionScreen extends ConsumerStatefulWidget {
  const new({super.key, this.denied = false});
  final bool denied;

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen>
    with WidgetsBindingObserver {
  late bool _denied = widget.denied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Coming back from phone Settings: continue if the camera is now allowed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _denied) unawaited(_recheck());
  }

  Future<void> _recheck() async {
    if (await Permission.camera.isGranted && mounted) {
      context.pushReplacement('/scan/camera');
    }
  }

  Future<void> _allow() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      context.pushReplacement('/scan/camera');
    } else {
      setState(() => _denied = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final s = t.colorScheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _denied ? s.errorContainer : s.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _denied
                        ? Symbols.no_photography_rounded
                        : Symbols.photo_camera_rounded,
                    size: 56,
                    color: _denied ? s.onErrorContainer : s.onPrimaryContainer,
                  ),
                ),
              ),
              Text(
                _denied ? l.permDeniedTitle : l.permTitle,
                style: t.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Text(
                _denied ? l.permDeniedBody : l.permBody,
                style: t.textTheme.bodyLarge?.copyWith(
                  color: s.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              if (_denied)
                FilledButton.icon(
                  onPressed: openAppSettings,
                  icon: const Icon(Symbols.settings_rounded),
                  label: Text(l.permOpenSettings),
                )
              else
                FilledButton.icon(
                  onPressed: _allow,
                  icon: const Icon(Symbols.photo_camera_rounded),
                  label: Text(l.permAllow),
                ),
              FilledButton.tonalIcon(
                onPressed: () => pickFromGallery(
                  context,
                  ref.read(scanSessionProvider.notifier),
                  replace: true,
                ),
                icon: const Icon(Symbols.photo_library_rounded),
                label: Text(l.permUpload),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// S08 Camera: full-bleed preview, framing guide, live tips, shutter.
class CameraScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _controller;
  Object? _error;
  bool _busy = false;
  int _tip = 0;
  Timer? _tipTimer;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_init());
    _tipTimer = Timer.periodic(
      const Duration(milliseconds: 2600),
      (_) => setState(() => _tip++),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) throw CameraException('none', 'No camera');
      final back = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final c = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await c.initialize();
      await c.setFlashMode(FlashMode.off);
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _controller = c;
        _error = null;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (state == AppLifecycleState.inactive && c != null) {
      _controller = null;
      unawaited(c.dispose());
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      unawaited(_init());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tipTimer?.cancel();
    _pulse.dispose();
    unawaited(_controller?.dispose());
    super.dispose();
  }

  Future<void> _shoot() async {
    final c = _controller;
    if (c == null || _busy || !c.value.isInitialized) return;
    setState(() => _busy = true);
    unawaited(HapticFeedback.mediumImpact());
    try {
      final file = await c.takePicture();
      final bytes = await file.readAsBytes();
      ref
          .read(scanSessionProvider.notifier)
          .setPhoto(bytes, PhotoSource.camera);
      if (mounted) await context.push('/scan/review');
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tips = [l.camTip1, l.camTip2, l.camTip3, l.camTip4];
    final c = _controller;
    const glass = Color(0x9E17130F);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (c != null && c.value.isInitialized)
            ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: c.value.previewSize!.height,
                  height: c.value.previewSize!.width,
                  child: CameraPreview(c),
                ),
              ),
            )
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    const Icon(
                      Symbols.no_photography_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                    Text(
                      l.camError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    FilledButton.icon(
                      onPressed: () => pickFromGallery(
                        context,
                        ref.read(scanSessionProvider.notifier),
                        replace: true,
                      ),
                      icon: const Icon(Symbols.photo_library_rounded),
                      label: Text(l.permUpload),
                    ),
                  ],
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          if (_error == null)
            IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) => Transform.scale(
                    scale: 1 - _pulse.value * 0.04,
                    child: CustomPaint(
                      size: Size.square(
                        MediaQuery.sizeOf(context).shortestSide * 0.72,
                      ),
                      painter: _ReticlePainter(),
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: glass),
                        tooltip: l.camClose,
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Symbols.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: glass),
                        tooltip: l.camTips,
                        onPressed: () => context.push('/help'),
                        icon: const Icon(
                          Symbols.lightbulb_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  liveRegion: true,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(_tip % tips.length),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: glass,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tips[_tip % tips.length],
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filled(
                        iconSize: 28,
                        style: IconButton.styleFrom(
                          backgroundColor: glass,
                          minimumSize: const Size.square(56),
                        ),
                        tooltip: l.camGallery,
                        onPressed: () => pickFromGallery(
                          context,
                          ref.read(scanSessionProvider.notifier),
                        ),
                        icon: const Icon(
                          Symbols.photo_library_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: l.camShutter,
                        child: GestureDetector(
                          onTap: _shoot,
                          child: AnimatedScale(
                            scale: _busy ? 0.86 : 1,
                            duration: const Duration(milliseconds: 150),
                            child: Container(
                              width: 78,
                              height: 78,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 56),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const len = 34.0;
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, len)
      ..lineTo(0, 0)
      ..lineTo(len, 0)
      ..moveTo(w - len, 0)
      ..lineTo(w, 0)
      ..lineTo(w, len)
      ..moveTo(w, h - len)
      ..lineTo(w, h)
      ..lineTo(w - len, h)
      ..moveTo(len, h)
      ..lineTo(0, h)
      ..lineTo(0, h - len);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_ReticlePainter oldDelegate) => false;
}

/// S09 Review photo: Use photo / Retake.
class ReviewScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final session = ref.watch(scanSessionProvider);
    final photo = session.photo;
    if (photo == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    return Scaffold(
      appBar: AppBar(title: Text(l.reviewTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.memory(
                    photo,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    semanticLabel: l.yourPhoto,
                    errorBuilder: (context, _, _) =>
                        Center(child: Text(l.photoUnreadable)),
                  ),
                ),
              ),
              Text(
                l.reviewHint,
                textAlign: TextAlign.center,
                style: t.textTheme.bodyMedium?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (session.source == PhotoSource.gallery) {
                          unawaited(
                            pickFromGallery(
                              context,
                              ref.read(scanSessionProvider.notifier),
                              replace: true,
                            ),
                          );
                        } else {
                          context.pop();
                        }
                      },
                      icon: const Icon(Symbols.replay_rounded),
                      label: Text(l.reviewRetake),
                    ),
                  ),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        // Camera and review leave the stack: Back from the
                        // result returns to where the scan started.
                        final router = GoRouter.of(context)..go(session.origin);
                        unawaited(router.push('/scan/analyzing'));
                      },
                      icon: const Icon(Symbols.check_rounded),
                      label: Text(l.reviewUse),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// S10 Analyzing: woven scan animation while the scanner runs (US-16).
class AnalyzingScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends ConsumerState<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _line = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  int _msg = 0;
  Timer? _msgTimer;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _msgTimer = Timer.periodic(
      const Duration(milliseconds: 700),
      (_) => setState(() => _msg = (_msg + 1).clamp(0, 2)),
    );
    unawaited(_run());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context) && !_line.isAnimating) {
      _line.repeat(reverse: true);
    }
  }

  Future<void> _run() async {
    setState(() => _failed = false);
    try {
      // Show the animation for at least 1.2 s so it reads as a step, but
      // never wait longer than the scanner needs beyond that.
      await Future.wait([
        ref.read(scanSessionProvider.notifier).analyze(),
        Future<void>.delayed(const Duration(milliseconds: 1200)),
      ]);
      if (mounted) context.pushReplacement('/result');
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _line.dispose();
    _msgTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context);
    final photo = ref.watch(scanSessionProvider).photo;
    final count = ref.watch(catalogProvider).value?.fabrics.length ?? 0;
    final msgs = [l.analyzing1, l.analyzing2(count), l.analyzing3];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: [
              SizedBox.square(
                dimension: 240,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (photo != null)
                        Image.memory(photo, fit: BoxFit.cover)
                      else
                        const Center(child: HiblaLogo(size: 88)),
                      AnimatedBuilder(
                        animation: _line,
                        builder: (context, _) => Align(
                          alignment: Alignment(0, _line.value * 2 - 1),
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: t.colorScheme.inversePrimary,
                              boxShadow: [
                                BoxShadow(
                                  color: t.colorScheme.inversePrimary,
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_failed) ...[
                Text(l.analyzingError, textAlign: TextAlign.center),
                FilledButton(onPressed: _run, child: Text(l.tryAgain)),
              ] else ...[
                Text(l.analyzingTitle, style: t.textTheme.headlineSmall),
                Semantics(
                  liveRegion: true,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      msgs[_msg],
                      key: ValueKey(_msg),
                      style: t.textTheme.bodyLarge?.copyWith(
                        color: t.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 200, child: LinearProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
