/// Every possible outcome of a student check-in attempt.
enum CheckInStatus {
  success,
  invalidStudentId,
  invalidQrCode,
  sessionNotFound,
  sessionClosed,
  alreadyRecorded,
}

/// The result of one check-in attempt, shown to the student.
class CheckInResult {
  final CheckInStatus status;
  final String title;
  final String message;

  const CheckInResult({
    required this.status,
    required this.title,
    required this.message,
  });

  /// True only when attendance was recorded.
  bool get isSuccess => status == CheckInStatus.success;
}