import 'package:srik_cli/models/enums.dart';

/// A full color palette. Values are hex strings without the leading #.
class DesignPalette {
  final String secondary;
  final String background;
  final String surface;
  final String error;
  final String success;
  final String warning;
  final String info;
  final String textPrimary;
  final String textSecondary;
  final String textDisabled;
  final String textOnPrimary;
  // Neutral scale 50..900
  final List<String> neutral;
  // Gradient end color (paired with the brand color as start)
  final String gradientEnd;

  const DesignPalette({
    required this.secondary,
    required this.background,
    required this.surface,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.neutral,
    required this.gradientEnd,
  });

  static DesignPalette forPreset(DesignPreset preset) {
    switch (preset) {
      case DesignPreset.material:
        return const DesignPalette(
          secondary: 'FF03DAC6',
          background: 'FFFAFAFA',
          surface: 'FFFFFFFF',
          error: 'FFB00020',
          success: 'FF388E3C',
          warning: 'FFF57C00',
          info: 'FF1976D2',
          textPrimary: 'FF212121',
          textSecondary: 'FF757575',
          textDisabled: 'FFBDBDBD',
          textOnPrimary: 'FFFFFFFF',
          neutral: [
            'FFFAFAFA',
            'FFF5F5F5',
            'FFEEEEEE',
            'FFE0E0E0',
            'FFBDBDBD',
            'FF9E9E9E',
            'FF757575',
            'FF616161',
            'FF424242',
            'FF212121',
          ],
          gradientEnd: 'FF03DAC6',
        );
      case DesignPreset.vibrant:
        return const DesignPalette(
          secondary: 'FFEC4899',
          background: 'FFFAFAFA',
          surface: 'FFFFFFFF',
          error: 'FFEF4444',
          success: 'FF10B981',
          warning: 'FFF59E0B',
          info: 'FF3B82F6',
          textPrimary: 'FF111827',
          textSecondary: 'FF6B7280',
          textDisabled: 'FFD1D5DB',
          textOnPrimary: 'FFFFFFFF',
          neutral: [
            'FFFAFAFA',
            'FFF5F5F5',
            'FFE5E5E5',
            'FFD4D4D4',
            'FFA3A3A3',
            'FF737373',
            'FF525252',
            'FF404040',
            'FF262626',
            'FF171717',
          ],
          gradientEnd: 'FFEC4899',
        );
      case DesignStyle.minimalism:
        return const DesignPalette(
          secondary: 'FF404040',
          background: 'FFFFFFFF',
          surface: 'FFFAFAFA',
          error: 'FF991B1B',
          success: 'FF166534',
          warning: 'FF92400E',
          info: 'FF1E3A8A',
          textPrimary: 'FF0A0A0A',
          textSecondary: 'FF525252',
          textDisabled: 'FFA3A3A3',
          textOnPrimary: 'FFFFFFFF',
          neutral: [
            'FFFAFAFA',
            'FFF5F5F5',
            'FFE5E5E5',
            'FFD4D4D4',
            'FFA3A3A3',
            'FF737373',
            'FF525252',
            'FF404040',
            'FF262626',
            'FF0A0A0A',
          ],
          gradientEnd: 'FF737373',
        );
      default:
        return DesignPalette.forPreset(DesignStyle.material);
    }
  }
}
