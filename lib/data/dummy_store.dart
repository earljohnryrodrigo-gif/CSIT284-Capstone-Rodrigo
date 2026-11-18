import 'package:flutter/foundation.dart';

import '../models/attendance_models.dart';

const String kClassName = 'BSCS 3A - Mobile Development';
const String kTeacherPin = '1234';

const Map<String, String> kStudentRoster = {
  '2024-001': 'Juan Dela Cruz',
  '2024-002': 'Maria Clara Santos',
  '2024-003': 'Jose Rizal Mendoza',
  '2024-004': 'Ana Mae Reyes',
  '2024-005': 'Carlo Bautista',
  '2024-006': 'Sofia Garcia',
  '2024-007': 'Miguel Torres',
  '2024-008': 'Bianca Villanueva',
  '2024-009': 'Rafael Aquino',
  '2024-010': 'Patricia Ramos',
};

String twoDigits(int n) => n.toString().padLeft(2, '0');

class DummyStore extends ChangeNotifier {
  final List<ClassSession> sessions = [
    ClassSession(
      id: 'SES-DEMO-01',
      label: 'Nov 18 - Lecture (Dummy)',
      isActive: true,
      records: {
        '2024-001': AttendanceRecord(
          studentId: '2024-001',
          studentName: 'Juan Dela Cruz',
          scannedAt: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
        '2024-003': AttendanceRecord(
          studentId: '2024-003',
          studentName: 'Jose Rizal Mendoza',
          scannedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        '2024-005': AttendanceRecord(
          studentId: '2024-005',
          studentName: 'Carlo Bautista',
          scannedAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      },
    ),
  ];

  ClassSession createSession(String label) {
    final now = DateTime.now();
    final id =
        'SES-${now.year}${twoDigits(now.month)}${twoDigits(now.day)}-${twoDigits(now.hour)}${twoDigits(now.minute)}${twoDigits(now.second)}';

    final session = ClassSession(
      id: id,
      label: label.isEmpty ? id : label,
      isActive: true,
    );
    sessions.insert(0, session);
    notifyListeners();
    return session;
  }

  void toggleSession(String sessionId) {
    final index = sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      sessions[index].isActive = !sessions[index].isActive;
      notifyListeners();
    }
  }

  CheckInResult markAttendance({
    required String sessionId,
    required String studentId,
    required String studentName,
  }) {
    final index = sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) {
      return CheckInResult(
        title: 'Invalid QR Code',
        message: 'This QR code is not a valid class session.',
        isError: true,
      );
    }

    final session = sessions[index];
    if (!session.isActive) {
      return CheckInResult(
        title: 'Session Closed',
        message:
            'Attendance for "${session.label}" has already been closed by the teacher.',
        isError: true,
      );
    }

    if (session.records.containsKey(studentId)) {
      return CheckInResult(
        title: 'Already Checked In',
        message:
            '$studentName ($studentId) is already marked present for "${session.label}".',
        isError: false,
      );
    }

    session.records[studentId] = AttendanceRecord(
      studentId: studentId,
      studentName: studentName,
      scannedAt: DateTime.now(),
    );
    notifyListeners();

    return CheckInResult(
      title: 'Present!',
      message: 'Welcome, $studentName.\nRecorded for "${session.label}".',
      isError: false,
    );
  }
}

final DummyStore dummyStore = DummyStore();