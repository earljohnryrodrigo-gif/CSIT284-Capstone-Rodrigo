import 'app_constants.dart';

/// Encodes and decodes the text stored inside a session QR code.
class QrPayload {
  QrPayload._();

  /// Builds the text that goes inside the QR code for a session.
  static String encode(String sessionId) => '$kQrPrefix$sessionId';

  /// Returns the session ID from a scanned value, or null if the value is
  /// not a valid attendance QR code.
  static String? decodeSessionId(String rawValue) {
    final value = rawValue.trim();
    if (!value.startsWith(kQrPrefix)) return null;

    final sessionId = value.substring(kQrPrefix.length).trim();
    return sessionId.isEmpty ? null : sessionId;
  }
}