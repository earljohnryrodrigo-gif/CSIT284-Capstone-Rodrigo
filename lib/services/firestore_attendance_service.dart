import 'package:cloud_firestore/cloud_firestore.dart';

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

class FirestoreAttendanceService implements AttendanceService {
  FirestoreAttendanceService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _sessionsRef =>
      _db.collection('sessions');

  Student? _studentById(String studentId) {
    for (final student in kStudentRoster) {
      if (student.id == studentId) return student;
    }
    return null;
  }

  ClassSession _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final createdRaw = data['createdAt'];
    final createdAt = createdRaw is Timestamp
        ? createdRaw.toDate()
        : DateTime.tryParse(createdRaw?.toString() ?? '') ?? DateTime.now();

    final rawRecords = data['records'] as Map<String, dynamic>? ?? {};
    final records = <String, AttendanceRecord>{};

    rawRecords.forEach((studentId, value) {
      if (value is Map<String, dynamic>) {
        final tsRaw = value['timestamp'];
        final ts = tsRaw is Timestamp
            ? tsRaw.toDate()
            : DateTime.tryParse(tsRaw?.toString() ?? '') ?? DateTime.now();

        records[studentId] = AttendanceRecord(
          studentId: value['studentId'] as String? ?? studentId,
          studentName: value['studentName'] as String? ?? 'Unknown Student',
          timestamp: ts,
        );
      }
    });

    return ClassSession(
      id: doc.id,
      title: data['title'] as String? ?? 'Class Session',
      createdAt: createdAt,
      isOpen: data['isOpen'] as bool? ?? true,
      records: records,
    );
  }

  Future<void> _closeAllOpenExcept(String? keepId) async {
    final openSnap = await _sessionsRef.where('isOpen', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in openSnap.docs) {
      if (doc.id != keepId) {
        batch.update(doc.reference, {'isOpen': false});
      }
    }
    await batch.commit();
  }

  @override
  Future<List<Student>> getRoster() async {
    return List<Student>.unmodifiable(kStudentRoster);
  }

  @override
  Future<Student?> findStudent(String studentId) async {
    final id = studentId.trim();
    if (!StudentIdValidator.isValid(id)) return null;
    return _studentById(id);
  }

  @override
  Future<List<ClassSession>> getSessions() async {
    final snap =
        await _sessionsRef.orderBy('createdAt', descending: false).get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Stream<List<ClassSession>> watchSessions() {
    return _sessionsRef
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Future<ClassSession> createSession(String title) async {
    final trimmed = title.trim();
    await _closeAllOpenExcept(null);

    final id = 'SES-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final finalTitle = trimmed.isEmpty ? 'Class Session' : trimmed;

    await _sessionsRef.doc(id).set({
      'title': finalTitle,
      'createdAt': Timestamp.fromDate(now),
      'isOpen': true,
      'records': <String, dynamic>{},
    });

    return ClassSession(
      id: id,
      title: finalTitle,
      createdAt: now,
      isOpen: true,
      records: const {},
    );
  }

  @override
  Future<void> setSessionOpen(String sessionId, bool isOpen) async {
    final docRef = _sessionsRef.doc(sessionId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    if (isOpen) {
      await _closeAllOpenExcept(sessionId);
    }

    await docRef.update({'isOpen': isOpen});
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _sessionsRef.doc(sessionId).delete();
  }

  @override
  Future<CheckInResult> checkIn({
    required String rawQrValue,
    required String studentId,
  }) async {
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

    final docRef = _sessionsRef.doc(sessionId);
    final doc = await docRef.get();
    if (!doc.exists) {
      return const CheckInResult(
        status: CheckInStatus.sessionNotFound,
        title: 'Session Not Found',
        message: 'This QR code does not match any class session.',
      );
    }

    final session = _fromDoc(doc);

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
    await docRef.update({
      'records.$id': {
        'studentId': id,
        'studentName': student.fullName,
        'timestamp': Timestamp.fromDate(now),
      },
    });

    return CheckInResult(
      status: CheckInStatus.success,
      title: 'Attendance Recorded',
      message: 'Thank you, ${student.fullName}. '
          'You are marked present at ${formatTime(now)}.',
    );
  }

  @override
  void dispose() {
    // Firestore streams are managed automatically.
  }
}