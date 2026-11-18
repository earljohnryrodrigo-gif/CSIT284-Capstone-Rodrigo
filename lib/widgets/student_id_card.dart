import 'package:flutter/material.dart';

import '../data/dummy_store.dart';

class StudentIdCard extends StatelessWidget {
  final TextEditingController controller;
  final String? matchedName;
  final VoidCallback onChanged;

  const StudentIdCard({
    super.key,
    required this.controller,
    required this.matchedName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final firstId = kStudentRoster.keys.first;
    final lastId = kStudentRoster.keys.last;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kClassName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                labelText: 'Student ID',
                hintText: 'e.g. $firstId',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  matchedName != null
                      ? Icons.verified_user_outlined
                      : Icons.info_outline,
                  size: 18,
                  color:
                      matchedName != null ? Colors.green : colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    matchedName != null
                        ? 'Student: $matchedName'
                        : 'Enter ID from roster ($firstId to $lastId)',
                    style: TextStyle(
                      color: matchedName != null
                          ? Colors.green.shade700
                          : colorScheme.onSurfaceVariant,
                      fontWeight: matchedName != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}