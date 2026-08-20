import 'dart:math' as math;

/// Color utilities used by the design-token engine.
///
/// Operates on 8-digit ARGB hex strings (no leading `#`), e.g. `FF6200EE`.
class Argb {
  final int a;
  final int r;
  final int g;
  final int b;

  const Argb(this.a, this.r, this.g, this.b);

  factory Argb.parse(String hex) {
    var h = hex.trim().replaceFirst('#', '').toUpperCase();
    if (h.length == 6) h = 'FF$h';
    if (h.length != 8) {
      throw FormatException('Invalid color "$hex". Use #RRGGBB or #AARRGGBB.');
    }
    final value = int.parse(h, radix: 16);
    return Argb(
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    );
  }

  factory Argb.rgb(int r, int g, int b, [int a = 255]) => Argb(
        a.clamp(0, 255),
        r.clamp(0, 255),
        g.clamp(0, 255),
        b.clamp(0, 255),
      );

  static const Argb white = Argb(255, 255, 255, 255);
  static const Argb black = Argb(255, 0, 0, 0);

  int get value => (a << 24) | (r << 16) | (g << 8) | b;

  /// Dart `Color` literal argument, e.g. `0xFF6200EE`.
  String get dartLiteral => '0x$hex';

  String get hex {
    String two(int n) => n.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '${two(a)}${two(r)}${two(g)}${two(b)}';
  }

  /// Relative luminance (sRGB), 0–1.
  double get luminance {
    double lin(int c) {
      final s = c / 255.0;
      return s <= 0.03928
          ? s / 12.92
          : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
  }

  Argb withAlpha(int alpha) => Argb(alpha.clamp(0, 255), r, g, b);

  Argb get opaque => withAlpha(255);
}

class Hsl {
  final double h; // 0–360
  final double s; // 0–1
  final double l; // 0–1
  final int a;

  const Hsl(this.h, this.s, this.l, [this.a = 255]);

  factory Hsl.fromArgb(Argb c) {
    final r = c.r / 255.0;
    final g = c.g / 255.0;
    final b = c.b / 255.0;
    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final l = (max + min) / 2.0;
    if (max == min) return Hsl(0, 0, l, c.a);
    final d = max - min;
    final s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min);
    double h;
    if (max == r) {
      h = ((g - b) / d + (g < b ? 6 : 0)) / 6.0;
    } else if (max == g) {
      h = ((b - r) / d + 2) / 6.0;
    } else {
      h = ((r - g) / d + 4) / 6.0;
    }
    return Hsl(h * 360.0, s, l, c.a);
  }

  Argb toArgb() {
    double hue2rgb(double p, double q, double t) {
      var tt = t;
      if (tt < 0) tt += 1;
      if (tt > 1) tt -= 1;
      if (tt < 1 / 6) return p + (q - p) * 6 * tt;
      if (tt < 1 / 2) return q;
      if (tt < 2 / 3) return p + (q - p) * (2 / 3 - tt) * 6;
      return p;
    }

    final h = this.h / 360.0;
    final s = this.s.clamp(0.0, 1.0);
    final l = this.l.clamp(0.0, 1.0);
    if (s == 0) {
      final v = (l * 255).round();
      return Argb(a, v, v, v);
    }
    final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    final p = 2 * l - q;
    final r = (hue2rgb(p, q, h + 1 / 3) * 255).round();
    final g = (hue2rgb(p, q, h) * 255).round();
    final b = (hue2rgb(p, q, h - 1 / 3) * 255).round();
    return Argb(a, r, g, b);
  }

  Hsl copyWith({double? h, double? s, double? l, int? a}) =>
      Hsl(h ?? this.h, s ?? this.s, l ?? this.l, a ?? this.a);
}

class ColorMath {
  ColorMath._();

  static Argb mix(Argb a, Argb b, double t) {
    final tt = t.clamp(0.0, 1.0);
    return Argb(
      (a.a + (b.a - a.a) * tt).round(),
      (a.r + (b.r - a.r) * tt).round(),
      (a.g + (b.g - a.g) * tt).round(),
      (a.b + (b.b - a.b) * tt).round(),
    );
  }

  static Argb lighten(Argb c, double amount) {
    final hsl = Hsl.fromArgb(c);
    return hsl.copyWith(l: (hsl.l + amount).clamp(0.0, 1.0)).toArgb();
  }

  static Argb darken(Argb c, double amount) {
    final hsl = Hsl.fromArgb(c);
    return hsl.copyWith(l: (hsl.l - amount).clamp(0.0, 1.0)).toArgb();
  }

  static Argb saturate(Argb c, double amount) {
    final hsl = Hsl.fromArgb(c);
    return hsl.copyWith(s: (hsl.s + amount).clamp(0.0, 1.0)).toArgb();
  }

  static Argb desaturate(Argb c, double amount) {
    final hsl = Hsl.fromArgb(c);
    return hsl.copyWith(s: (hsl.s - amount).clamp(0.0, 1.0)).toArgb();
  }

  static Argb rotateHue(Argb c, double degrees) {
    final hsl = Hsl.fromArgb(c);
    var h = (hsl.h + degrees) % 360.0;
    if (h < 0) h += 360.0;
    return hsl.copyWith(h: h).toArgb();
  }

  static Argb withSaturation(Argb c, double s) {
    final hsl = Hsl.fromArgb(c);
    return hsl.copyWith(s: s.clamp(0.0, 1.0)).toArgb();
  }

  static Argb withLightness(Argb c, double l) {
    final hsl = Hsl.fromArgb(c);
    return hsl.copyWith(l: l.clamp(0.0, 1.0)).toArgb();
  }

  static double contrastRatio(Argb a, Argb b) {
    final l1 = a.luminance + 0.05;
    final l2 = b.luminance + 0.05;
    return l1 > l2 ? l1 / l2 : l2 / l1;
  }

  /// Black or white, whichever contrasts better against [background].
  static Argb contrastingForeground(Argb background, {double min = 4.5}) {
    final whiteRatio = contrastRatio(Argb.white, background);
    final blackRatio = contrastRatio(Argb.black, background);
    if (whiteRatio >= min || whiteRatio >= blackRatio) {
      return whiteRatio >= blackRatio ? Argb.white : Argb.black;
    }
    return blackRatio >= whiteRatio ? Argb.black : Argb.white;
  }

  /// Nudge [fg] toward black/white until contrast against [bg] is at least
  /// [min], or return a hard black/white fallback.
  static Argb ensureContrast(Argb fg, Argb bg, {double min = 4.5}) {
    if (contrastRatio(fg, bg) >= min) return fg;
    var candidate = fg;
    for (var i = 0; i < 8; i++) {
      candidate = bg.luminance > 0.5
          ? darken(candidate, 0.08)
          : lighten(candidate, 0.08);
      if (contrastRatio(candidate, bg) >= min) return candidate;
    }
    return contrastingForeground(bg, min: min);
  }

  static List<Argb> neutralScale({
    required Argb lightest,
    required Argb darkest,
  }) {
    return [
      for (var i = 0; i < 10; i++) mix(lightest, darkest, i / 9.0),
    ];
  }
}
