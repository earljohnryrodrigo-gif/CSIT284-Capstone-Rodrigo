class AttendanceRecord {
  final String studentId;
  final String studentName;
  final DateTime scannedAt;

  AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.scannedAt,
  });
}

class ClassSession {
  final String id;
  final String label;
  bool isActive;
  final Map<String, AttendanceRecord> records;

  ClassSession({
    required this.id,
    required this.label,
    this.isActive = true,
    Map<String, AttendanceRecord>? records,
  }) : records = records ?? {};
}

class CheckInResult {
  final String title;
  final String message;
  final bool isError;

  CheckInResult({
    required this.title,
    required this.message,
    required this.isError,
  });
}