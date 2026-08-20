/// Reusable style-aware widgets. Source is identical for every visual style;
/// rendering is driven by tokens + [AppStyleConfig].
class ComponentTemplates {
  ComponentTemplates._();

  static String surface() => r'''
import 'dart:ui';

import 'package:flutter/material.dart';

import '../styles/design_style_config.dart';
import '../themes/app_theme_extensions.dart';
import '../tokens/app_blur.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_shadows.dart';
import '../tokens/app_spacing.dart';

enum AppSurfaceDepth { flat, raised, floating, pressed, inset }

class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.depth = AppSurfaceDepth.raised,
    this.radius,
    this.onTap,
    this.semanticLabel,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AppSurfaceDepth depth;
  final double? radius;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double? width;
  final double? height;

  static bool allowExpensiveEffects(BuildContext context) {
    final data = MediaQuery.maybeOf(context);
    if (data == null) return true;
    if (data.disableAnimations) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = Theme.of(context).extension<AppSurfaceTheme>();
    final radiusValue = radius ?? AppRadius.md;
    final borderRadius = BorderRadius.circular(radiusValue);
    final useBlur = AppStyleConfig.usesBlur &&
        allowExpensiveEffects(context) &&
        depth != AppSurfaceDepth.pressed &&
        depth != AppSurfaceDepth.flat;
    final sigma = depth == AppSurfaceDepth.floating
        ? AppBlur.large
        : AppBlur.medium;

    final decoration = _decoration(context, surfaces, borderRadius);

    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    Widget painted = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standardCurve,
      width: width,
      height: height,
      decoration: useBlur ? decoration.copyWith(color: Colors.transparent) : decoration,
      child: content,
    );

    if (useBlur) {
      painted = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: DecoratedBox(
            decoration: decoration,
            child: content,
          ),
        ),
      );
    }

    if (AppStyleConfig.usesLiquidHighlight) {
      painted = Stack(
        children: <Widget>[
          painted,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      (surfaces?.highlight ?? AppColors.highlight)
                          .withAlpha(140),
                      Colors.transparent,
                      (surfaces?.highlight ?? AppColors.highlight)
                          .withAlpha(30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (AppStyleConfig.usesSpatialDepth &&
        (depth == AppSurfaceDepth.floating ||
            depth == AppSurfaceDepth.raised)) {
      final scale = depth == AppSurfaceDepth.floating ? 1.02 : 1.0;
      painted = AnimatedScale(
        scale: scale,
        duration: AppMotion.normal,
        curve: AppMotion.entranceCurve,
        child: painted,
      );
    }

    if (onTap != null) {
      painted = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: painted,
        ),
      );
    }

    if (semanticLabel != null) {
      painted = Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: painted,
      );
    }

    if (margin != null) {
      painted = Padding(padding: margin!, child: painted);
    }

    return painted;
  }

  BoxDecoration _decoration(
    BuildContext context,
    AppSurfaceTheme? surfaces,
    BorderRadius borderRadius,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColorsDark.surface : AppColors.surface;
    final elevated =
        isDark ? AppColorsDark.surfaceElevated : AppColors.surfaceElevated;
    final translucent = surfaces?.surfaceTranslucent ??
        (isDark
            ? AppColorsDark.surfaceTranslucent
            : AppColors.surfaceTranslucent);
    final outline = isDark ? AppColorsDark.outline : AppColors.outline;

    Color color;
    switch (depth) {
      case AppSurfaceDepth.flat:
        color = surfaces?.background ??
            (isDark ? AppColorsDark.background : AppColors.background);
        break;
      case AppSurfaceDepth.floating:
        color = elevated;
        break;
      case AppSurfaceDepth.pressed:
      case AppSurfaceDepth.inset:
        color = isDark
            ? AppColorsDark.surfaceVariant
            : AppColors.surfaceVariant;
        break;
      case AppSurfaceDepth.raised:
        color = base;
        break;
    }

    if (AppStyleConfig.usesBlur &&
        allowExpensiveEffects(context) &&
        AppStyleConfig.reducedTransparencyFallback == false) {
      color = translucent;
    } else if (AppStyleConfig.usesBlur &&
        !allowExpensiveEffects(context)) {
      color = elevated;
    }

    Gradient? gradient;
    if (AppStyleConfig.usesSkeuoGradient) {
      gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color.lerp(color, Colors.white, 0.22)!,
          color,
          Color.lerp(color, Colors.black, 0.08)!,
        ],
      );
    }

    return BoxDecoration(
      color: gradient == null ? color : null,
      gradient: gradient,
      borderRadius: borderRadius,
      border: _border(outline),
      boxShadow: _shadows(),
    );
  }

  Border? _border(Color outline) {
    if (AppStyleConfig.usesHardOffsetShadow) {
      return Border.all(color: outline, width: 3);
    }
    if (AppStyleConfig.usesBlur || AppStyleConfig.usesLiquidHighlight) {
      return Border.all(
        color: AppColors.highlight.withAlpha(140),
        width: 1,
      );
    }
    if (AppStyleConfig.usesNeoShadows) {
      return null;
    }
    return Border.all(
      color: AppColors.outlineVariant,
      width: 1,
    );
  }

  List<BoxShadow> _shadows() {
    if (depth == AppSurfaceDepth.flat) return const <BoxShadow>[];
    if (AppStyleConfig.usesNeoShadows) {
      return depth == AppSurfaceDepth.pressed || depth == AppSurfaceDepth.inset
          ? AppShadows.neoInset
          : AppShadows.neoRaised;
    }
    if (AppStyleConfig.usesHardOffsetShadow) {
      return depth == AppSurfaceDepth.pressed
          ? const <BoxShadow>[]
          : AppShadows.hardOffset;
    }
    if (AppStyleConfig.usesClayInflation) {
      return AppShadows.clay;
    }
    switch (depth) {
      case AppSurfaceDepth.floating:
        return AppShadows.floating;
      case AppSurfaceDepth.raised:
        return AppShadows.medium;
      case AppSurfaceDepth.pressed:
      case AppSurfaceDepth.inset:
        return AppShadows.low;
      case AppSurfaceDepth.flat:
        return const <BoxShadow>[];
    }
  }
}
''';

  static String card() => r'''
import 'package:flutter/material.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import 'app_surface.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.depth = AppSurfaceDepth.raised,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AppSurfaceDepth depth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      margin: margin,
      depth: depth,
      radius: AppRadius.lg,
      semanticLabel: semanticLabel,
      child: child,
    );
  }
}
''';

  static String button() => r'''
import 'package:flutter/material.dart';

import '../styles/design_style_config.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_gradients.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_shadows.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

enum AppButtonVariant {
  primary,
  secondary,
  tertiary,
  outline,
  text,
  destructive,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final IconData? icon;
  final bool expanded;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final child = _content(context);
    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppSizes.minTapTarget,
          minWidth: AppSizes.minTapTarget,
        ),
        child: child,
      ),
    );
  }

  Widget _content(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = _background(isDark);
    final fg = _foreground(isDark);

    Widget body = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (loading)
          SizedBox(
            width: AppSizes.iconSm,
            height: AppSizes.iconSm,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fg,
            ),
          )
        else if (icon != null) ...<Widget>[
          Icon(icon, size: AppSizes.iconSm, color: fg),
          const SizedBox(width: AppSpacing.sm),
        ],
        if (!loading)
          Flexible(
            child: Text(
              label,
              style: AppTypography.button.copyWith(color: fg),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );

    body = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: body,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        AppStyleConfig.usesHardOffsetShadow ? AppRadius.none : AppRadius.md,
      ),
      side: variant == AppButtonVariant.outline ||
              AppStyleConfig.usesHardOffsetShadow
          ? BorderSide(
              color: variant == AppButtonVariant.destructive
                  ? AppColors.error
                  : (isDark ? AppColorsDark.outline : AppColors.outline),
              width: AppStyleConfig.usesHardOffsetShadow ? 3 : 1.5,
            )
          : BorderSide.none,
    );

    return AnimatedOpacity(
      duration: AppMotion.fast,
      opacity: _enabled ? 1 : 0.5,
      child: Material(
        color: AppStyleConfig.prefersGradientButtons &&
                variant == AppButtonVariant.primary
            ? Colors.transparent
            : bg,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          customBorder: shape,
          child: Ink(
            decoration: AppStyleConfig.prefersGradientButtons &&
                    variant == AppButtonVariant.primary
                ? BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: AppStyleConfig.usesClayInflation
                        ? AppShadows.clay
                        : AppStyleConfig.usesNeoShadows
                            ? AppShadows.neoRaised
                            : null,
                  )
                : BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(
                      AppStyleConfig.usesHardOffsetShadow
                          ? AppRadius.none
                          : AppRadius.md,
                    ),
                    boxShadow: _shadows(),
                  ),
            child: body,
          ),
        ),
      ),
    );
  }

  List<BoxShadow>? _shadows() {
    if (variant == AppButtonVariant.text ||
        variant == AppButtonVariant.tertiary) {
      return null;
    }
    if (AppStyleConfig.usesNeoShadows) {
      return AppShadows.neoRaised;
    }
    if (AppStyleConfig.usesHardOffsetShadow) {
      return AppShadows.hardOffset;
    }
    if (AppStyleConfig.usesClayInflation) {
      return AppShadows.clay;
    }
    return AppShadows.low;
  }

  Color _background(bool isDark) {
    switch (variant) {
      case AppButtonVariant.primary:
        return isDark ? AppColorsDark.primary : AppColors.primary;
      case AppButtonVariant.secondary:
        return isDark
            ? AppColorsDark.surfaceVariant
            : AppColors.surfaceVariant;
      case AppButtonVariant.tertiary:
      case AppButtonVariant.text:
      case AppButtonVariant.outline:
        return Colors.transparent;
      case AppButtonVariant.destructive:
        return isDark ? AppColorsDark.error : AppColors.error;
    }
  }

  Color _foreground(bool isDark) {
    switch (variant) {
      case AppButtonVariant.primary:
        return isDark ? AppColorsDark.onPrimary : AppColors.onPrimary;
      case AppButtonVariant.destructive:
        return isDark ? AppColorsDark.onPrimary : AppColors.onPrimary;
      case AppButtonVariant.secondary:
      case AppButtonVariant.tertiary:
      case AppButtonVariant.outline:
      case AppButtonVariant.text:
        return isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;
    }
  }
}
''';

  static String iconButton() => r'''
import 'package:flutter/material.dart';

import '../tokens/app_sizes.dart';
import 'app_surface.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final button = AppSurface(
      depth: AppSurfaceDepth.raised,
      padding: const EdgeInsets.all(12),
      onTap: onPressed,
      semanticLabel: semanticLabel ?? tooltip,
      child: Icon(icon, size: AppSizes.iconMd),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
''';

  static String textField() => r'''
import 'package:flutter/material.dart';

import '../styles/design_style_config.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import 'app_surface.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? prefix;
  final Widget? suffix;
  final String? errorText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const radius = AppStyleConfig.usesHardOffsetShadow
        ? AppRadius.none
        : AppRadius.md;

    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
        errorText: errorText,
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppSurface(
          depth: enabled ? AppSurfaceDepth.inset : AppSurfaceDepth.flat,
          radius: radius,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: field,
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: <Widget>[
              Icon(
                Icons.error_outline,
                size: 16,
                color: isDark ? AppColorsDark.error : AppColors.error,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  errorText!,
                  style: TextStyle(
                    color: isDark ? AppColorsDark.error : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
''';

  static String chip() => r'''
import 'package:flutter/material.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'app_surface.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      depth: selected ? AppSurfaceDepth.pressed : AppSurfaceDepth.raised,
      radius: AppRadius.pill,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      onTap: onTap,
      semanticLabel: label,
      child: Text(label, style: AppTypography.label),
    );
  }
}
''';

  static String badge() => r'''
import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_sizes.dart';
import '../tokens/app_typography.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.child,
    this.count,
    this.dot = false,
  });

  final Widget child;
  final int? count;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final show = dot || (count != null && count! > 0);
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        if (show)
          Positioned(
            right: -4,
            top: -4,
            child: Semantics(
              label: count == null ? 'Notification' : '$count notifications',
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: AppSizes.badgeSize,
                  minHeight: AppSizes.badgeSize,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColorsDark.error : AppColors.error,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                alignment: Alignment.center,
                child: dot
                    ? const SizedBox.shrink()
                    : Text(
                        count! > 99 ? '99+' : '$count',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onPrimary,
                          fontSize: 10,
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}
''';

  static String dialog() => r'''
import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'app_button.dart';
import 'app_surface.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.body,
    this.primaryLabel = 'OK',
    this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
  });

  final String title;
  final String body;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String body,
    String primaryLabel = 'OK',
    String? secondaryLabel,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AppDialog(
          title: title,
          body: body,
          primaryLabel: primaryLabel,
          secondaryLabel: secondaryLabel,
          onPrimary: () => Navigator.of(context).pop(),
          onSecondary: secondaryLabel == null
              ? null
              : () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: AppSurface(
        depth: AppSurfaceDepth.floating,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: AppTypography.headline),
            const SizedBox(height: AppSpacing.sm),
            Text(body, style: AppTypography.body),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              children: <Widget>[
                if (secondaryLabel != null)
                  AppButton(
                    label: secondaryLabel!,
                    variant: AppButtonVariant.text,
                    onPressed: onSecondary,
                  ),
                AppButton(
                  label: primaryLabel,
                  onPressed: onPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
''';

  static String bottomSheet() => r'''
import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import 'app_surface.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
  });

  final Widget child;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppBottomSheet(child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: AppSurface(
          depth: AppSurfaceDepth.floating,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}
''';

  static String navigationBar() => r'''
import 'package:flutter/material.dart';

import '../styles/design_style_config.dart';
import '../tokens/app_sizes.dart';
import 'app_surface.dart';

class AppNavigationDestination {
  const AppNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final String label;
  final IconData? selectedIcon;
}

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.floating = false,
  });

  final List<AppNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final bar = NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      height: AppSizes.navBarHeight,
      destinations: <Widget>[
        for (final AppNavigationDestination d in destinations)
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon ?? d.icon),
            label: d.label,
          ),
      ],
    );

    final useSurface = AppStyleConfig.usesBlur ||
        AppStyleConfig.usesSpatialDepth ||
        AppStyleConfig.usesNeoShadows ||
        floating;

    if (!useSurface) {
      return bar;
    }

    return AppSurface(
      depth: floating ? AppSurfaceDepth.floating : AppSurfaceDepth.raised,
      padding: EdgeInsets.zero,
      margin: floating
          ? const EdgeInsets.fromLTRB(16, 0, 16, 16)
          : EdgeInsets.zero,
      child: bar,
    );
  }
}
''';
}
