import 'dart:io';

class CashDrawerService {
  static const int defaultPort = 9100; // Xprinter LAN usually 9100

  // Try method A then B (best for Xprinter variations)
  static Future<void> open({
    required String ip,
    int port = defaultPort,
  }) async {
    final kickA = <int>[0x1B, 0x70, 0x00, 0x19, 0xFA];
    final kickB = <int>[0x1B, 0x70, 0x00, 0x3C, 0xFF];

    // Attempt A
    final okA = await _send(ip, port, kickA);
    if (okA) return;

    // Attempt B
    await _send(ip, port, kickB);
  }

  static Future<bool> _send(String ip, int port, List<int> bytes) async {
    Socket? socket;
    try {
      socket =
          await Socket.connect(ip, port, timeout: const Duration(seconds: 3));
      socket.add(bytes);
      await socket.flush();
      return true;
    } catch (_) {
      return false;
    } finally {
      await socket?.close();
    }
  }
}
