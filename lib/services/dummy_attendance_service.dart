import 'dart:async';

import '../data/seed_sessions.dart';
import '../data/student_roster.dart';
import '../models/attendance_record.dart';
import '../models/check_in_result.dart';
import '../models/class_session.dart';
import '../models/student.dart';
import '../utils/app_constants.dart';
import '../utils/formatters.dart';
import '../utils/qr_payload.dart';
import '../utils/student_id_validator.dart';
import 'attendance_service.dart';

class DummyAttendanceService implements AttendanceService {
  DummyAttendanceService() : _sessions = buildSeedSessions();

  final List<ClassSession> _sessions;

  final StreamController<List<ClassSession>> _controller =
      StreamController<List<ClassSession>>.broadcast();

  static const Duration _latency = Duration(milliseconds: 250);

  Future<void> _delay() => Future<void>.delayed(_latency);

  List<ClassSession> _snapshot() => List<ClassSession>.unmodifiable(_sessions);

  void _emit() => _controller.add(_snapshot());

  int _indexOf(String sessionId) {
    for (var i = 0; i < _sessions.length; i++) {
      if (_sessions[i].id == sessionId) return i;
    }
    return -1;
  }

  Student? _studentById(String studentId) {
    for (final student in kStudentRoster) {
      if (student.id == studentId) return student;
    }
    return null;
  }

  void _closeAllOpenExcept(String? keepId) {
    for (var i = 0; i < _sessions.length; i++) {
      final session = _sessions[i];
      if (session.isOpen && session.id != keepId) {
        _sessions[i] = session.copyWith(isOpen: false);
      }
    }
  }

  @override
  Future<List<Student>> getRoster() async {
    await _delay();
    return List<Student>.unmodifiable(kStudentRoster);
  }

  @override
  Future<Student?> findStudent(String studentId) async {
    await _delay();
    final id = studentId.trim();
    if (!StudentIdValidator.isValid(id)) return null;
    return _studentById(id);
  }

  @override
  Future<List<ClassSession>> getSessions() async {
    await _delay();
    return _snapshot();
  }

  @override
  Stream<List<ClassSession>> watchSessions() async* {
    yield _snapshot();
    yield* _controller.stream;
  }

  @override
  Future<ClassSession> createSession(String title) async {
    await _delay();

    final trimmed = title.trim();
    _closeAllOpenExcept(null);

    final session = ClassSession(
      id: 'SES-${DateTime.now().millisecondsSinceEpoch}',
      title: trimmed.isEmpty ? 'Class Session' : trimmed,
      createdAt: DateTime.now(),
    );

    _sessions.add(session);
    _emit();
    return session;
  }

  @override
  Future<void> setSessionOpen(String sessionId, bool isOpen) async {
    await _delay();

    final index = _indexOf(sessionId);
    if (index == -1) return;

    if (isOpen) _closeAllOpenExcept(sessionId);

    _sessions[index] = _sessions[index].copyWith(isOpen: isOpen);
    _emit();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _delay();

    final index = _indexOf(sessionId);
    if (index == -1) return;

    _sessions.removeAt(index);
    _emit();
  }

  @override
  Future<CheckInResult> checkIn({
    required String rawQrValue,
    required String studentId,
  }) async {
    await _delay();

    final id = studentId.trim();
    if (!StudentIdValidator.isValid(id)) {
      return CheckInResult(
        status: CheckInStatus.invalidStudentId,
        title: 'Invalid Student ID',
        message: 'Student IDs use the format $kStudentIdHint. '
            'Please check and try again.',
      );
    }

    final student = _studentById(id);
    if (student == null) {
      return CheckInResult(
        status: CheckInStatus.invalidStudentId,
        title: 'Student ID Not Found',
        message: 'The Student ID "$id" is not in the class roster. '
            'Please check and try again.',
      );
    }

    final sessionId = QrPayload.decodeSessionId(rawQrValue);
    if (sessionId == null) {
      return const CheckInResult(
        status: CheckInStatus.invalidQrCode,
        title: 'Invalid QR Code',
        message: 'This is not an attendance QR code for this class.',
      );
    }

    final index = _indexOf(sessionId);
    if (index == -1) {
      return const CheckInResult(
        status: CheckInStatus.sessionNotFound,
        title: 'Session Not Found',
        message: 'This QR code does not match any class session.',
      );
    }

    final session = _sessions[index];

    if (!session.isOpen) {
      return CheckInResult(
        status: CheckInStatus.sessionClosed,
        title: 'Session Closed',
        message: 'The teacher has closed "${session.title}". '
            'Attendance cannot be recorded.',
      );
    }

    if (session.hasAttended(id)) {
      return CheckInResult(
        status: CheckInStatus.alreadyRecorded,
        title: 'Already Recorded',
        message: '${student.fullName}, your attendance for '
            '"${session.title}" is already recorded.',
      );
    }

    final now = DateTime.now();
    final records = Map<String, AttendanceRecord>.of(session.records);
    records[id] = AttendanceRecord(
      studentId: id,
      studentName: student.fullName,
      timestamp: now,
    );

    _sessions[index] = session.copyWith(records: records);
    _emit();

    return CheckInResult(
      status: CheckInStatus.success,
      title: 'Attendance Recorded',
      message: 'Thank you, ${student.fullName}. '
          'You are marked present at ${formatTime(now)}.',
    );
  }

  @override
  void dispose() {
    _controller.close();
  }
}