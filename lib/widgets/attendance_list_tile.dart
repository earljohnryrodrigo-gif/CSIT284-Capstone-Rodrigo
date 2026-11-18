import 'package:flutter/material.dart';

import '../data/dummy_store.dart';
import '../models/attendance_models.dart';

class AttendanceListTile extends StatelessWidget {
  final String studentId;
  final String studentName;
  final AttendanceRecord? record;

  const AttendanceListTile({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final isPresent = record != null;
    final timeText = record != null
        ? '${twoDigits(record!.scannedAt.hour)}:${twoDigits(record!.scannedAt.minute)}'
        : '';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            isPresent ? Colors.green.shade100 : Colors.grey.shade200,
        child: Icon(
          isPresent ? Icons.check : Icons.close,
          color: isPresent ? Colors.green.shade800 : Colors.grey,
        ),
      ),
      title: Text(studentName),
      subtitle: Text(studentId),
      trailing: Text(
        isPresent ? 'Present ($timeText)' : 'Absent',
        style: TextStyle(
          
          color: isPresent ? Colors.green.shade700 : Colors.grey,
        ),
      ),
    );
  }
}