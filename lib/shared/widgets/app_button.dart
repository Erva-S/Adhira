import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Primary button widget with multiple variants.
enum AppButtonVariant { primary, secondary, outline, text, danger }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final height = _getHeight();
    final textStyle = _getTextStyle();
    final colors = _getColors();

    Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.$2,
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _getIconSize(), color: colors.$2),
                const SizedBox(width: 8),
              ],
              Text(label, style: textStyle.copyWith(color: colors.$2)),
            ],
          );

    if (variant == AppButtonVariant.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      );
    }

    if (variant == AppButtonVariant.outline) {
      return SizedBox(
        height: height,
        width: isFullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.$1, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.$1,
          foregroundColor: colors.$2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small: return AppSpacing.buttonHeightSmall;
      case AppButtonSize.medium: return AppSpacing.buttonHeight;
      case AppButtonSize.large: return 56;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small: return 16;
      case AppButtonSize.medium: return 20;
      case AppButtonSize.large: return 24;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
      case AppButtonSize.medium:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case AppButtonSize.large:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }

  (Color, Color) _getColors() {
    switch (variant) {
      case AppButtonVariant.primary:
        return (AppColors.primary, AppColors.textOnPrimary);
      case AppButtonVariant.secondary:
        return (AppColors.accent, AppColors.textOnAccent);
      case AppButtonVariant.outline:
        return (AppColors.primary, AppColors.primary);
      case AppButtonVariant.text:
        return (Colors.transparent, AppColors.primary);
      case AppButtonVariant.danger:
        return (AppColors.error, AppColors.textOnPrimary);
    }
  }
}
