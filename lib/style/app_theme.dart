import "package:flutter/material.dart";

class AppTheme {
  final TextTheme textTheme;
  const AppTheme({
    this.textTheme = const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    ),
  });

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xffbe0003),
      surfaceTint: Color(0xffc00003),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffe62117),
      onPrimaryContainer: Color(0xfffffeff),
      secondary: Color(0xffac3326),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfffd6e5b),
      onSecondaryContainer: Color(0xff6d0101),
      tertiary: Color(0xff825300),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffa36900),
      onTertiaryContainer: Color(0xfffffdff),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff291714),
      onSurfaceVariant: Color(0xff5e3f3b),
      outline: Color(0xff926e69),
      outlineVariant: Color(0xffe7bdb6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff402b28),
      inversePrimary: Color(0xffffb4a8),
      primaryFixed: Color(0xffffdad5),
      onPrimaryFixed: Color(0xff410000),
      primaryFixedDim: Color(0xffffb4a8),
      onPrimaryFixedVariant: Color(0xff930002),
      secondaryFixed: Color(0xffffdad5),
      onSecondaryFixed: Color(0xff410000),
      secondaryFixedDim: Color(0xffffb4a8),
      onSecondaryFixedVariant: Color(0xff8b1a11),
      tertiaryFixed: Color(0xffffddb6),
      onTertiaryFixed: Color(0xff2a1800),
      tertiaryFixedDim: Color(0xffffb959),
      onTertiaryFixedVariant: Color(0xff643f00),
      surfaceDim: Color(0xfff4d2cd),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ee),
      surfaceContainer: Color(0xffffe9e6),
      surfaceContainerHigh: Color(0xffffe2dd),
      surfaceContainerHighest: Color(0xfffddbd5),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff740001),
      surfaceTint: Color(0xffc00003),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd9140e),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff720503),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffc04133),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff4e3000),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff986100),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff1d0d0a),
      onSurfaceVariant: Color(0xff4b2f2b),
      outline: Color(0xff6a4b46),
      outlineVariant: Color(0xff87655f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff402b28),
      inversePrimary: Color(0xffffb4a8),
      primaryFixed: Color(0xffd9140e),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xffae0002),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffc04133),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff9f291d),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff986100),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff774b00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffe0bfba),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff0ee),
      surfaceContainer: Color(0xffffe2dd),
      surfaceContainerHigh: Color(0xfff7d5d0),
      surfaceContainerHighest: Color(0xffeccac5),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff610001),
      surfaceTint: Color(0xffc00003),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff980002),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff610001),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff8e1d13),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff402700),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff674100),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff402521),
      outlineVariant: Color(0xff60413d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff402b28),
      inversePrimary: Color(0xffffb4a8),
      primaryFixed: Color(0xff980002),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff6d0001),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff8e1d13),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff6d0101),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff674100),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff492d00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd2b2ad),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffffedea),
      surfaceContainer: Color(0xfffddbd5),
      surfaceContainerHigh: Color(0xffefcdc8),
      surfaceContainerHighest: Color(0xffe0bfba),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb4a8),
      surfaceTint: Color(0xffffb4a8),
      onPrimary: Color(0xff690001),
      primaryContainer: Color(0xffe62117),
      onPrimaryContainer: Color(0xfffffeff),
      secondary: Color(0xffffb4a8),
      onSecondary: Color(0xff690001),
      secondaryContainer: Color(0xff8b1a11),
      onSecondaryContainer: Color(0xffff9a8b),
      tertiary: Color(0xffffb959),
      onTertiary: Color(0xff462a00),
      tertiaryContainer: Color(0xffa36900),
      onTertiaryContainer: Color(0xfffffdff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff200f0c),
      onSurface: Color(0xfffddbd5),
      onSurfaceVariant: Color(0xffe7bdb6),
      outline: Color(0xffae8882),
      outlineVariant: Color(0xff5e3f3b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfffddbd5),
      inversePrimary: Color(0xffc00003),
      primaryFixed: Color(0xffffdad5),
      onPrimaryFixed: Color(0xff410000),
      primaryFixedDim: Color(0xffffb4a8),
      onPrimaryFixedVariant: Color(0xff930002),
      secondaryFixed: Color(0xffffdad5),
      onSecondaryFixed: Color(0xff410000),
      secondaryFixedDim: Color(0xffffb4a8),
      onSecondaryFixedVariant: Color(0xff8b1a11),
      tertiaryFixed: Color(0xffffddb6),
      onTertiaryFixed: Color(0xff2a1800),
      tertiaryFixedDim: Color(0xffffb959),
      onTertiaryFixedVariant: Color(0xff643f00),
      surfaceDim: Color(0xff200f0c),
      surfaceBright: Color(0xff4a3430),
      surfaceContainerLowest: Color(0xff1a0a08),
      surfaceContainerLow: Color(0xff291714),
      surfaceContainer: Color(0xff2e1b18),
      surfaceContainerHigh: Color(0xff392522),
      surfaceContainerHighest: Color(0xff452f2c),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd2cb),
      surfaceTint: Color(0xffffb4a8),
      onPrimary: Color(0xff540000),
      primaryContainer: Color(0xffff5542),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffd2cb),
      onSecondary: Color(0xff540000),
      secondaryContainer: Color(0xfff06452),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd5a4),
      onTertiary: Color(0xff372100),
      tertiaryContainer: Color(0xffc38423),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff200f0c),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffd2cb),
      outline: Color(0xffd2a8a2),
      outlineVariant: Color(0xffae8781),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfffddbd5),
      inversePrimary: Color(0xff960002),
      primaryFixed: Color(0xffffdad5),
      onPrimaryFixed: Color(0xff2d0000),
      primaryFixedDim: Color(0xffffb4a8),
      onPrimaryFixedVariant: Color(0xff740001),
      secondaryFixed: Color(0xffffdad5),
      onSecondaryFixed: Color(0xff2d0000),
      secondaryFixedDim: Color(0xffffb4a8),
      onSecondaryFixedVariant: Color(0xff720503),
      tertiaryFixed: Color(0xffffddb6),
      onTertiaryFixed: Color(0xff1c0e00),
      tertiaryFixedDim: Color(0xffffb959),
      onTertiaryFixedVariant: Color(0xff4e3000),
      surfaceDim: Color(0xff200f0c),
      surfaceBright: Color(0xff563f3b),
      surfaceContainerLowest: Color(0xff110403),
      surfaceContainerLow: Color(0xff2b1916),
      surfaceContainer: Color(0xff372320),
      surfaceContainerHigh: Color(0xff422d2a),
      surfaceContainerHighest: Color(0xff4f3835),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffece9),
      surfaceTint: Color(0xffffb4a8),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffaea2),
      onPrimaryContainer: Color(0xff220000),
      secondary: Color(0xffffece9),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffaea2),
      onSecondaryContainer: Color(0xff220000),
      tertiary: Color(0xffffeddb),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xfffcb551),
      onTertiaryContainer: Color(0xff140900),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff200f0c),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffece9),
      outlineVariant: Color(0xffe3b9b2),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfffddbd5),
      inversePrimary: Color(0xff960002),
      primaryFixed: Color(0xffffdad5),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb4a8),
      onPrimaryFixedVariant: Color(0xff2d0000),
      secondaryFixed: Color(0xffffdad5),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffb4a8),
      onSecondaryFixedVariant: Color(0xff2d0000),
      tertiaryFixed: Color(0xffffddb6),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffffb959),
      onTertiaryFixedVariant: Color(0xff1c0e00),
      surfaceDim: Color(0xff200f0c),
      surfaceBright: Color(0xff624a47),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff2e1b18),
      surfaceContainer: Color(0xff402b28),
      surfaceContainerHigh: Color(0xff4c3633),
      surfaceContainerHighest: Color(0xff58413e),
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
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );

  /// YiYellow
  static const yiYellow = ExtendedColor(
    seed: Color(0xffffd700),
    value: Color(0xffffd700),
    light: ColorFamily(
      color: Color(0xff705d00),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffd700),
      onColorContainer: Color(0xff705e00),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff705d00),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffd700),
      onColorContainer: Color(0xff705e00),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff705d00),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffffd700),
      onColorContainer: Color(0xff705e00),
    ),
    dark: ColorFamily(
      color: Color(0xfffff6df),
      onColor: Color(0xff3a3000),
      colorContainer: Color(0xffffd700),
      onColorContainer: Color(0xff705e00),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xfffff6df),
      onColor: Color(0xff3a3000),
      colorContainer: Color(0xffffd700),
      onColorContainer: Color(0xff705e00),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xfffff6df),
      onColor: Color(0xff3a3000),
      colorContainer: Color(0xffffd700),
      onColorContainer: Color(0xff705e00),
    ),
  );

  List<ExtendedColor> get extendedColors => [yiYellow];
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
