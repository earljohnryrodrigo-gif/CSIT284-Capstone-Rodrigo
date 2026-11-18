import 'package:flutter/material.dart';

import '../models/class_session.dart';
import '../models/student.dart';
import '../services/attendance_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/attendance_list_tile.dart';
import '../widgets/qr_display_card.dart';
import '../widgets/session_card.dart';
import '../widgets/summary_chip.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final AttendanceService service;

  const TeacherDashboardScreen({super.key, required this.service});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  late final Stream<List<ClassSession>> _sessionsStream;
  List<Student> _roster = const [];
  String? _selectedSessionId;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _sessionsStream = widget.service.watchSessions();
    _loadRoster();
  }

  Future<void> _loadRoster() async {
    final roster = await widget.service.getRoster();
    if (!mounted) return;
    setState(() => _roster = roster);
  }

  ClassSession? _findSelected(List<ClassSession> sessions) {
    if (sessions.isEmpty) return null;
    for (final session in sessions) {
      if (session.id == _selectedSessionId) return session;
    }
    return sessions.last;
  }

  Future<void> _createSession() async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => const _NewSessionDialog(),
    );

    if (title == null || !mounted) return;

    setState(() => _isBusy = true);
    final session = await widget.service.createSession(title);
    if (!mounted) return;

    setState(() {
      _selectedSessionId = session.id;
      _isBusy = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session created. Students can scan the QR code now.'),
      ),
    );
  }

  Future<void> _toggleSession(ClassSession session) async {
    setState(() => _isBusy = true);
    await widget.service.setSessionOpen(session.id, !session.isOpen);
    if (!mounted) return;
    setState(() => _isBusy = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(session.isOpen ? 'Session closed.' : 'Session reopened.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Exit Teacher Mode',
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: StreamBuilder<List<ClassSession>>(
        stream: _sessionsStream,
        builder: (context, snapshot) {
          final sessions = snapshot.data;
          if (sessions == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final current = _findSelected(sessions);
          final openCount = sessions.where((s) => s.isOpen).length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_isBusy) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: SummaryChip(
                      icon: Icons.lock_open,
                      label: 'Open Sessions',
                      value: '$openCount',
                      color: AppTheme.presentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryChip(
                      icon: Icons.groups_outlined,
                      label: 'Students',
                      value: '${_roster.length}',
                      color: AppTheme.seedColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sessions',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _isBusy ? null : _createSession,
                    icon: const Icon(Icons.add),
                    label: const Text('New Session'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final session in sessions.reversed) ...[
                SessionCard(
                  session: session,
                  isSelected: session.id == current?.id,
                  onTap: () => setState(() => _selectedSessionId = session.id),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 12),
              if (current == null)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No sessions yet. Tap "New Session" to create a QR code.',
                    ),
                  ),
                )
              else ...[
                QrDisplayCard(session: current),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _isBusy ? null : () => _toggleSession(current),
                  icon: Icon(
                    current.isOpen
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_outline,
                  ),
                  label: Text(
                    current.isOpen ? 'Close Session' : 'Reopen Session',
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Attendance',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (_) {
                    final present =
                        _roster.where((s) => current.hasAttended(s.id)).length;
                    final absent = _roster.length - present;

                    return Row(
                      children: [
                        Expanded(
                          child: SummaryChip(
                            icon: Icons.check_circle_outline,
                            label: 'Present',
                            value: '$present',
                            color: AppTheme.presentColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryChip(
                            icon: Icons.person_off_outlined,
                            label: 'Absent',
                            value: '$absent',
                            color: AppTheme.absentColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final student in _roster)
                        AttendanceListTile(
                          studentId: student.id,
                          studentName: student.fullName,
                          record: current.records[student.id],
                        ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _NewSessionDialog extends StatefulWidget {
  const _NewSessionDialog();

  @override
  State<_NewSessionDialog> createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends State<_NewSessionDialog> {
  final TextEditingController _controller = TextEditingController(
    text: 'Lecture ${formatDateTime(DateTime.now())}',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Class Session'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Session Title',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Create'),
        ),
      ],
    );
  }
}