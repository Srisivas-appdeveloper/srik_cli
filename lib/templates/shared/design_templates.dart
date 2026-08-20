import 'package:srik_cli/design/token_builder.dart';
import 'package:srik_cli/models/project_config.dart';
import 'package:srik_cli/templates/shared/design/component_templates.dart';
import 'package:srik_cli/templates/shared/design/style_templates.dart';
import 'package:srik_cli/templates/shared/design/theme_templates.dart';
import 'package:srik_cli/templates/shared/design/token_templates.dart';

/// Generates the design-system files. These are identical regardless of
/// architecture — only the folder they land in differs.
class DesignTemplates {
  /// Nested design-system files, relative to the architecture design folder.
  static Map<String, String> allFiles(ProjectConfig c) {
    final tokens = DesignTokens.fromConfig(c);
    final recipe = tokens.recipe;

    final files = <String, String>{
      'tokens/app_colors.dart': TokenTemplates.colors(c, tokens),
      'tokens/app_spacing.dart': TokenTemplates.spacing(c, tokens),
      'tokens/app_radius.dart': TokenTemplates.radius(tokens),
      'tokens/app_typography.dart': TokenTemplates.typography(tokens),
      'tokens/app_shadows.dart': TokenTemplates.shadows(tokens),
      'tokens/app_blur.dart': TokenTemplates.blur(tokens),
      'tokens/app_borders.dart': TokenTemplates.borders(tokens),
      'tokens/app_opacity.dart': TokenTemplates.opacity(tokens),
      'tokens/app_gradients.dart': TokenTemplates.gradients(c, tokens),
      'tokens/app_elevation.dart': TokenTemplates.elevation(tokens),
      'tokens/app_motion.dart': TokenTemplates.motion(tokens),
      'tokens/app_sizes.dart': TokenTemplates.sizes(),
      'themes/app_theme_extensions.dart': ThemeTemplates.extensions(),
      'themes/app_component_theme.dart': ThemeTemplates.componentTheme(),
      'themes/app_theme.dart': ThemeTemplates.theme(useGradient: c.useGradient),
      'components/app_surface.dart': ComponentTemplates.surface(),
      'components/app_card.dart': ComponentTemplates.card(),
      'components/app_button.dart': ComponentTemplates.button(),
      'components/app_icon_button.dart': ComponentTemplates.iconButton(),
      'components/app_text_field.dart': ComponentTemplates.textField(),
      'components/app_chip.dart': ComponentTemplates.chip(),
      'components/app_badge.dart': ComponentTemplates.badge(),
      'components/app_dialog.dart': ComponentTemplates.dialog(),
      'components/app_bottom_sheet.dart': ComponentTemplates.bottomSheet(),
      'components/app_navigation_bar.dart': ComponentTemplates.navigationBar(),
      'styles/design_style.dart': StyleTemplates.designStyle(c),
      'styles/design_style_config.dart':
          StyleTemplates.designStyleConfig(c, recipe),
      'design_system.dart': _barrel,
      // Root re-exports so `srik add` can keep importing app_spacing.dart etc.
      'app_colors.dart': "export 'tokens/app_colors.dart';\n",
      'app_spacing.dart': "export 'tokens/app_spacing.dart';\n",
      'app_radius.dart': "export 'tokens/app_radius.dart';\n",
      'app_text_styles.dart': "export 'tokens/app_typography.dart';\n",
      'app_durations.dart': "export 'tokens/app_motion.dart';\n",
      'app_theme.dart': "export 'themes/app_theme.dart';\n",
      'app_gradients.dart': "export 'tokens/app_gradients.dart';\n",
    };
    return files;
  }

  /// Compatibility shims written to the v0.3 token folder
  /// (`core/constants`, `shared/theme`, or `theme`).
  static Map<String, String> legacyShims(ProjectConfig c) {
    const prefix = '../design/';
    final files = <String, String>{
      'app_colors.dart': "export '${prefix}tokens/app_colors.dart';\n",
      'app_spacing.dart': "export '${prefix}tokens/app_spacing.dart';\n",
      'app_radius.dart': "export '${prefix}tokens/app_radius.dart';\n",
      'app_text_styles.dart': "export '${prefix}tokens/app_typography.dart';\n",
      'app_durations.dart': "export '${prefix}tokens/app_motion.dart';\n",
      'app_theme.dart': "export '${prefix}themes/app_theme.dart';\n",
    };
    if (c.useGradient) {
      files['app_gradients.dart'] =
          "export '${prefix}tokens/app_gradients.dart';\n";
    }
    return files;
  }

  /// Legacy helpers kept so existing unit tests that call these methods
  /// continue to compile. Prefer [allFiles].
  static String colors(ProjectConfig c) =>
      TokenTemplates.colors(c, DesignTokens.fromConfig(c));

  static String spacing(ProjectConfig c) =>
      TokenTemplates.spacing(c, DesignTokens.fromConfig(c));

  static String radius(ProjectConfig c) =>
      TokenTemplates.radius(DesignTokens.fromConfig(c));

  static String textStyles(ProjectConfig c) =>
      TokenTemplates.typography(DesignTokens.fromConfig(c));

  static String durations(ProjectConfig c) =>
      TokenTemplates.motion(DesignTokens.fromConfig(c));

  static String gradients(ProjectConfig c) =>
      TokenTemplates.gradients(c, DesignTokens.fromConfig(c));

  static String theme(ProjectConfig c) =>
      ThemeTemplates.theme(useGradient: c.useGradient);

  static const String _barrel = '''
export 'tokens/app_colors.dart';
export 'tokens/app_spacing.dart';
export 'tokens/app_radius.dart';
export 'tokens/app_typography.dart';
export 'tokens/app_shadows.dart';
export 'tokens/app_blur.dart';
export 'tokens/app_borders.dart';
export 'tokens/app_opacity.dart';
export 'tokens/app_gradients.dart';
export 'tokens/app_elevation.dart';
export 'tokens/app_motion.dart';
export 'tokens/app_sizes.dart';
export 'themes/app_theme.dart';
export 'themes/app_theme_extensions.dart';
export 'themes/app_component_theme.dart';
export 'styles/design_style.dart';
export 'styles/design_style_config.dart';
export 'components/app_surface.dart';
export 'components/app_card.dart';
export 'components/app_button.dart';
export 'components/app_icon_button.dart';
export 'components/app_text_field.dart';
export 'components/app_chip.dart';
export 'components/app_badge.dart';
export 'components/app_dialog.dart';
export 'components/app_bottom_sheet.dart';
export 'components/app_navigation_bar.dart';
''';
}
