// import 'dart:io';

// import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
// import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';

// class CashDrawerService {
//   static const int defaultPort = 9100; // Xprinter LAN usually 9100

//   // Try method A then B (best for Xprinter variations)
//   static Future<void> open({
//     required String ip,
//     int port = defaultPort,
//     String? usbPrinterName,
//   }) async {
//     final kickA = <int>[0x1B, 0x70, 0x00, 0x19, 0xFA];
//     final kickB = <int>[0x1B, 0x70, 0x00, 0x3C, 0xFF];

//     // Attempt A
//     final okA = await _send(ip, port, kickA);

//     if (usbPrinterName != null) {
//       await _sendToUSB(usbPrinterName, kickA);
//       await Future.delayed(Duration(milliseconds: 100));
//       await _sendToUSB(usbPrinterName, kickB);
//       return;
//     }
//     if (okA) return;

//     // Attempt B
//     await _send(ip, port, kickB);
//   }

//   static Future<bool> _send(String ip, int port, List<int> bytes) async {
//     Socket? socket;
//     try {
//       socket =
//           await Socket.connect(ip, port, timeout: const Duration(seconds: 3));
//       socket.add(bytes);
//       await socket.flush();
//       return true;
//     } catch (_) {
//       return false;
//     } finally {
//       await socket?.close();
//     }
//   }

//   static Future<bool> _sendToUSB(String printerName, List<int> command) async {
//     print(">>>>>>>>>>>>>>  ${printerName}");
//     try {
//       // For USB printers, use your existing printer package
//       // Example with esc_pos_printer or similar package:

//       final profile = await CapabilityProfile.load();
//       final printer = NetworkPrinter(PaperSize.mm80, profile);

//       // If using USB printer package like 'printing' or 'esc_pos_printer'
//       // You'll need to send raw bytes to the USB printer

//       // Example pseudocode (adjust based on your printer package):
//       // await UsbPrinter.write(printerName, Uint8List.fromList(command));

//       return true;
//     } catch (e) {
//       print('USB send error: $e');
//       return false;
//     }
//   }
// }

//////////////////////////  working code////////////////////////////////////

// import 'dart:io';
// import 'dart:typed_data';
// import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
// import 'package:flutter_thermal_printer/utils/printer.dart';
// import 'package:tenxglobal_pos/models/printer_model.dart' hide Printer;

// class CashDrawerService {
//   static const int defaultPort = 9100; // Xprinter LAN usually 9100

//   // ESC/POS cash drawer kick commands
//   static final kickCommandA =
//       Uint8List.fromList([0x1B, 0x70, 0x00, 0x19, 0xFA]);
//   static final kickCommandB =
//       Uint8List.fromList([0x1B, 0x70, 0x00, 0x3C, 0xFF]);

//   /// Open cash drawer for both LAN and USB printers
//   static Future<void> open({
//     required String? ip,
//     int port = defaultPort,
//     String? usbPrinterName,
//   }) async {
//     // USB Printer
//     if (usbPrinterName != null && usbPrinterName.isNotEmpty) {
//       await _openUSBDrawer(usbPrinterName);
//       return;
//     }

//     // LAN Printer
//     if (ip != null && ip.isNotEmpty) {
//       await _openLANDrawer(ip, port);
//       return;
//     }

//     print('⚠️ No printer specified for cash drawer');
//   }

//   /// Open cash drawer via LAN printer
//   static Future<void> _openLANDrawer(String ip, int port) async {
//     // Try command A first
//     final okA = await _sendToLAN(ip, port, kickCommandA);
//     if (okA) {
//       print('✅ Cash drawer opened (Command A)');
//       return;
//     }

//     // Fallback to command B
//     final okB = await _sendToLAN(ip, port, kickCommandB);
//     if (okB) {
//       print('✅ Cash drawer opened (Command B)');
//     } else {
//       print('❌ Failed to open cash drawer');
//     }
//   }

//   static Future<List<Printer>> _getUSBPrinters(
//       FlutterThermalPrinter printer) async {
//     try {
//       List<Printer>? capturedPrinters;

//       final subscription = printer.devicesStream.listen((printers) {
//         capturedPrinters = printers;
//       });

//       try {
//         await printer.getPrinters(
//           connectionTypes: [ConnectionType.USB],
//         );

//         // Wait for stream to receive data
//         await Future.delayed(const Duration(milliseconds: 1000));

//         return capturedPrinters ?? [];
//       } finally {
//         await subscription.cancel();
//       }
//     } catch (e) {
//       debugPrint("⚠️ Error getting USB printers: $e");
//       return [];
//     }
//   }

//   /// Open cash drawer via USB printer
//   /// Open cash drawer via USB printer
//   static Future<void> _openUSBDrawer(String printerName) async {
//     final _thermalPrinter = FlutterThermalPrinter.instance;

//     try {
//       final printers = await _getUSBPrinters(_thermalPrinter);

//       if (printers.isEmpty) {
//         throw Exception('No USB printers found. Please check connection.');
//       }

//       // Find the matching printer
//       Printer? targetPrinter;
//       final parts = printerName.split(':');
//       if (parts.length == 3) {
//         // Format: usb:vendorId:productId
//         final vendorId = parts[1];
//         final productId = parts[2];

//         targetPrinter = printers.firstWhere(
//           (p) => '${p.vendorId}' == vendorId && '${p.productId}' == productId,
//           orElse: () => printers.first, // Fallback to first USB printer
//         );
//       } else {
//         // If only "usb:vendorId" or malformed, use first available
//         targetPrinter = printers.first;
//       }

//       debugPrint("✅ Found USB printer: ${targetPrinter.name}");

//       // Print using flutter_thermal_printer
//       await _thermalPrinter.printData(
//         targetPrinter,
//         kickCommandA,
//         longData: true, // Use longData for larger prints
//       );

//       await Future.delayed(const Duration(milliseconds: 100));
//       await _thermalPrinter.printData(
//         targetPrinter,
//         kickCommandB,
//         longData: true, // Use longData for larger prints
//       );

//       print('✅ USB Cash drawer kick sent to: $printerName');
//     } catch (e) {
//       print('❌ USB cash drawer error: $e');
//     }
//   }

//   /// Send raw bytes to LAN printer
//   static Future<bool> _sendToLAN(String ip, int port, Uint8List bytes) async {
//     Socket? socket;
//     try {
//       socket = await Socket.connect(
//         ip,
//         port,
//         timeout: const Duration(seconds: 3),
//       );
//       socket.add(bytes);
//       await socket.flush();
//       return true;
//     } catch (e) {
//       print('LAN send error: $e');
//       return false;
//     } finally {
//       await socket?.close();
//     }
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:tenxglobal_pos/data/models/printer_model.dart' hide Printer;

class CashDrawerService {
  static const int defaultPort = 9100; // Xprinter LAN usually 9100

  // ESC/POS cash drawer kick commands
  static final kickCommandA =
      Uint8List.fromList([0x1B, 0x70, 0x00, 0x19, 0xFA]);
  static final kickCommandB =
      Uint8List.fromList([0x1B, 0x70, 0x00, 0x3C, 0xFF]);
  static final kickCommandStandard =
      Uint8List.fromList([0x1B, 0x70, 0x00, 0x64, 0x64]); // Standard kick

  /// Open cash drawer for both LAN and USB printers
  static Future<void> open({
    required String? ip,
    int port = defaultPort,
    String? usbPrinterName,
  }) async {
    // USB Printer
    if (usbPrinterName != null && usbPrinterName.isNotEmpty) {
      await _openUSBDrawer(usbPrinterName);
      return;
    }

    // LAN Printer
    if (ip != null && ip.isNotEmpty) {
      await _openLANDrawer(ip, port);
      return;
    }

    print('⚠️ No printer specified for cash drawer');
  }

  /// Open cash drawer via LAN printer
  static Future<void> _openLANDrawer(String ip, int port) async {
    try {
      // Method 1: Using esc_pos_printer_plus with proper generator
      final profile = await CapabilityProfile.load();
      final printer = NetworkPrinter(PaperSize.mm80, profile);

      final PosPrintResult res = await printer.connect(ip, port: port);

      if (res == PosPrintResult.success) {
        final generator = Generator(PaperSize.mm80, profile);

        // Generate drawer kick command using the generator
        final bytes = generator.drawer();

        printer.rawBytes(bytes);
        await Future.delayed(const Duration(milliseconds: 500));
        printer.disconnect();

        print('✅ Cash drawer opened via LAN (Method 1)');
        return;
      }
    } catch (e) {
      print('LAN Method 1 failed: $e');
    }

    // Method 2: Raw socket commands (fallback)
    final okA = await _sendToLAN(ip, port, kickCommandStandard);
    if (okA) {
      print('✅ Cash drawer opened (Standard Command)');
      return;
    }

    final okB = await _sendToLAN(ip, port, kickCommandA);
    if (okB) {
      print('✅ Cash drawer opened (Command A)');
      return;
    }

    final okC = await _sendToLAN(ip, port, kickCommandB);
    if (okC) {
      print('✅ Cash drawer opened (Command B)');
    } else {
      print('❌ Failed to open cash drawer');
    }
  }

  static Future<List<Printer>> _getUSBPrinters(
      FlutterThermalPrinter printer) async {
    try {
      List<Printer>? capturedPrinters;

      final subscription = printer.devicesStream.listen((printers) {
        capturedPrinters = printers;
      });

      try {
        await printer.getPrinters(
          connectionTypes: [ConnectionType.USB],
        );

        // Wait for stream to receive data
        await Future.delayed(const Duration(milliseconds: 1000));

        return capturedPrinters ?? [];
      } finally {
        await subscription.cancel();
      }
    } catch (e) {
      debugPrint("⚠️ Error getting USB printers: $e");
      return [];
    }
  }

  /// Open cash drawer via USB printer using ESC/POS generator
  static Future<void> _openUSBDrawer(String printerName) async {
    final _thermalPrinter = FlutterThermalPrinter.instance;

    try {
      final printers = await _getUSBPrinters(_thermalPrinter);

      if (printers.isEmpty) {
        throw Exception('No USB printers found. Please check connection.');
      }

      // Find the matching printer
      Printer? targetPrinter;
      final parts = printerName.split(':');
      if (parts.length == 3) {
        final vendorId = parts[1];
        final productId = parts[2];

        targetPrinter = printers.firstWhere(
          (p) => '${p.vendorId}' == vendorId && '${p.productId}' == productId,
          orElse: () => printers.first,
        );
      } else {
        targetPrinter = printers.first;
      }

      debugPrint("✅ Found USB printer: ${targetPrinter.name}");

      // Generate proper ESC/POS command with drawer kick
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);

      // Method 1: Using generator (most compatible)
      final drawerBytes = generator.drawer();
      final ticket = drawerBytes;

      await _thermalPrinter.printData(
        targetPrinter,
        Uint8List.fromList(ticket),
        longData: false,
      );

      await Future.delayed(const Duration(milliseconds: 300));

      // Method 2: Try raw commands as fallback
      await _thermalPrinter.printData(
        targetPrinter,
        kickCommandStandard,
        longData: false,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      await _thermalPrinter.printData(
        targetPrinter,
        kickCommandA,
        longData: false,
      );

      print('✅ USB Cash drawer kick sent to: ${targetPrinter.name}');
    } catch (e) {
      print('❌ USB cash drawer error: $e');
      rethrow;
    }
  }

  /// Send raw bytes to LAN printer
  static Future<bool> _sendToLAN(String ip, int port, Uint8List bytes) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 3),
      );
      socket.add(bytes);
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    } catch (e) {
      print('LAN send error: $e');
      return false;
    } finally {
      await socket?.close();
    }
  }
}
