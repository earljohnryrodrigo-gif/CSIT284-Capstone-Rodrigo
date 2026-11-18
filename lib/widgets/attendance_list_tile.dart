import 'package:flutter/material.dart';

import '../models/attendance_record.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final attendance = record;
    final isPresent = attendance != null;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isPresent
            ? AppTheme.presentColor.withValues(alpha: 0.15)
            : colorScheme.surfaceContainerHighest,
        child: Icon(
          isPresent ? Icons.check : Icons.close,
          color: isPresent ? AppTheme.presentColor : AppTheme.absentColor,
        ),
      ),
      title: Text(studentName),
      subtitle: Text(studentId),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            isPresent ? 'Present' : 'Absent',
            style: TextStyle(
              color: isPresent ? AppTheme.presentColor : AppTheme.absentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (attendance != null)
            Text(
              formatTime(attendance.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}