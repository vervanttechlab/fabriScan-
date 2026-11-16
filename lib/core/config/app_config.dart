/// Build-time configuration. Values that tune the scanner (thresholds,
/// temperature) are NOT here: they live in `assets/model/model_meta.json`.
abstract final class AppConfig {
  /// TAM survey link (US-52). Empty = the "Take the survey" row is hidden.
  /// Set at build time: `--dart-define=TAM_SURVEY_URL=https://...`
  static const String tamSurveyUrl = String.fromEnvironment('TAM_SURVEY_URL');

  /// Use the Firebase Local Emulator Suite instead of the real project.
  /// Set with `--dart-define=USE_FIREBASE_EMULATOR=true`.
  static const bool useFirebaseEmulator = bool.fromEnvironment(
    'USE_FIREBASE_EMULATOR',
  );
}
