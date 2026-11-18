import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

class StudentIdField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isValid;

  const StudentIdField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.isValid = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Student ID',
        hintText: 'e.g. $kStudentIdHint',
        prefixIcon: const Icon(Icons.badge_outlined),
        suffixIcon: isValid
            ? const Icon(Icons.check_circle, color: AppTheme.presentColor)
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}