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

  //===========================================================
  // LOAD PRINTERS
  //===========================================================
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

      // Restore saved printer mapping
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
    } catch (e) {
      debugPrint("❌ Error loading printers: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  //===========================================================
  // SAVE PRINTERS
  //===========================================================
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

  //===========================================================
  // NETWORK SCAN (🔥 OPTIMIZED)
  //===========================================================
  Future<List<Printer>> getMobileNetworkPrinters() async {
    List<Printer> found = [];

    try {
      String ip = await _getLocalIpAddress();
      debugPrint("📍 Local IP: $ip");

      if (ip.isEmpty || ip == "0.0.0.0") return [];

      final parts = ip.split(".");
      final prefix = "${parts[0]}.${parts[1]}.${parts[2]}";

      debugPrint("🔍 Starting scan on $prefix.1 - $prefix.254");

      // 1️⃣ QUICK DIRECT CHECK FIRST
      final directIp = "$prefix.200";
      final directPrinter = await _pingPrinter(directIp, 9100);

      if (directPrinter != null) {
        debugPrint("🎯 Direct printer found: $directIp");
        found.add(directPrinter);

        // ⚡ RETURN INSTANTLY — NO FULL SCAN
        return found;
      }

      // 2️⃣ Only scan subnet if direct search failed
      final results = await compute(_scanSubnet, prefix);

      for (final p in results) {
        if (p != null) found.add(p);
      }

      debugPrint("🎉 Scan complete. Found: ${found.length}");
    } catch (e) {
      debugPrint("❌ Scan error: $e");
    }

    return found;
  }

  //===========================================================
  // ISOLATE SCAN FUNCTION
  //===========================================================
  static Future<List<Printer?>> _scanSubnet(String prefix) async {
    List<Printer?> results = [];

    for (int i = 1; i <= 254; i++) {
      final ip = "$prefix.$i";
      final printer = await _trySocket(ip, 9100);
      if (printer != null) results.add(printer);
    }

    return results;
  }

  //===========================================================
  // SOCKET CHECK (used by isolate)
  //===========================================================
  static Future<Printer?> _trySocket(String ip, int port) async {
    try {
      final socket = await Socket.connect(ip, port,
          timeout: const Duration(milliseconds: 300));
      await socket.close();

      return Printer(
        name: "Printer $ip",
        url: "$ip:$port",
        location: ip,
        model: "Network Printer",
        isAvailable: true,
        isDefault: false,
      );
    } catch (_) {
      return null;
    }
  }

  //===========================================================
  // DIRECT TEST FUNCTION
  //===========================================================
  Future<Printer?> _pingPrinter(String ip, int port) async {
    try {
      final socket = await Socket.connect(ip, port,
          timeout: const Duration(milliseconds: 400));
      await socket.close();

      return Printer(
        name: "Printer $ip",
        url: "$ip:$port",
        location: ip,
        model: "Network Printer",
        isAvailable: true,
        isDefault: false,
      );
    } catch (_) {
      return null;
    }
  }

  //===========================================================
  // GET LOCAL IP
  //===========================================================
  Future<String> _getLocalIpAddress() async {
    try {
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();

      if (wifiIP != null && wifiIP.isNotEmpty) {
        return wifiIP;
      }
    } catch (_) {}

    return "0.0.0.0";
  }
}
