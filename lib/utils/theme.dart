import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff0f6681),
      surfaceTint: Color(0xff0f6681),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffbce9ff),
      onPrimaryContainer: Color(0xff001f29),
      secondary: Color(0xff026b5d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff9ff2e0),
      onSecondaryContainer: Color(0xff00201b),
      tertiary: Color(0xff0e6681),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffbbe9ff),
      onTertiaryContainer: Color(0xff001f29),
      error: Color(0xff904a43),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff3b0907),
      surface: Color(0xfff5fbf4),
      onSurface: Color(0xff171d19),
      onSurfaceVariant: Color(0xff424940),
      outline: Color(0xff72796f),
      outlineVariant: Color(0xffc2c9bd),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff8ad0ee),
      primaryFixed: Color(0xffbce9ff),
      onPrimaryFixed: Color(0xff001f29),
      primaryFixedDim: Color(0xff8ad0ee),
      onPrimaryFixedVariant: Color(0xff004d63),
      secondaryFixed: Color(0xff9ff2e0),
      onSecondaryFixed: Color(0xff00201b),
      secondaryFixedDim: Color(0xff83d5c4),
      onSecondaryFixedVariant: Color(0xff005046),
      tertiaryFixed: Color(0xffbbe9ff),
      onTertiaryFixed: Color(0xff001f29),
      tertiaryFixedDim: Color(0xff8ad0ee),
      onTertiaryFixedVariant: Color(0xff004d63),
      surfaceDim: Color(0xffd6dbd5),
      surfaceBright: Color(0xfff5fbf4),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f5ef),
      surfaceContainer: Color(0xffeaefe9),
      surfaceContainerHigh: Color(0xffe4eae3),
      surfaceContainerHighest: Color(0xffdee4de),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00495e),
      surfaceTint: Color(0xff0f6681),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff327d98),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff004c42),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff2b8273),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff00495d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff317d98),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff6e302a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffaa6058),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf4),
      onSurface: Color(0xff171d19),
      onSurfaceVariant: Color(0xff3e453c),
      outline: Color(0xff5a6158),
      outlineVariant: Color(0xff767d73),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff8ad0ee),
      primaryFixed: Color(0xff327d98),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff08647e),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff2b8273),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff00685b),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff317d98),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff07647e),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd6dbd5),
      surfaceBright: Color(0xfff5fbf4),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f5ef),
      surfaceContainer: Color(0xffeaefe9),
      surfaceContainerHigh: Color(0xffe4eae3),
      surfaceContainerHighest: Color(0xffdee4de),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff002632),
      surfaceTint: Color(0xff0f6681),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff00495e),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff002822),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff004c42),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff002632),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff00495d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff44100c),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff6e302a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf4),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff1f261e),
      outline: Color(0xff3e453c),
      outlineVariant: Color(0xff3e453c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xffd4f0ff),
      primaryFixed: Color(0xff00495e),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003140),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff004c42),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff00332c),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff00495d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003140),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd6dbd5),
      surfaceBright: Color(0xfff5fbf4),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f5ef),
      surfaceContainer: Color(0xffeaefe9),
      surfaceContainerHigh: Color(0xffe4eae3),
      surfaceContainerHighest: Color(0xffdee4de),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff8ad0ee),
      surfaceTint: Color(0xff8ad0ee),
      onPrimary: Color(0xff003545),
      primaryContainer: Color(0xff004d63),
      onPrimaryContainer: Color(0xffbce9ff),
      secondary: Color(0xff83d5c4),
      onSecondary: Color(0xff003730),
      secondaryContainer: Color(0xff005046),
      onSecondaryContainer: Color(0xff9ff2e0),
      tertiary: Color(0xff8ad0ee),
      onTertiary: Color(0xff003545),
      tertiaryContainer: Color(0xff004d63),
      onTertiaryContainer: Color(0xffbbe9ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff561e19),
      errorContainer: Color(0xff73332d),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0f1511),
      onSurface: Color(0xffdee4de),
      onSurfaceVariant: Color(0xffc2c9bd),
      outline: Color(0xff8c9388),
      outlineVariant: Color(0xff424940),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4de),
      inversePrimary: Color(0xff0f6681),
      primaryFixed: Color(0xffbce9ff),
      onPrimaryFixed: Color(0xff001f29),
      primaryFixedDim: Color(0xff8ad0ee),
      onPrimaryFixedVariant: Color(0xff004d63),
      secondaryFixed: Color(0xff9ff2e0),
      onSecondaryFixed: Color(0xff00201b),
      secondaryFixedDim: Color(0xff83d5c4),
      onSecondaryFixedVariant: Color(0xff005046),
      tertiaryFixed: Color(0xffbbe9ff),
      onTertiaryFixed: Color(0xff001f29),
      tertiaryFixedDim: Color(0xff8ad0ee),
      onTertiaryFixedVariant: Color(0xff004d63),
      surfaceDim: Color(0xff0f1511),
      surfaceBright: Color(0xff353b36),
      surfaceContainerLowest: Color(0xff0a0f0c),
      surfaceContainerLow: Color(0xff171d19),
      surfaceContainer: Color(0xff1b211d),
      surfaceContainerHigh: Color(0xff262b27),
      surfaceContainerHighest: Color(0xff303632),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff8ed4f3),
      surfaceTint: Color(0xff8ad0ee),
      onPrimary: Color(0xff001922),
      primaryContainer: Color(0xff5299b6),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xff88dac8),
      onSecondary: Color(0xff001a16),
      secondaryContainer: Color(0xff4c9e8f),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xff8ed4f2),
      onTertiary: Color(0xff001922),
      tertiaryContainer: Color(0xff529ab6),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab2),
      onError: Color(0xff330404),
      errorContainer: Color(0xffcc7b72),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1511),
      onSurface: Color(0xfff7fcf6),
      onSurfaceVariant: Color(0xffc6cdc1),
      outline: Color(0xff9ea59a),
      outlineVariant: Color(0xff7e857b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4de),
      inversePrimary: Color(0xff004e65),
      primaryFixed: Color(0xffbce9ff),
      onPrimaryFixed: Color(0xff00131b),
      primaryFixedDim: Color(0xff8ad0ee),
      onPrimaryFixedVariant: Color(0xff003b4d),
      secondaryFixed: Color(0xff9ff2e0),
      onSecondaryFixed: Color(0xff001511),
      secondaryFixedDim: Color(0xff83d5c4),
      onSecondaryFixedVariant: Color(0xff003e35),
      tertiaryFixed: Color(0xffbbe9ff),
      onTertiaryFixed: Color(0xff00131b),
      tertiaryFixedDim: Color(0xff8ad0ee),
      onTertiaryFixedVariant: Color(0xff003b4d),
      surfaceDim: Color(0xff0f1511),
      surfaceBright: Color(0xff353b36),
      surfaceContainerLowest: Color(0xff0a0f0c),
      surfaceContainerLow: Color(0xff171d19),
      surfaceContainer: Color(0xff1b211d),
      surfaceContainerHigh: Color(0xff262b27),
      surfaceContainerHighest: Color(0xff303632),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff6fbff),
      surfaceTint: Color(0xff8ad0ee),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff8ed4f3),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffecfff9),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff88dac8),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff6fbff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff8ed4f2),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab2),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1511),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfff6fdf1),
      outline: Color(0xffc6cdc1),
      outlineVariant: Color(0xffc6cdc1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4de),
      inversePrimary: Color(0xff002e3d),
      primaryFixed: Color(0xffc7edff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff8ed4f3),
      onPrimaryFixedVariant: Color(0xff001922),
      secondaryFixed: Color(0xffa4f6e4),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff88dac8),
      onSecondaryFixedVariant: Color(0xff001a16),
      tertiaryFixed: Color(0xffc6edff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff8ed4f2),
      onTertiaryFixedVariant: Color(0xff001922),
      surfaceDim: Color(0xff0f1511),
      surfaceBright: Color(0xff353b36),
      surfaceContainerLowest: Color(0xff0a0f0c),
      surfaceContainerLow: Color(0xff171d19),
      surfaceContainer: Color(0xff1b211d),
      surfaceContainerHigh: Color(0xff262b27),
      surfaceContainerHighest: Color(0xff303632),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
