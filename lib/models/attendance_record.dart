/// One student's check-in for a single class session.
class AttendanceRecord {
  final String studentId;
  final String studentName;
  final DateTime timestamp;

  const AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.timestamp,
  });
}