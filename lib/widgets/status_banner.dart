import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusBanner extends StatelessWidget {
  final String title;
  final String message;
  final bool isSuccess;

  const StatusBanner({
    super.key,
    required this.title,
    required this.message,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final background = isSuccess
        ? AppTheme.presentColor.withValues(alpha: 0.12)
        : colorScheme.errorContainer;
    final foreground =
        isSuccess ? AppTheme.presentColor : colorScheme.onErrorContainer;

    return Card(
      color: background,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: foreground,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: foreground,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}