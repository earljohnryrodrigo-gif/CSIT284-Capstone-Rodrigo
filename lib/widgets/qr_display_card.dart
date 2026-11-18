import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/class_session.dart';
import '../utils/qr_payload.dart';

class QrDisplayCard extends StatelessWidget {
  final ClassSession session;

  const QrDisplayCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              session.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: QrPayload.encode(session.id),
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              session.isOpen ? 'Open for check-in' : 'Closed',
              style: textTheme.labelLarge?.copyWith(
                color: session.isOpen
                    ? const Color(0xFF2E7D32)
                    : colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Session ID: ${session.id}',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}