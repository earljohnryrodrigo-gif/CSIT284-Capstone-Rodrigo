import 'package:flutter/material.dart';

import '../models/class_session.dart';
import '../models/student.dart';
import '../services/attendance_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
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

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen>
    with SingleTickerProviderStateMixin {
  static const int _recordsTab = 1;

  late final TabController _tabController;
  late final Stream<List<ClassSession>> _sessionsStream;
  List<Student> _roster = const [];
  String? _selectedSessionId;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _sessionsStream = widget.service.watchSessions();
    _loadRoster();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRoster() async {
    final roster = await widget.service.getRoster();
    if (!mounted) return;
    setState(() => _roster = roster);
  }

  ClassSession? _currentSession(List<ClassSession> sessions) {
    if (sessions.isEmpty) return null;
    for (final session in sessions.reversed) {
      if (session.isOpen) return session;
    }
    return sessions.last;
  }

  ClassSession? _recordsSession(
    List<ClassSession> sessions,
    ClassSession? current,
  ) {
    for (final session in sessions) {
      if (session.id == _selectedSessionId) return session;
    }
    return current;
  }

  List<ClassSession> _historySessions(
    List<ClassSession> sessions,
    ClassSession? current,
  ) {
    return sessions
        .where((session) => session.id != current?.id)
        .toList()
        .reversed
        .toList();
  }

  int _presentCount(ClassSession session) {
    return _roster.where((student) => session.hasAttended(student.id)).length;
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
    _showMessage('Session created. Students can scan the QR code now.');
  }

  Future<void> _setOpen(ClassSession session, bool open) async {
    setState(() => _isBusy = true);
    await widget.service.setSessionOpen(session.id, open);
    if (!mounted) return;
    setState(() => _isBusy = false);

    _showMessage(
      open
          ? 'Session opened. Any other open session was closed.'
          : 'Session closed.',
    );
  }

  Future<void> _deleteSession(ClassSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.delete_outline,
          color: Theme.of(ctx).colorScheme.error,
        ),
        title: const Text('Delete session?'),
        content: Text(
          '"${session.title}" and its ${session.presentCount} attendance '
          'record(s) will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    await widget.service.deleteSession(session.id);
    if (!mounted) return;

    setState(() {
      if (_selectedSessionId == session.id) _selectedSessionId = null;
      _isBusy = false;
    });
    _showMessage('Session deleted.');
  }

  void _openRecords(ClassSession session) {
    setState(() => _selectedSessionId = session.id);
    _tabController.animateTo(_recordsTab);
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Current Session'),
            Tab(text: 'Attendance Records'),
            Tab(text: 'Session History'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isBusy) const LinearProgressIndicator(),
          Expanded(
            child: StreamBuilder<List<ClassSession>>(
              stream: _sessionsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load sessions:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final sessions = snapshot.data;
                if (sessions == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final current = _currentSession(sessions);

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCurrentTab(current),
                    _buildRecordsTab(sessions, current),
                    _buildHistoryTab(sessions, current),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab(ClassSession? current) {
    final textTheme = Theme.of(context).textTheme;

    if (current == null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('No sessions yet. Create one to generate a QR code.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isBusy ? null : _createSession,
            icon: const Icon(Icons.add),
            label: const Text('New Session'),
          ),
        ],
      );
    }

    final present = _presentCount(current);
    final absent = _roster.length - present;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          current.title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '$kClassName - ${formatDateTime(current.createdAt)}',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        QrDisplayCard(session: current),
        const SizedBox(height: 16),
        Row(
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
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: _isBusy ? null : () => _setOpen(current, !current.isOpen),
          icon: Icon(
            current.isOpen
                ? Icons.stop_circle_outlined
                : Icons.play_circle_outline,
          ),
          label: Text(current.isOpen ? 'Close Session' : 'Open Session'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isBusy ? null : _createSession,
          icon: const Icon(Icons.add),
          label: const Text('New Session'),
        ),
      ],
    );
  }

  Widget _buildRecordsTab(List<ClassSession> sessions, ClassSession? current) {
    final session = _recordsSession(sessions, current);

    if (session == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No sessions yet. Create one in the Current Session tab.',
          ),
        ),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final present = _presentCount(session);
    final absent = _roster.length - present;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Attendance - $kClassName',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('Session: ${session.title}', style: textTheme.bodyMedium),
        Text(
          'Date: ${formatDateTime(session.createdAt)}',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: session.id,
                isExpanded: true,
                items: [
                  for (final item in sessions.reversed)
                    DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(
                        "${item.title} (${item.isOpen ? 'Open' : 'Closed'})",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (id) {
                  if (id != null) setState(() => _selectedSessionId = id);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryChip(
                icon: Icons.groups_outlined,
                label: 'Total',
                value: '${_roster.length}',
                color: AppTheme.seedColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SummaryChip(
                icon: Icons.check_circle_outline,
                label: 'Present',
                value: '$present',
                color: AppTheme.presentColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SummaryChip(
                icon: Icons.person_off_outlined,
                label: 'Absent',
                value: '$absent',
                color: AppTheme.absentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < _roster.length; i++) ...[
                AttendanceListTile(
                  studentId: _roster[i].id,
                  studentName: _roster[i].fullName,
                  record: session.records[_roster[i].id],
                ),
                if (i < _roster.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(List<ClassSession> sessions, ClassSession? current) {
    final history = _historySessions(sessions, current);

    if (history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No previous sessions yet. Sessions you replace will appear here.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final session = history[index];
        return SessionCard(
          session: session,
          totalStudents: _roster.length,
          isSelected: session.id == _selectedSessionId,
          onTap: () => _openRecords(session),
          trailing: IconButton(
            tooltip: 'Delete session',
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            onPressed: _isBusy ? null : () => _deleteSession(session),
          ),
        );
      },
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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