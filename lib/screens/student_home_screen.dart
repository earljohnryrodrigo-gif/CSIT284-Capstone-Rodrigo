import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dummy_store.dart';
import '../widgets/student_id_card.dart';
import 'qr_scanner_screen.dart';
import 'teacher_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final TextEditingController _idController = TextEditingController();
  String? _lastStatusMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedStudentId();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('student_id') ?? '';
    if (!mounted) return;
    setState(() {
      _idController.text = savedId;
    });
  }

  Future<void> _saveStudentId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_id', id.trim());
  }

  Future<void> _openScanner({bool simulate = false}) async {
    final studentId = _idController.text.trim();
    final studentName = kStudentRoster[studentId];

    if (studentName == null) {
      _showResultDialog(
        title: 'Invalid Student ID',
        message:
            'Please enter a valid Student ID from $kClassName (e.g., 2024-002).',
        isError: true,
      );
      return;
    }

    await _saveStudentId(studentId);
    if (!mounted) return;

    String? scannedCode;
    if (simulate) {
      scannedCode = dummyStore.sessions.isNotEmpty
          ? dummyStore.sessions.first.id
          : null;
    } else {
      scannedCode = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const QrScannerScreen()),
      );
    }

    if (scannedCode == null || scannedCode.trim().isEmpty) return;

    final result = dummyStore.markAttendance(
      sessionId: scannedCode.trim(),
      studentId: studentId,
      studentName: studentName,
    );

    if (!result.isError) {
      setState(() {
        _lastStatusMessage = result.message.replaceAll('\n', ' - ');
      });
    }

    if (!mounted) return;
    _showResultDialog(
      title: result.title,
      message: result.message,
      isError: result.isError,
    );
  }

  void _showResultDialog({
    required String title,
    required String message,
    required bool isError,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: isError ? Theme.of(ctx).colorScheme.error : Colors.green,
          size: 40,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _promptTeacherPin() async {
    final pinController = TextEditingController();
    final granted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Teacher Mode'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Enter Teacher PIN',
            hintText: 'Default: 1234',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx, pinController.text.trim() == kTeacherPin);
            },
            child: const Text('Enter'),
          ),
        ],
      ),
    );

    pinController.dispose();

    if (!mounted) return;
    if (granted == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TeacherScreen()),
      );
    } else if (granted == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final matchedName = kStudentRoster[_idController.text.trim()];

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _promptTeacherPin,
          child: const Text('Attendance Checker'),
        ),
        actions: [
          IconButton(
            tooltip: 'Teacher Mode (PIN: $kTeacherPin)',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: _promptTeacherPin,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StudentIdCard(
              controller: _idController,
              matchedName: matchedName,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _openScanner(simulate: false),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              icon: const Icon(Icons.qr_code_scanner, size: 28),
              label: const Text(
                'Scan Class QR',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _openScanner(simulate: true),
              icon: const Icon(Icons.bug_report_outlined),
              label: const Text('Demo: Simulate QR Scan'),
            ),
            if (_lastStatusMessage != null) ...[
              const SizedBox(height: 16),
              Card(
                color: colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(_lastStatusMessage!),
                ),
              ),
            ],
            const Spacer(),
            Text(
              'Dummy Data Mode (No Firebase yet).\nTap top-right icon for Teacher Mode (PIN: $kTeacherPin).',
              //textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}