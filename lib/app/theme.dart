import 'package:material_ui/material_ui.dart';

/// Hibla theme. Every value comes from `docs/design/tokens.json`
/// (via `docs/design/handoff-notes.md` section 1). Don't add colours or font
/// sizes in widgets; read them from `Theme.of(context)` instead.
abstract final class HiblaTheme {
  static const String displayFont = 'Fraunces';
  static const String uiFont = 'PlusJakartaSans';

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2E3F8F),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDDE1F7),
    onPrimaryContainer: Color(0xFF17225A),
    secondary: Color(0xFF6B4E35),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF2DEC8),
    onSecondaryContainer: Color(0xFF2A1A0B),
    tertiary: Color(0xFF3D6B37),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD3EBC8),
    onTertiaryContainer: Color(0xFF10290D),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFFAF6EE),
    onSurface: Color(0xFF3B2A1E),
    onSurfaceVariant: Color(0xFF6B5644),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF6F0E4),
    surfaceContainer: Color(0xFFF1EADC),
    surfaceContainerHigh: Color(0xFFEBE3D3),
    surfaceContainerHighest: Color(0xFFE5DCCA),
    outline: Color(0xFF8C7A68),
    outlineVariant: Color(0xFFD8CCB9),
    inverseSurface: Color(0xFF3B2A1E),
    onInverseSurface: Color(0xFFFAF6EE),
    inversePrimary: Color(0xFFB7C2FF),
    scrim: Color(0xFF000000),
    shadow: Color(0xFF000000),
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFB7C2FF),
    onPrimary: Color(0xFF15205A),
    primaryContainer: Color(0xFF34418A),
    onPrimaryContainer: Color(0xFFDDE1FF),
    secondary: Color(0xFFDCC1A6),
    onSecondary: Color(0xFF3D2914),
    secondaryContainer: Color(0xFF55402B),
    onSecondaryContainer: Color(0xFFF2DEC8),
    tertiary: Color(0xFF9FD39A),
    onTertiary: Color(0xFF0E3A10),
    tertiaryContainer: Color(0xFF255322),
    onTertiaryContainer: Color(0xFFD3EBC8),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF17130F),
    onSurface: Color(0xFFF1E8DA),
    onSurfaceVariant: Color(0xFFCDBFAE),
    surfaceContainerLowest: Color(0xFF120E0B),
    surfaceContainerLow: Color(0xFF1F1A15),
    surfaceContainer: Color(0xFF2A241E),
    surfaceContainerHigh: Color(0xFF342D26),
    surfaceContainerHighest: Color(0xFF3F3730),
    outline: Color(0xFF9A8B7A),
    outlineVariant: Color(0xFF4E4337),
    inverseSurface: Color(0xFFF1E8DA),
    onInverseSurface: Color(0xFF3B2A1E),
    inversePrimary: Color(0xFF2E3F8F),
    scrim: Color(0xFF000000),
    shadow: Color(0xFF000000),
  );

  static ThemeData light() => _build(lightScheme, ConfidenceColors.light);
  static ThemeData dark() => _build(darkScheme, ConfidenceColors.dark);

  static TextStyle _style(
    String family,
    double size,
    double lineHeight,
    int weight,
    double tracking,
  ) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: family == displayFont
        ? const ['Georgia', 'serif']
        : const ['Roboto', 'sans-serif'],
    fontSize: size,
    height: lineHeight / size,
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    // Bundled fonts are variable fonts: set the weight axis explicitly.
    fontVariations: [FontVariation('wght', weight.toDouble())],
    letterSpacing: tracking,
  );

  /// `tokens.json` → `typeScale`. Display + headline use Fraunces;
  /// title, body and label use Plus Jakarta Sans.
  static final TextTheme textTheme = TextTheme(
    displaySmall: _style(displayFont, 36, 44, 600, -0.25),
    headlineLarge: _style(displayFont, 32, 40, 600, -0.25),
    headlineMedium: _style(displayFont, 28, 36, 600, 0),
    headlineSmall: _style(displayFont, 24, 32, 600, 0),
    titleLarge: _style(uiFont, 20, 28, 700, 0),
    titleMedium: _style(uiFont, 16, 24, 700, 0.1),
    titleSmall: _style(uiFont, 14, 20, 700, 0.1),
    bodyLarge: _style(uiFont, 16, 24, 400, 0.2),
    bodyMedium: _style(uiFont, 14, 20, 400, 0.2),
    bodySmall: _style(uiFont, 12, 16, 500, 0.3),
    labelLarge: _style(uiFont, 14, 20, 600, 0.1),
    labelMedium: _style(uiFont, 12, 16, 600, 0.4),
    labelSmall: _style(uiFont, 11, 16, 600, 0.5),
  );

  static ThemeData _build(ColorScheme scheme, ConfidenceColors confidence) {
    final text = textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      fontFamily: uiFont,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: [confidence],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: text.labelLarge,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
      ),
      chipTheme: const ChipThemeData(shape: StadiumBorder()),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

/// Confidence colours for result states A / B / C (`tokens.json` conf*).
@immutable
class ConfidenceColors extends ThemeExtension<ConfidenceColors> {
  const new({
    required this.high,
    required this.highContainer,
    required this.onHighContainer,
    required this.possible,
    required this.possibleContainer,
    required this.onPossibleContainer,
    required this.notSure,
    required this.notSureContainer,
    required this.onNotSureContainer,
  });

  static const light = ConfidenceColors(
    high: Color(0xFF2F6B3A),
    highContainer: Color(0xFFD5EDD3),
    onHighContainer: Color(0xFF0F2E14),
    possible: Color(0xFF8A5A00),
    possibleContainer: Color(0xFFFBE7C2),
    onPossibleContainer: Color(0xFF2E1D00),
    notSure: Color(0xFFA23A2A),
    notSureContainer: Color(0xFFF9DCD5),
    onNotSureContainer: Color(0xFF3D0A03),
  );

  static const dark = ConfidenceColors(
    high: Color(0xFF8FD49A),
    highContainer: Color(0xFF1E4A26),
    onHighContainer: Color(0xFFD5EDD3),
    possible: Color(0xFFF2C46B),
    possibleContainer: Color(0xFF5A3D00),
    onPossibleContainer: Color(0xFFFBE7C2),
    notSure: Color(0xFFFFB4A6),
    notSureContainer: Color(0xFF7A2618),
    onNotSureContainer: Color(0xFFF9DCD5),
  );

  final Color high;
  final Color highContainer;
  final Color onHighContainer;
  final Color possible;
  final Color possibleContainer;
  final Color onPossibleContainer;
  final Color notSure;
  final Color notSureContainer;
  final Color onNotSureContainer;

  @override
  ConfidenceColors copyWith({
    Color? high,
    Color? highContainer,
    Color? onHighContainer,
    Color? possible,
    Color? possibleContainer,
    Color? onPossibleContainer,
    Color? notSure,
    Color? notSureContainer,
    Color? onNotSureContainer,
  }) => ConfidenceColors(
    high: high ?? this.high,
    highContainer: highContainer ?? this.highContainer,
    onHighContainer: onHighContainer ?? this.onHighContainer,
    possible: possible ?? this.possible,
    possibleContainer: possibleContainer ?? this.possibleContainer,
    onPossibleContainer: onPossibleContainer ?? this.onPossibleContainer,
    notSure: notSure ?? this.notSure,
    notSureContainer: notSureContainer ?? this.notSureContainer,
    onNotSureContainer: onNotSureContainer ?? this.onNotSureContainer,
  );

  @override
  ConfidenceColors lerp(ConfidenceColors? other, double t) {
    if (other == null) return this;
    return ConfidenceColors(
      high: Color.lerp(high, other.high, t)!,
      highContainer: Color.lerp(highContainer, other.highContainer, t)!,
      onHighContainer: Color.lerp(onHighContainer, other.onHighContainer, t)!,
      possible: Color.lerp(possible, other.possible, t)!,
      possibleContainer: Color.lerp(
        possibleContainer,
        other.possibleContainer,
        t,
      )!,
      onPossibleContainer: Color.lerp(
        onPossibleContainer,
        other.onPossibleContainer,
        t,
      )!,
      notSure: Color.lerp(notSure, other.notSure, t)!,
      notSureContainer: Color.lerp(
        notSureContainer,
        other.notSureContainer,
        t,
      )!,
      onNotSureContainer: Color.lerp(
        onNotSureContainer,
        other.onNotSureContainer,
        t,
      )!,
    );
  }
}
