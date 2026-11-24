# Attendance Checker (QR-Based)

**CSIT284 Capstone Project**

**Developer:** Earl Johnry Rodrigo
**Workstation Number:** [W32]

## Project Description

The Attendance Checker is a mobile application that lets teachers generate a unique QR code for each class session. Students enter their Student ID, scan the QR code with their phone, and receive confirmation that their attendance was recorded.

The application includes:

- **Student module:** Student ID entry with automatic name lookup, QR code scanning, attendance recording, duplicate prevention, closed-session validation, and clear success and error messages.
- **Teacher module:** PIN-protected access, a dashboard for creating sessions, generating QR codes, opening and closing sessions, and viewing present and absent students with check-in times.

## Features

- Student ID validation against a 10-student class roster
- QR code generation and scanning
- Duplicate attendance prevention
- Closed-session validation
- Invalid QR code handling
- Live attendance list with Present and Absent status and timestamps
- Material 3 interface

## Technology

- Flutter and Dart
- Material 3
- `qr_flutter` for generating QR codes
- `mobile_scanner` for scanning QR codes
- `shared_preferences` for remembering the last Student ID

## Project Structure

```
lib/
├── main.dart
├── data/          Dummy roster and sample sessions
├── models/        Student, ClassSession, AttendanceRecord, CheckInResult
├── services/      AttendanceService interface and dummy implementation
├── screens/       Student home, QR scanner, teacher login, teacher dashboard
├── widgets/       Reusable UI components
├── theme/         Material 3 theme
└── utils/         Constants, formatters, QR payload helpers
test/
└── attendance_logic_test.dart
```

## Running the Project

```powershell
flutter pub get
flutter run
```

Use an Android phone or emulator for QR scanning. The scanner does not run on Windows desktop.

## Testing

```powershell
flutter analyze
flutter test
```

## Demo Credentials

- **Teacher PIN:** 1234
- **Sample Student IDs:** 2024-001 to 2024-010

## Future Work

The service layer is designed so that Firebase Firestore can replace the dummy data. Only a new service class and one line in `main.dart` need to change.