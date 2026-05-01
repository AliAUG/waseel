import 'package:flutter/material.dart';
import 'package:waseel/core/theme.dart';

/// Confirmation dialog before sign-out (returns `true` if user confirms).
Future<bool> showSignOutConfirmDialog(
  BuildContext context, {
  required String message,
  required String cancelLabel,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    useRootNavigator: true,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: scheme.surface,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
            height: 1.35,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: scheme.onSurface,
              backgroundColor: scheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.carRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
