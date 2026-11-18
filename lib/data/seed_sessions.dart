import '../models/attendance_record.dart';
import '../models/class_session.dart';
import '../models/student.dart';
import 'student_roster.dart';

List<ClassSession> buildSeedSessions() {
  final now = DateTime.now();

  return [
    ClassSession(
      id: 'SES-DEMO-OLDER',
      title: 'Lecture - Nov 16',
      createdAt: now.subtract(const Duration(days: 2)),
      isOpen: false,
      records: _recordsFor(
        ['24-3982-160', '24-3982-161', '24-3982-162', '24-3761-043'],
        now.subtract(const Duration(days: 2, hours: 1)),
      ),
    ),
    ClassSession(
      id: 'SES-DEMO-CLOSED',
      title: 'Lecture - Nov 17',
      createdAt: now.subtract(const Duration(days: 1)),
      isOpen: false,
      records: _recordsFor(
        [
          '24-3982-160',
          '24-4120-208',
          '24-3654-117',
          '24-4011-092',
          '24-3893-275',
          '24-4256-131',
        ],
        now.subtract(const Duration(days: 1, hours: 1)),
      ),
    ),
    ClassSession(
      id: 'SES-DEMO-OPEN',
      title: 'Lecture - Today (Demo)',
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