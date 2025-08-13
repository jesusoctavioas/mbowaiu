import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import '../../shared/theme/theme_extensions.dart';

/// Service for platform-specific features and polish
class PlatformService {
  /// Check if running on iOS
  static bool get isIOS => Platform.isIOS;

  /// Check if running on Android
  static bool get isAndroid => Platform.isAndroid;

  /// Provide haptic feedback appropriate for the action
  static void hapticFeedback({HapticType type = HapticType.light}) {
    if (isIOS) {
      _iOSHapticFeedback(type);
    } else if (isAndroid) {
      _androidHapticFeedback(type);
    }
  }

  /// Provide haptic feedback respecting user preferences
  static void hapticFeedbackWithSettings({
    HapticType type = HapticType.light,
    required bool hapticEnabled,
  }) {
    if (hapticEnabled) {
      hapticFeedback(type: type);
    }
  }

  /// iOS-specific haptic feedback
  static void _iOSHapticFeedback(HapticType type) {
    switch (type) {
      case HapticType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticType.success:
        // iOS has specific success haptics in newer versions
        HapticFeedback.lightImpact();
        break;
      case HapticType.warning:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.error:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  /// Android-specific haptic feedback
  static void _androidHapticFeedback(HapticType type) {
    switch (type) {
      case HapticType.light:
      case HapticType.selection:
        HapticFeedback.lightImpact();
        break;
      case HapticType.medium:
      case HapticType.success:
        HapticFeedback.mediumImpact();
        break;
      case HapticType.heavy:
      case HapticType.warning:
      case HapticType.error:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  /// Get platform-appropriate button style
  static ButtonStyle getPlatformButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    bool isDestructive = false,
  }) {
    // Return Material button style for both platforms since ButtonStyle is a Material concept
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
      elevation: isDestructive ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
    );
  }

  /// Get platform-appropriate card elevation
  static double getPlatformCardElevation({bool isRaised = false}) {
    if (isIOS) {
      return 0; // iOS prefers flat design
    } else {
      return isRaised ? 4.0 : 1.0; // Android Material elevation
    }
  }

  /// Get platform-appropriate border radius
  static BorderRadius getPlatformBorderRadius({double radius = 12}) {
    if (isIOS) {
      return BorderRadius.circular(
        radius + 2,
      ); // iOS prefers slightly more rounded
    } else {
      return BorderRadius.circular(radius); // Android standard
    }
  }

  /// Create platform-appropriate navigation transition
  static Route<T> createPlatformRoute<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    if (isIOS) {
      return CupertinoPageRoute<T>(
        builder: (context) => page,
        settings: settings,
      );
    } else {
      return MaterialPageRoute<T>(
        builder: (context) => page,
        settings: settings,
      );
    }
  }

  /// Show platform-appropriate action sheet
  static Future<T?> showPlatformActionSheet<T>({
    required BuildContext context,
    required String title,
    List<PlatformActionSheetAction>? actions,
    PlatformActionSheetAction? cancelAction,
  }) {
    if (isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text(title),
          actions: actions
              ?.map(
                (action) => CupertinoActionSheetAction(
                  onPressed: action.onPressed,
                  isDestructiveAction: action.isDestructive,
                  child: Text(action.title),
                ),
              )
              .toList(),
          cancelButton: cancelAction != null
              ? CupertinoActionSheetAction(
                  onPressed: cancelAction.onPressed,
                  child: Text(cancelAction.title),
                )
              : null,
        ),
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            ...actions?.map(
                  (action) => ListTile(
                    title: Text(
                      action.title,
                      style: TextStyle(
                        color: action.isDestructive
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                    onTap: action.onPressed,
                  ),
                ) ??
                [],
            if (cancelAction != null)
              ListTile(
                title: Text(cancelAction.title),
                onTap: cancelAction.onPressed,
              ),
          ],
        ),
      );
    }
  }

  /// Show platform-appropriate alert dialog
  static Future<bool?> showPlatformAlert({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'OK',
    String? cancelText,
    bool isDestructive = false,
  }) {
    if (isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            if (cancelText != null)
              CupertinoDialogAction(
                child: Text(cancelText),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              child: Text(confirmText),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.conduitTheme.surfaceBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.dialog),
          ),
          title: Text(
            title,
            style: TextStyle(color: context.conduitTheme.textPrimary),
          ),
          content: Text(
            content,
            style: TextStyle(color: context.conduitTheme.textSecondary),
          ),
          actions: [
            if (cancelText != null)
              TextButton(
                child: Text(
                  cancelText,
                  style: TextStyle(color: context.conduitTheme.textSecondary),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: isDestructive
                    ? context.conduitTheme.error
                    : context.conduitTheme.buttonPrimary,
              ),
              child: Text(confirmText),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    }
  }

  /// Get platform-appropriate loading indicator
  static Widget getPlatformLoadingIndicator({double size = 20, Color? color}) {
    if (isIOS) {
      return SizedBox(
        width: size,
        height: size,
        child: CupertinoActivityIndicator(color: color),
      );
    } else {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: color != null
              ? AlwaysStoppedAnimation<Color>(color)
              : null,
        ),
      );
    }
  }

  /// Get platform-appropriate switch widget
  static Widget getPlatformSwitch({
    required bool value,
    required ValueChanged<bool>? onChanged,
    Color? activeColor,
  }) {
    if (isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: activeColor,
      );
    } else {
      return Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      );
    }
  }

  /// Apply platform-specific status bar styling
  static void setPlatformStatusBarStyle({
    bool isDarkContent = false,
    Color? backgroundColor,
  }) {
    if (isIOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: isDarkContent
              ? Brightness.light
              : Brightness.dark,
          statusBarIconBrightness: isDarkContent
              ? Brightness.dark
              : Brightness.light,
          statusBarColor: backgroundColor,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: backgroundColor ?? Colors.transparent,
          statusBarIconBrightness: isDarkContent
              ? Brightness.dark
              : Brightness.light,
          systemNavigationBarColor: backgroundColor,
          systemNavigationBarIconBrightness: isDarkContent
              ? Brightness.dark
              : Brightness.light,
        ),
      );
    }
  }

  /// Check if device supports dynamic colors (Android 12+)
  static bool supportsDynamicColors() {
    // This would require platform channel implementation
    // For now, return false
    return false;
  }

  /// Get platform-appropriate text selection controls
  static TextSelectionControls getPlatformTextSelectionControls() {
    if (isIOS) {
      return cupertinoTextSelectionControls;
    } else {
      return materialTextSelectionControls;
    }
  }

  /// Create platform-specific app bar
  static PreferredSizeWidget createPlatformAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = false,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    if (isIOS) {
      return CupertinoNavigationBar(
        middle: Text(title),
        trailing: actions != null && actions.isNotEmpty
            ? Row(mainAxisSize: MainAxisSize.min, children: actions)
            : null,
        leading: leading,
        backgroundColor: backgroundColor,
      );
    } else {
      return AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        centerTitle: centerTitle,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      );
    }
  }
}

/// Types of haptic feedback
enum HapticType { light, medium, heavy, selection, success, warning, error }

/// Action sheet action configuration
class PlatformActionSheetAction {
  final String title;
  final VoidCallback onPressed;
  final bool isDestructive;

  const PlatformActionSheetAction({
    required this.title,
    required this.onPressed,
    this.isDestructive = false,
  });
}
