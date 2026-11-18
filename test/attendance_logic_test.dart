import 'package:flutter_test/flutter_test.dart';

import 'package:capstone_rodrigo/data/student_roster.dart';
import 'package:capstone_rodrigo/models/check_in_result.dart';
import 'package:capstone_rodrigo/services/dummy_attendance_service.dart';
import 'package:capstone_rodrigo/utils/qr_payload.dart';
import 'package:capstone_rodrigo/utils/student_id_validator.dart';

void main() {
  group('StudentIdValidator', () {
    test('accepts the school ID format', () {
      expect(StudentIdValidator.isValid('24-3982-160'), isTrue);
    });

    test('rejects malformed IDs', () {
      expect(StudentIdValidator.isValid('2024-001'), isFalse);
      expect(StudentIdValidator.isValid('24-398-160'), isFalse);
      expect(StudentIdValidator.isValid('ABC'), isFalse);
      expect(StudentIdValidator.isValid(''), isFalse);
    });

    test('every roster ID follows the school format', () {
      for (final student in kStudentRoster) {
        expect(StudentIdValidator.isValid(student.id), isTrue);
      }
    });
  });

  group('QrPayload', () {
    test('encode and decode round-trip the session ID', () {
      final encoded = QrPayload.encode('SES-123');
      expect(QrPayload.decodeSessionId(encoded), 'SES-123');
    });

    test('decode rejects values without the attendance prefix', () {
      expect(QrPayload.decodeSessionId('https://example.com'), isNull);
    });

    test('decode rejects an empty session ID', () {
      expect(QrPayload.decodeSessionId('CSIT284-ATT:'), isNull);
    });
  });

  group('DummyAttendanceService check-in', () {
    late DummyAttendanceService service;

    setUp(() {
      service = DummyAttendanceService();
    });

    tearDown(() {
      service.dispose();
    });

    test('records attendance for a valid student and open session', () async {
      final result = await service.checkIn(
        rawQrValue: QrPayload.encode('SES-DEMO-OPEN'),
        studentId: '24-4120-208',
      );

      expect(result.status, CheckInStatus.success);
      expect(result.isSuccess, isTrue);
    });

    test('blocks a second check-in for the same student and session', () async {
      final qr = QrPayload.encode('SES-DEMO-OPEN');

      await service.checkIn(rawQrValue: qr, studentId: '24-3654-117');
      final second =
          await service.checkIn(rawQrValue: qr, studentId: '24-3654-117');

      expect(second.status, CheckInStatus.alreadyRecorded);
    });

    test('rejects an unknown student ID', () async {
      final result = await service.checkIn(
        rawQrValue: QrPayload.encode('SES-DEMO-OPEN'),
        studentId: '99-0000-000',
      );

      expect(result.status, CheckInStatus.invalidStudentId);
    });

    test('rejects a student ID with the wrong format', () async {
      final result = await service.checkIn(
        rawQrValue: QrPayload.encode('SES-DEMO-OPEN'),
        studentId: '2024-001',
      );

      expect(result.status, CheckInStatus.invalidStudentId);
    });

    test('rejects a QR code that is not an attendance code', () async {
      final result = await service.checkIn(
        rawQrValue: 'https://example.com',
        studentId: '24-4011-092',
      );

      expect(result.status, CheckInStatus.invalidQrCode);
    });

    test('rejects a QR code for a session that does not exist', () async {
      final result = await service.checkIn(
        rawQrValue: QrPayload.encode('SES-DOES-NOT-EXIST'),
        studentId: '24-4011-092',
      );

      expect(result.status, CheckInStatus.sessionNotFound);
    });

    test('rejects check-in when the session is closed', () async {
      final result = await service.checkIn(
        rawQrValue: QrPayload.encode('SES-DEMO-CLOSED'),
        studentId: '24-3893-275',
      );

      expect(result.status, CheckInStatus.sessionClosed);
    });
  });

  group('DummyAttendanceService session management', () {
    late DummyAttendanceService service;

    setUp(() {
      service = DummyAttendanceService();
    });

    tearDown(() {
      service.dispose();
    });

    test('createSession adds an open session and closes the others', () async {
      final session = await service.createSession('Lab Test');

      expect(session.title, 'Lab Test');
      expect(session.isOpen, isTrue);

      final sessions = await service.getSessions();
      expect(sessions.any((s) => s.id == session.id), isTrue);
      expect(sessions.where((s) => s.isOpen).length, 1);
    });

    test('setSessionOpen closes and reopens a session', () async {
      await service.setSessionOpen('SES-DEMO-OPEN', false);
      var sessions = await service.getSessions();
      expect(sessions.firstWhere((s) => s.id == 'SES-DEMO-OPEN').isOpen, isFalse);

      await service.setSessionOpen('SES-DEMO-OPEN', true);
      sessions = await service.getSessions();
      expect(sessions.firstWhere((s) => s.id == 'SES-DEMO-OPEN').isOpen, isTrue);
    });

    test('a student cannot check in after the teacher closes the session', () async {
      await service.setSessionOpen('SES-DEMO-OPEN', false);

      final result = await service.checkIn(
        rawQrValue: QrPayload.encode('SES-DEMO-OPEN'),
        studentId: '24-4256-131',
      );

      expect(result.status, CheckInStatus.sessionClosed);
    });

    test('deleteSession removes only the selected session', () async {
      await service.deleteSession('SES-DEMO-CLOSED');

      final sessions = await service.getSessions();
      expect(sessions.any((s) => s.id == 'SES-DEMO-CLOSED'), isFalse);
      expect(sessions.any((s) => s.id == 'SES-DEMO-OPEN'), isTrue);
      expect(sessions.any((s) => s.id == 'SES-DEMO-OLDER'), isTrue);
    });

    test('deleting an unknown session changes nothing', () async {
      final before = (await service.getSessions()).length;
      await service.deleteSession('SES-NOT-REAL');
      final after = (await service.getSessions()).length;

      expect(after, before);
    });
  });

  group('DummyAttendanceService roster', () {
    test('roster contains 10 students with IDs and names', () async {
      final service = DummyAttendanceService();
      final roster = await service.getRoster();

      expect(roster.length, greaterThanOrEqualTo(10));
      expect(
        roster.every((s) => s.id.isNotEmpty && s.fullName.isNotEmpty),
        isTrue,
      );

      service.dispose();
    });

    test('findStudent returns the registered name for a valid ID', () async {
      final service = DummyAttendanceService();
      final student = await service.findStudent('24-3982-160');

      expect(student?.fullName, 'Earl Rodrigo');

      service.dispose();
    });
  });
}