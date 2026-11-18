import '../models/check_in_result.dart';
import '../models/class_session.dart';
import '../models/student.dart';

abstract class AttendanceService {
  Future<List<Student>> getRoster();

  Future<Student?> findStudent(String studentId);

  Future<List<ClassSession>> getSessions();

  Stream<List<ClassSession>> watchSessions();

  Future<ClassSession> createSession(String title);

  Future<void> setSessionOpen(String sessionId, bool isOpen);

  Future<void> deleteSession(String sessionId);

  Future<CheckInResult> checkIn({
    required String rawQrValue,
    required String studentId,
  });

  void dispose();
}