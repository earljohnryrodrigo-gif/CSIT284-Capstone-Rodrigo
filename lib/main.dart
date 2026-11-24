import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/student_home_screen.dart';
import 'services/attendance_service.dart';
import 'services/firestore_attendance_service.dart';
import 'theme/app_theme.dart';
import 'utils/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final AttendanceService service = FirestoreAttendanceService();
  runApp(AttendanceApp(service: service));
}

class AttendanceApp extends StatelessWidget {
  final AttendanceService service;

  const AttendanceApp({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: StudentHomeScreen(service: service),
    );
  }
}