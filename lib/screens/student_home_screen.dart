import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/check_in_result.dart';
import '../models/student.dart';
import '../services/attendance_service.dart';
import '../utils/app_constants.dart';
import '../widgets/status_banner.dart';
import '../widgets/student_id_field.dart';
import 'qr_scanner_screen.dart';
import 'teacher_login_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final AttendanceService service;

  const StudentHomeScreen({super.key, required this.service});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  static const String _savedIdKey = 'student_id';

  final TextEditingController _idController = TextEditingController();
  Student? _student;
  CheckInResult? _result;
  bool _isLookingUp = false;
  bool _isChecking = false;
  int _lookupToken = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedId();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedId() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_savedIdKey) ?? '';
    if (!mounted) return;
    _idController.text = saved;
    await _lookupStudent(saved);
  }

  Future<void> _lookupStudent(String rawId) async {
    final token = ++_lookupToken;
    final id = rawId.trim();

    if (id.isEmpty) {
      setState(() {
        _student = null;
        _isLookingUp = false;
      });
      return;
    }

    setState(() => _isLookingUp = true);
    final student = await widget.service.findStudent(id);

    if (!mounted || token != _lookupToken) return;
    setState(() {
      _student = student;
      _isLookingUp = false;
    });
  }

  Future<void> _scanAndCheckIn() async {
    final id = _idController.text.trim();

    if (_student == null) {
      setState(() {
        _result = const CheckInResult(
          status: CheckInStatus.invalidStudentId,
          title: 'Student ID Not Found',
          message:
              'Enter a valid Student ID from the class roster before scanning.',
        );
      });
      return;
    }

    final scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );

    if (!mounted || scannedValue == null) return;

    setState(() => _isChecking = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedIdKey, id);

    final result = await widget.service.checkIn(
      rawQrValue: scannedValue,
      studentId: id,
    );

    if (!mounted) return;
    setState(() {
      _result = result;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final student = _student;
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        title: const Text(kAppName),
        actions: [
          IconButton(
            tooltip: 'Teacher Mode',
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeacherLoginScreen(service: widget.service),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            elevation: 0,
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kClassName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter your Student ID, then scan the QR code shown by your teacher.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          StudentIdField(
            controller: _idController,
            onChanged: _lookupStudent,
            isValid: student != null,
          ),
          if (_isLookingUp) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
          if (student != null && !_isLookingUp)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 4),
              child: Text(
                'Welcome, ${student.fullName}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isChecking ? null : _scanAndCheckIn,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(
              _isChecking ? 'Checking in...' : 'Scan Class QR',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          if (_isChecking) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
          if (result != null && !_isChecking) ...[
            const SizedBox(height: 20),
            StatusBanner(
              title: result.title,
              message: result.message,
              isSuccess: result.isSuccess,
            ),
          ],
        ],
      ),
    );
  }
}