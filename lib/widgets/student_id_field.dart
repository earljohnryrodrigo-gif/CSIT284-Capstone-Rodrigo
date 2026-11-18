import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/student_id_validator.dart';

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
    final text = controller.text.trim();

    // Only show an error once the full ID length is typed.
    final showError = text.length >= kStudentIdHint.length &&
        !StudentIdValidator.isValid(text);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      maxLength: kStudentIdHint.length,
      buildCounter: (
        BuildContext context, {
        required int currentLength,
        required bool isFocused,
        required int? maxLength,
      }) =>
          null,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
      ],
      decoration: InputDecoration(
        labelText: 'Student ID',
        hintText: 'e.g. $kStudentIdHint',
        errorText: showError ? 'Use the format $kStudentIdHint' : null,
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