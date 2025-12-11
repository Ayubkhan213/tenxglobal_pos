import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:tenxglobal_pos/models/printer_model.dart';

class PrintingAgentProviderMobile extends ChangeNotifier {
  Box<Printer>? printerBox;

  bool isLoading = false;
  List<Printer> availablePrinters = [];

  Printer? customerPrinter;
  Printer? kotPrinter;

  static const _customerKey = 'customer_printer';
  static const _kotKey = 'kot_printer';

  PrintingAgentProviderMobile() {
    _init();
  }

  Future<void> _init() async {
    if (!Hive.isBoxOpen('printerBoxs')) {
      printerBox = await Hive.openBox<Printer>('printerBoxs');
    } else {
      printerBox = Hive.box<Printer>('printerBoxs');
    }

    customerPrinter = printerBox!.get(_customerKey);
    kotPrinter = printerBox!.get(_kotKey);

    notifyListeners();
  }

  // ============================================================
  // LOAD PRINTERS
  // ============================================================
  Future<void> loadPrinters() async {
    if (printerBox == null) await _init();

    isLoading = true;
    notifyListeners();

    try {
      debugPrint("📱 Scanning mobile printers...");
      final printers = await getMobileNetworkPrinters();
      debugPrint('============ Printers Found ==============');
      debugPrint('Total: ${printers.length}');
      for (var p in printers) {
        debugPrint('  • ${p.name} at ${p.url}');
      }
      debugPrint('=========================================');

      availablePrinters = printers;

      // Restore saved printers
      if (customerPrinter != null) {
        customerPrinter = availablePrinters.firstWhere(
          (p) => p.url == customerPrinter!.url,
          orElse: () => customerPrinter!,
        );
      }

      if (kotPrinter != null) {
        kotPrinter = availablePrinters.firstWhere(
          (p) => p.url == kotPrinter!.url,
          orElse: () => kotPrinter!,
        );
      }

      debugPrint("✅ Loaded printers: ${availablePrinters.length}");
    } catch (e, stackTrace) {
      debugPrint("❌ Error loading printers: $e");
      debugPrint("Stack trace: $stackTrace");
      availablePrinters = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // SELECT PRINTER
  // ============================================================
  Future<void> selectCustomerPrinter(Printer? printer) async {
    customerPrinter = printer;
    if (printer == null) {
      await printerBox!.delete(_customerKey);
    } else {
      await printerBox!.put(_customerKey, printer.copy());
    }
    notifyListeners();
  }

  Future<void> selectKOTPrinter(Printer? printer) async {
    kotPrinter = printer;
    if (printer == null) {
      await printerBox!.delete(_kotKey);
    } else {
      await printerBox!.put(_kotKey, printer.copy());
    }
    notifyListeners();
  }

  // ============================================================
  // NETWORK SCAN - IMPROVED
  // ============================================================
  Future<List<Printer>> getMobileNetworkPrinters() async {
    List<Printer> found = [];

    try {
      final ip = await _getLocalIpAddress();
      debugPrint("📍 Local IP: $ip");

      if (ip == "0.0.0.0" || ip.isEmpty) {
        debugPrint("❌ No local IP found");
        return [];
      }

      final parts = ip.split(".");
      if (parts.length != 4) {
        debugPrint("❌ Invalid IP format: $ip");
        return [];
      }

      final prefix = "${parts[0]}.${parts[1]}.${parts[2]}";
      debugPrint("🔍 Scanning network: $prefix.1-254");

      // Common printer ports
      List<int> ports = [9100, 631, 515];

      // ✅ FIXED: Scan full range 1-254
      List<Future<Printer?>> scans = [];

      // Scan entire subnet (1-254)
      for (int i = 1; i <= 254; i++) {
        final target = "$prefix.$i";
        for (final port in ports) {
          scans.add(_pingPrinter(target, port));
        }
      }

      debugPrint("⏳ Scanning ${scans.length} possible printer addresses...");

      final results = await Future.wait(scans);

      for (final p in results) {
        if (p != null) {
          found.add(p);
          debugPrint("✅ Found printer: ${p.url}");
        }
      }

      debugPrint("🎉 Scan complete. Found ${found.length} printers");
    } catch (e, stackTrace) {
      debugPrint("❌ Network scan error: $e");
      debugPrint("Stack trace: $stackTrace");
    }

    return found;
  }

  Future<Printer?> _pingPrinter(String ip, int port) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(
            milliseconds: 500), // Reduced timeout for faster scanning
      );

      await socket.close();

      debugPrint("✅ Printer found at $ip:$port");

      return Printer(
        name: "Printer $ip",
        url: "$ip:$port",
        location: ip,
        model: "Network Printer (Port $port)",
        isDefault: false,
        isAvailable: true,
      );
    } catch (_) {
      // Silent fail for faster scanning
      return null;
    }
  }

  Future<String> _getLocalIpAddress() async {
    try {
      final info = NetworkInfo();

      // Try WiFi first
      final wifiIP = await info.getWifiIP();
      if (wifiIP != null && wifiIP.isNotEmpty && wifiIP != "0.0.0.0") {
        debugPrint("✅ WiFi IP: $wifiIP");
        return wifiIP;
      }

      // Try getting from network interfaces as fallback
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        final name = interface.name.toLowerCase();

        // Look for WiFi or Ethernet
        if (name.contains('wlan') ||
            name.contains('wifi') ||
            name.contains('eth') ||
            name.contains('en0')) {
          for (var addr in interface.addresses) {
            if (addr.type == InternetAddressType.IPv4 &&
                !addr.address.startsWith('127') &&
                !addr.address.startsWith('169.254')) {
              debugPrint("✅ Network IP: ${addr.address} (${interface.name})");
              return addr.address;
            }
          }
        }
      }

      debugPrint("⚠️ No valid IP found");
    } catch (e) {
      debugPrint("❌ Error getting IP: $e");
    }

    return "0.0.0.0";
  }

  // ============================================================
  // MANUAL PRINTER ADD (NEW - for testing specific IPs)
  // ============================================================
  Future<void> testSpecificPrinter(String ip, int port) async {
    debugPrint("🔍 Testing printer at $ip:$port");

    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 3),
      );

      await socket.close();

      debugPrint("✅ Printer is reachable at $ip:$port");

      final printer = Printer(
        name: "Printer $ip",
        url: "$ip:$port",
        location: ip,
        model: "Network Printer (Port $port)",
        isDefault: false,
        isAvailable: true,
      );

      // Add to list if not already present
      if (!availablePrinters.any((p) => p.url == printer.url)) {
        availablePrinters.add(printer);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Cannot reach printer at $ip:$port - $e");
      rethrow;
    }
  }
}
