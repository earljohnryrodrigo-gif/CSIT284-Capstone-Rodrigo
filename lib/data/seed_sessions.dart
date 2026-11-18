import '../models/attendance_record.dart';
import '../models/class_session.dart';
import '../models/student.dart';
import 'student_roster.dart';

List<ClassSession> buildSeedSessions() {
  final now = DateTime.now();

  return [
    ClassSession(
      id: 'SES-DEMO-CLOSED',
      title: 'Previous Lecture - Nov 17',
      createdAt: now.subtract(const Duration(days: 1)),
      isOpen: false,
      records: _recordsFor(
        ['2024-001', '2024-002', '2024-003', '2024-004'],
        now.subtract(const Duration(days: 1, hours: 1)),
      ),
    ),
    ClassSession(
      id: 'SES-DEMO-OPEN',
      title: 'Current Lecture - Demo',
      createdAt: now,
      isOpen: true,
    ),
  ];
}

Map<String, AttendanceRecord> _recordsFor(
  List<String> studentIds,
  DateTime timestamp,
) {
  final records = <String, AttendanceRecord>{};

  for (final id in studentIds) {
    final student = _studentById(id);
    if (student == null) continue;

    records[id] = AttendanceRecord(
      studentId: id,
      studentName: student.fullName,
      timestamp: timestamp,
    );
  }

  return records;
}

Student? _studentById(String id) {
  for (final student in kStudentRoster) {
    if (student.id == id) return student;
  }
  return null;
}