import 'dart:async';
import 'dart:typed_data';

import 'package:fabriscan/features/catalog/data/catalog_repository.dart';
import 'package:fabriscan/features/history/data/history_repository.dart';
import 'package:fabriscan/features/identify/data/identify_providers.dart';
import 'package:fabriscan/features/identify/domain/identification.dart';
import 'package:fabriscan/features/scan/data/photo_processing.dart';
import 'package:fabriscan/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

/// One scan, from capture to the saved History entry. Only the 256 px
/// thumbnail outlives it; the full photo is dropped (ADR-005).
@immutable
class ScanSession {
  const new({
    this.origin = '/',
    this.photo,
    this.source = PhotoSource.camera,
    this.thumbnail,
    this.result,
    this.recordId,
  });

  /// Where the scan started (Home, History…): Back from the result goes here.
  final String origin;
  final Uint8List? photo;
  final PhotoSource source;
  final Uint8List? thumbnail;
  final IdentificationResult? result;
  final String? recordId;
}

class ScanSessionNotifier extends Notifier<ScanSession> {
  @override
  ScanSession build() => const ScanSession();

  void start(String origin) => state = ScanSession(origin: origin);

  void setPhoto(Uint8List bytes, PhotoSource source) =>
      state = ScanSession(origin: state.origin, photo: bytes, source: source);

  /// Thumbnail + classification + decision; saves state A right away (US-40).
  Future<IdentificationResult> analyze() async {
    final photo = state.photo;
    if (photo == null) throw StateError('No photo to analyze');
    final classifier = await ref.read(classifierProvider.future);
    final policy = await ref.read(decisionPolicyProvider.future);
    final results = await Future.wait([
      PhotoProcessing.thumbnail(photo),
      classifier.classify(photo),
    ]);
    final thumb = results[0] as Uint8List;
    final result = policy.decide(results[1] as Map<String, double>);
    String? recordId;
    if (result.state == ResultState.confident) {
      recordId = await _save(result, result.top!.fabricId, thumb);
    }
    state = ScanSession(
      origin: state.origin,
      source: state.source,
      thumbnail: thumb,
      result: result,
      recordId: recordId,
    );
    return result;
  }

  /// B: the user picked one of the top 3. A: "Not right?" replaced the match.
  Future<void> choose(String fabricId) async {
    final result = state.result;
    final thumb = state.thumbnail;
    if (result == null || thumb == null) return;
    final policy = await ref.read(decisionPolicyProvider.future);
    final score =
        result.topK.where((s) => s.fabricId == fabricId).firstOrNull?.score ??
        0;
    final level = policy.levelFor(score);
    final repo = ref.read(historyRepositoryProvider);
    if (state.recordId case final id?) {
      await repo.changeChoice(id, fabricId, level);
    } else {
      final id = await _save(result, fabricId, thumb, level: level);
      state = ScanSession(
        origin: state.origin,
        source: state.source,
        thumbnail: thumb,
        result: result,
        recordId: id,
      );
    }
  }

  Future<String> _save(
    IdentificationResult result,
    String fabricId,
    Uint8List thumb, {
    ConfidenceLevel level = ConfidenceLevel.high,
  }) async {
    final catalog = await ref.read(catalogProvider.future);
    return await ref
        .read(historyRepositoryProvider)
        .save(
          result: result,
          chosenFabricId: fabricId,
          confidence: level,
          source: state.source,
          thumbnailJpeg: thumb,
          contentVersion: catalog.contentVersion,
        );
  }
}

final scanSessionProvider = NotifierProvider<ScanSessionNotifier, ScanSession>(
  ScanSessionNotifier.new,
);

/// Entry point for every Scan / Upload button (US-10, US-11).
Future<void> startScan(BuildContext context, {bool upload = false}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final router = GoRouter.of(context);
  final origin = router.routerDelegate.currentConfiguration.uri.toString();
  final session = container.read(scanSessionProvider.notifier)
    ..start(origin.startsWith('/scan') ? '/' : origin);
  if (upload) {
    await pickFromGallery(context, session);
    return;
  }
  final status = await Permission.camera.status;
  if (status.isGranted) {
    unawaited(router.push('/scan/camera'));
  } else if (status.isPermanentlyDenied || status.isRestricted) {
    unawaited(router.push('/scan/permission?denied=1'));
  } else {
    unawaited(router.push('/scan/permission'));
  }
}

/// Gallery pick → review. Unreadable files show an error (US-11).
Future<void> pickFromGallery(
  BuildContext context,
  ScanSessionNotifier session, {
  bool replace = false,
}) async {
  final router = GoRouter.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final l = AppLocalizations.of(context);
  final XFile? file;
  try {
    file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
    );
  } on Exception {
    messenger.showSnackBar(SnackBar(content: Text(l.photoUnreadable)));
    return;
  }
  if (file == null) return;
  final bytes = await file.readAsBytes();
  if (!await PhotoProcessing.canDecode(bytes)) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l.photoUnreadable),
          behavior: SnackBarBehavior.floating,
        ),
      );
    return;
  }
  session.setPhoto(bytes, PhotoSource.gallery);
  if (replace) {
    unawaited(router.pushReplacement('/scan/review'));
  } else {
    unawaited(router.push('/scan/review'));
  }
}

/// Retake from a result: same way the photo was taken last time.
Future<void> retake(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final source = container.read(scanSessionProvider).source;
  await startScan(context, upload: source == PhotoSource.gallery);
}
