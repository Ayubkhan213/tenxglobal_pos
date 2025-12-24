import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:tenxglobal_pos/core/services/hive_services/printer_box_service.dart';
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

      debugPrint(" Loaded printers: ${availablePrinters.length}");
      if (availablePrinters.isEmpty) {
        print('----------- Empty ------------');
        availablePrinters.clear();

        selectCustomerPrinter(null);
        selectKOTPrinter(null);

        // PrinterBoxService.clearBox();
      }
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
// SCAN FOR PRINTERS - WITH WORLDWIDE IP PRIORITY
//===========================================================
  Future<List<Printer>> getMobileNetworkPrinters() async {
    List<Printer> found = [];

    try {
      String ip = await _getLocalIpAddress();
      debugPrint(" Local IP: $ip");

      if (ip.isEmpty || ip == "0.0.0.0") return [];

      final parts = ip.split(".");
      final prefix = "${parts[0]}.${parts[1]}.${parts[2]}";

      debugPrint("🔍 Starting priority scan on $prefix.*");

      // WORLDWIDE PRIORITY IP LIST - Ordered by most common usage
      final priorityIPs = [
        // Tier 1: Most Common (80% of printers)
        200, 100, 192, 201, 254, 1, 150, 50, 10, 20,

        // Tier 2: Router Defaults
        101, 102, 103, 104, 105, 110, 120, 130, 140, 2, 3, 4, 5,

        // Tier 3: Brand-Specific (HP, Canon, Epson, Brother, Xerox)
        50, 51, 52, 30, 31, 32, 40, 41, 42, 60, 61, 62, 70, 71, 72,

        // Tier 4: DHCP Ranges
        106, 107, 108, 109, 111, 112, 113, 114, 115,
        151, 152, 153, 154, 155,
        202, 203, 204, 205, 206, 207, 208, 209, 210, 220, 230, 240, 250,

        // Tier 5: Network Equipment
        251, 252, 253,
      ];

      // Remove duplicates while maintaining order
      final uniqueIPs = priorityIPs.toSet().toList();

      // Check each IP - STOP at first printer found
      for (final lastOctet in uniqueIPs) {
        final testIp = "$prefix.$lastOctet";
        final printer = await _pingPrinter(testIp, 9100);

        if (printer != null) {
          debugPrint("✅ Printer found at: $testIp");
          found.add(printer);
          return found; // EXIT IMMEDIATELY - Printer found!
        }
      }

      debugPrint("❌ No printer found in priority IPs");
    } catch (e) {
      debugPrint("⚠️ Scan error: $e");
    }

    return found;
  }

  // Future<List<Printer>> getMobileNetworkPrinters() async {
  //   List<Printer> found = [];

  //   try {
  //     String ip = await _getLocalIpAddress();
  //     debugPrint(" Local IP: $ip");

  //     if (ip.isEmpty || ip == "0.0.0.0") return [];

  //     final parts = ip.split(".");
  //     final prefix = "${parts[0]}.${parts[1]}.${parts[2]}";

  //     debugPrint(" Starting priority scan on $prefix.*");

  //     // 1️ PRIORITY CHECK - Most common printer IPs
  //     final priorityIPs = [200, 100, 192, 201, 254, 1, 150, 50];

  //     for (final lastOctet in priorityIPs) {
  //       final testIp = "$prefix.$lastOctet";
  //       final printer = await _pingPrinter(testIp, 9100);

  //       if (printer != null) {
  //         debugPrint(" Printer found at priority IP: $testIp");
  //         found.add(printer);

  //         //  RETURN INSTANTLY — Found a printer
  //         return found;
  //       }
  //     }

  //     debugPrint(" No printer at priority IPs. Starting full scan...");

  //     // //  FULL SUBNET SCAN - Only if priority check failed
  //     // final results = await compute(_scanSubnet, prefix);

  //     // for (final p in results) {
  //     //   if (p != null) found.add(p);
  //     // }

  //     // debugPrint(" Scan complete. Found: ${found.length}");
  //   } catch (e) {
  //     debugPrint(" Scan error: $e");
  //   }

  //   return found;
  // }

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
// GET LOCAL IP - ENSURES CURRENT ACTIVE WIFI ONLY
//===========================================================
  Future<String> _getLocalIpAddress() async {
    // Method 1: Try network_info_plus (BEST - Gets CURRENT WiFi)
    try {
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();

      if (wifiIP != null && wifiIP.isNotEmpty && wifiIP != "0.0.0.0") {
        debugPrint("✅ Got current WiFi IP: $wifiIP");
        return wifiIP;
      }
    } catch (e) {
      debugPrint("⚠️ network_info_plus failed: $e");
    }

    // Method 2: Fallback - ONLY if Method 1 fails
    // Get ACTIVE interface by checking connectivity
    try {
      String? fallbackIP;

      for (var interface in await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      )) {
        // Skip if interface is DOWN or not active
        if (!interface.addresses.isNotEmpty) continue;

        final interfaceName = interface.name.toLowerCase();
        final isWifiOrEthernet = interfaceName.contains('wlan') ||
            interfaceName.contains('en') ||
            interfaceName.contains('eth') ||
            interfaceName.contains('wi');

        if (isWifiOrEthernet) {
          for (var addr in interface.addresses) {
            if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
              final ip = addr.address;

              // Only accept private network IPs
              if (ip.startsWith('192.168.') ||
                  ip.startsWith('10.') ||
                  (ip.startsWith('172.') &&
                      int.parse(ip.split('.')[1]) >= 16 &&
                      int.parse(ip.split('.')[1]) <= 31)) {
                // VERIFY this IP is actually reachable (active connection)
                if (await _verifyIpIsActive(ip)) {
                  debugPrint(
                      " Verified active WiFi IP from ${interface.name}: $ip");
                  return ip;
                } else {
                  // Store as fallback but keep searching
                  fallbackIP ??= ip;
                  debugPrint(" Found IP but not verified: $ip");
                }
              }
            }
          }
        }
      }

      // If we found an IP but couldn't verify, use it
      if (fallbackIP != null) {
        debugPrint("⚠️ Using unverified fallback IP: $fallbackIP");
        return fallbackIP;
      }
    } catch (e) {
      debugPrint("⚠️ NetworkInterface fallback failed: $e");
    }

    debugPrint("❌ No active WiFi IP found");
    return "0.0.0.0";
  }

//===========================================================
// VERIFY IP IS ACTIVE (Quick connectivity check)
//===========================================================
  Future<bool> _verifyIpIsActive(String ip) async {
    try {
      // Try to reach default gateway (usually .1)
      final parts = ip.split(".");
      final gateway = "${parts[0]}.${parts[1]}.${parts[2]}.1";

      final socket = await Socket.connect(
        gateway,
        80, // or any common port
        timeout: const Duration(milliseconds: 300),
      );
      socket.destroy();
      return true;
    } catch (_) {
      // Try pinging self as last resort
      try {
        final socket = await Socket.connect(
          ip,
          0,
          timeout: const Duration(milliseconds: 200),
        );
        socket.destroy();
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  // Future<String> _getLocalIpAddress() async {
  //   try {
  //     final info = NetworkInfo();
  //     final wifiIP = await info.getWifiIP();

  //     if (wifiIP != null && wifiIP.isNotEmpty) {
  //       return wifiIP;
  //     }
  //   } catch (_) {}

  //   return "0.0.0.0";
  // }
}
