/// Pads a number to two digits, for example 7 becomes "07".
String twoDigits(int value) => value.toString().padLeft(2, '0');

/// Formats a time as HH:mm, for example "09:05".
String formatTime(DateTime time) {
  return '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
}

/// Formats a date and time as MM/DD/YYYY HH:mm, for example "11/18/2026 09:05".
String formatDateTime(DateTime time) {
  return '${twoDigits(time.month)}/${twoDigits(time.day)}/${time.year} '
      '${formatTime(time)}';
}