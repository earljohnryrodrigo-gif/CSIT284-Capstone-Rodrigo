class StudentIdValidator {
  StudentIdValidator._();

  static final RegExp _pattern = RegExp(r'^\d{2}-\d{4}-\d{3}$');

  static bool isValid(String value) => _pattern.hasMatch(value.trim());
}