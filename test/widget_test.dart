import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capstone_rodrigo/main.dart';
import 'package:capstone_rodrigo/services/dummy_attendance_service.dart';
import 'package:capstone_rodrigo/utils/app_constants.dart';

void main() {
  testWidgets('Student home screen shows the app title and scan button',
      (WidgetTester tester) async {
    final service = DummyAttendanceService();

    await tester.pumpWidget(AttendanceApp(service: service));
    await tester.pump();

    expect(find.text(kAppName), findsOneWidget);
    expect(find.text('Scan Class QR'), findsOneWidget);
    expect(find.byIcon(Icons.admin_panel_settings_outlined), findsOneWidget);

    service.dispose();
  });
}