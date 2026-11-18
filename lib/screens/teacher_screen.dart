import 'package:flutter/material.dart';

import '../data/dummy_store.dart' hide kStudentRoster;
import '../models/attendance_models.dart' hide dummyStore;
import '../widgets/attendance_list_tile.dart';
import '../widgets/session_qr_card.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  String? _selectedSessionId;

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _startNewSession() async {
    final labelController = TextEditingController(
      text: _defaultSessionLabel(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Class Session'),
        content: TextField(
          controller: labelController,
          decoration: const InputDecoration(
            labelText: 'Session Label',
            hintText: 'e.g. Nov 18 - Lecture',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create QR'),
          ),
        ],
      ),
    );

    final label = labelController.text.trim();
    labelController.dispose();

    if (confirmed != true) return;

    final created = dummyStore.createSession(label);
    setState(() {
      _selectedSessionId = created.id;
    });
  }

  String _defaultSessionLabel() {
    final now = DateTime.now();
    return 'Session ${_twoDigits(now.month)}/${_twoDigits(now.day)} ${_twoDigits(now.hour)}:${_twoDigits(now.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teacher Panel (Dummy)'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.qr_code_2), text: 'Session QR'),
              Tab(icon: Icon(Icons.people_outline), text: 'Attendance List'),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            final sessions = dummyStore.sessions;

            if (sessions.isNotEmpty &&
                (_selectedSessionId == null ||
                    !sessions.any((s) => s.id == _selectedSessionId))) {
              _selectedSessionId = sessions.first.id;
            }

            final selectedSession = sessions.isEmpty
                ? null
                : sessions.firstWhere((s) => s.id == _selectedSessionId);

            return TabBarView(
              children: [
                _buildQrTab(sessions, selectedSession),
                _buildAttendanceListTab(selectedSession),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQrTab(
    List<ClassSession> sessions,
    ClassSession? selectedSession,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: _startNewSession,
            icon: const Icon(Icons.add),
            label: const Text('Start New Session'),
          ),
          const SizedBox(height: 16),
          if (selectedSession == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No sessions yet.\nTap "Start New Session" to generate a QR code.',
                  
                ),
              ),
            )
          else
            SessionQrCard(
              sessions: sessions,
              selectedSession: selectedSession,
              onSessionChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSessionId = value);
                }
              },
              onToggleStatus: () =>
                  dummyStore.toggleSession(selectedSession.id),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceListTab(ClassSession? selectedSession) {
    if (selectedSession == null) {
      return const Center(child: Text('Create a session first.'));
    }

    final rosterEntries = kStudentRoster.entries.toList();
    final presentCount = rosterEntries
        .where((e) => selectedSession.records.containsKey(e.key))
        .length;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedSession.label,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Chip(
                label: Text(
                  'Present: $presentCount / ${rosterEntries.length}',
                  
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: rosterEntries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = rosterEntries[index];
              return AttendanceListTile(
                studentId: entry.key,
                studentName: entry.value,
                record: selectedSession.records[entry.key],
              );
            },
          ),
        ),
      ],
    );
  }
}