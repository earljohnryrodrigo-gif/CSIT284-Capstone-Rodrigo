/// Shared, app-wide constant values.
const String kAppName = 'Attendance Checker';
const String kClassName = 'CSIT284 - Capstone Class';

/// Teacher PIN used to unlock Teacher Mode. Change this before presenting.
const String kTeacherPin = '1234';

/// Every valid attendance QR code starts with this prefix. Codes without it
/// (for example, a random website QR) are rejected as invalid.
const String kQrPrefix = 'CSIT284-ATT:';

/// Example format shown to students as a hint.
const String kStudentIdHint = '2024-001';