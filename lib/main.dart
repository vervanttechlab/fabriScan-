import 'package:fabriscan/app/app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

// Firebase is initialised in M4 (accounts & sync), after `flutterfire
// configure` has created `lib/firebase_options.dart`. Guest mode never needs it.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Designed for portrait only (prototype, camera framing).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: FabriScanApp()));
}
