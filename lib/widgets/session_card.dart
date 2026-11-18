import 'package:flutter/material.dart';

import '../models/class_session.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class SessionCard extends StatelessWidget {
  final ClassSession session;
  final int totalStudents;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  const SessionCard({
    super.key,
    required this.session,
    required this.totalStudents,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerLow,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Icon(
                session.isOpen ? Icons.lock_open : Icons.lock_outline,
                color:
                    session.isOpen ? AppTheme.presentColor : colorScheme.outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDateTime(session.createdAt),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${session.presentCount}/$totalStudents present',
                style: textTheme.labelMedium,
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}