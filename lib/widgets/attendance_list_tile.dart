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
    final textTheme = Theme.of(context).textTheme;
    final attendance = record;
    final isPresent = attendance != null;
    final statusColor =
        isPresent ? AppTheme.presentColor : AppTheme.absentColor;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.15),
        child: Icon(
          isPresent ? Icons.check : Icons.close,
          color: statusColor,
        ),
      ),
      title: Text(studentName),
      subtitle: Text(studentId),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPresent ? 'PRESENT' : 'ABSENT',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            attendance == null ? '--' : formatTime(attendance.timestamp),
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}