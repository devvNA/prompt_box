import 'dart:math';

/// Utility to generate RFC 4122 compliant version 4 UUIDs without external dependencies.
class UuidGenerator {
  UuidGenerator._();

  static final Random _random = Random.secure();

  /// Generates a random version 4 UUID string.
  static String v4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));

    // Set version to 0100 (version 4)
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Set variant to 10xx (RFC 4122)
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    return '${_toHex(bytes.sublist(0, 4))}-'
        '${_toHex(bytes.sublist(4, 6))}-'
        '${_toHex(bytes.sublist(6, 8))}-'
        '${_toHex(bytes.sublist(8, 10))}-'
        '${_toHex(bytes.sublist(10, 16))}';
  }

  static String _toHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
