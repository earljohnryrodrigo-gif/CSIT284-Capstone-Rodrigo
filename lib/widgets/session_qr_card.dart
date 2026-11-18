import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/attendance_models.dart';

class SessionQrCard extends StatelessWidget {
  final List<ClassSession> sessions;
  final ClassSession selectedSession;
  final ValueChanged<String?> onSessionChanged;
  final VoidCallback onToggleStatus;

  const SessionQrCard({
    super.key,
    required this.sessions,
    required this.selectedSession,
    required this.onSessionChanged,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Session: ',
                  
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedSession.id,
                    items: sessions.map((session) {
                      return DropdownMenuItem<String>(
                        value: session.id,
                        child: Text(
                          session.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: onSessionChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Chip(
              avatar: Icon(
                selectedSession.isActive
                    ? Icons.lock_open
                    : Icons.lock_outline,
                size: 18,
              ),
              label: Text(
                selectedSession.isActive ? 'Session Open' : 'Session Closed',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: selectedSession.id,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              selectedSession.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'ID: ${selectedSession.id}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onToggleStatus,
              icon: Icon(
                selectedSession.isActive ? Icons.stop_circle : Icons.play_arrow,
              ),
              label: Text(
                selectedSession.isActive ? 'Close Session' : 'Reopen Session',
              ),
            ),
          ],
        ),
      ),
    );
  }
}