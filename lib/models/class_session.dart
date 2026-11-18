import 'attendance_record.dart';

/// One class session created by the teacher.
class ClassSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final bool isOpen;

  /// Check-ins for this session, keyed by student ID.
  /// Using the student ID as the key makes duplicate checks simple.
  final Map<String, AttendanceRecord> records;

  const ClassSession({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isOpen = true,
    this.records = const {},
  });

  /// Number of students who have checked in.
  int get presentCount => records.length;

  /// True if the student has already checked in to this session.
  bool hasAttended(String studentId) => records.containsKey(studentId);

  /// Returns a copy of this session with the given fields changed.
  ClassSession copyWith({
    bool? isOpen,
    Map<String, AttendanceRecord>? records,
  }) {
    return ClassSession(
      id: id,
      title: title,
      createdAt: createdAt,
      isOpen: isOpen ?? this.isOpen,
      records: records ?? this.records,
    );
  }
}