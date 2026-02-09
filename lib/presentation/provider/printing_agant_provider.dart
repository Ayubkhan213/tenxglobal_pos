import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:hive/hive.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:tenxglobal_pos/core/services/hive_services/printer_box_service.dart';
import 'package:tenxglobal_pos/data/models/printer_model.dart' hide Printer;
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
// Alias only your custom Printer model
import 'package:tenxglobal_pos/data/models/printer_model.dart' as custom;
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';

class PrintingAgentProviderMobile extends ChangeNotifier {
  Box? printerBox;
  bool isLoading = false;
  List<custom.Printer> availablePrinters = [];
  custom.Printer? customerPrinter;
  custom.Printer? kotPrinter;

  static const _customerKey = 'customer_printer';
  static const _kotKey = 'kot_printer';

  // USB printer support
  final _thermalPrinter = FlutterThermalPrinter.instance;

  PrintingAgentProviderMobile() {
    _init();
  }

  Future<void> _init() async {
    if (!Hive.isBoxOpen('printerBoxs')) {
      printerBox = await Hive.openBox('printerBoxs');
    } else {
      printerBox = Hive.box('printerBoxs');
    }
    customerPrinter = printerBox!.get(_customerKey);
    kotPrinter = printerBox!.get(_kotKey);
    notifyListeners();
  }

  //===========================================================
  // LOAD PRINTERS - NETWORK + USB
  //===========================================================
  Future<void> loadPrinters() async {
    if (printerBox == null) await _init();

    isLoading = true;
    notifyListeners();

    try {
      debugPrint("📱 Scanning for printers (Network + USB)...");

      // Get network printers
      final networkPrinters = await getMobileNetworkPrinters();

      // Get USB printers
      final usbPrinters = await getUSBPrinters();

      // Combine both lists
      final allPrinters = [...networkPrinters, ...usbPrinters];

      debugPrint('============ Printers Found ==============');
      debugPrint('Network: ${networkPrinters.length}');
      debugPrint('USB: ${usbPrinters.length}');
      debugPrint('Total: ${allPrinters.length}');
      for (var p in allPrinters) {
        debugPrint('   • ${p.name} at ${p.url} (${p.model})');
      }
      debugPrint('=========================================');

      availablePrinters = allPrinters;

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

      if (availablePrinters.isEmpty) {
        print('----------- Empty - Clearing selections ------------');
        availablePrinters.clear();
        selectCustomerPrinter(null);
        selectKOTPrinter(null);
      }
    } catch (e) {
      debugPrint("❌ Error loading printers: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  //===========================================================
  // GET USB PRINTERS
  //===========================================================
  Future<List<custom.Printer>> getUSBPrinters() async {
    List<custom.Printer> found = [];
    try {
      debugPrint("🔌 Scanning for USB printers...");

      // Set up stream listener first
      List<Printer>? capturedPrinters;
      final subscription = _thermalPrinter.devicesStream.listen((printers) {
        capturedPrinters = printers;
        debugPrint("📱 Stream received ${printers.length} USB printer(s)");
      });

      try {
        // Now trigger the scan
        await _thermalPrinter.getPrinters(
          connectionTypes: [ConnectionType.USB],
        );

        // Wait for stream to receive data
        await Future.delayed(const Duration(milliseconds: 1500));

        // Cancel subscription
        await subscription.cancel();

        // Process captured printers
        if (capturedPrinters != null && capturedPrinters!.isNotEmpty) {
          for (var usbPrinter in capturedPrinters!) {
            // Create unique identifier for USB printer
            final usbId =
                'usb:${usbPrinter.vendorId ?? "unknown"}:${usbPrinter.productId ?? "unknown"}';

            found.add(custom.Printer(
              name: usbPrinter.name ?? 'USB Printer',
              url: usbId,
              location: 'USB Connected',
              model: 'USB Thermal Printer',
              isAvailable: true,
              isDefault: false,
            ));

            debugPrint(
                '✅ Found USB printer: ${usbPrinter.name} (VID: ${usbPrinter.vendorId}, PID: ${usbPrinter.productId})');
          }
        } else {
          debugPrint("ℹ️ No USB printers detected");
        }
      } finally {
        await subscription.cancel();
      }

      debugPrint("📊 USB scan complete. Found: ${found.length}");
    } catch (e) {
      debugPrint("⚠️ USB scan error: $e");
    }
    return found;
  }

  //===========================================================
  // SAVE PRINTERS
  //===========================================================
  Future<void> selectCustomerPrinter(custom.Printer? printer) async {
    customerPrinter = printer;
    if (printer == null) {
      await printerBox!.delete(_customerKey);
    } else {
      await printerBox!.put(_customerKey, printer.copy());
    }
    notifyListeners();
  }

  Future<void> selectKOTPrinter(custom.Printer? printer) async {
    kotPrinter = printer;
    if (printer == null) {
      await printerBox!.delete(_kotKey);
    } else {
      await printerBox!.put(_kotKey, printer.copy());
    }
    notifyListeners();
  }

  //===========================================================
  // SCAN FOR NETWORK PRINTERS - WITH WORLDWIDE IP PRIORITY
  //===========================================================
  Future<List<custom.Printer>> getMobileNetworkPrinters() async {
    List<custom.Printer> found = [];
    try {
      String ip = await _getLocalIpAddress();
      debugPrint("🌐 Local IP: $ip");

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
        51, 52, 30, 31, 32, 40, 41, 42, 60, 61, 62, 70, 71, 72,
        // Tier 4: DHCP Ranges
        106, 107, 108, 109, 111, 112, 113, 114, 115, 151, 152, 153, 154, 155,
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
          debugPrint("✅ Network printer found at: $testIp");
          found.add(printer);
          return found; // EXIT IMMEDIATELY - Printer found!
        }
      }

      debugPrint("❌ No network printer found in priority IPs");
    } catch (e) {
      debugPrint("⚠️ Network scan error: $e");
    }
    return found;
  }

  //===========================================================
  // DIRECT TEST FUNCTION
  //===========================================================
  Future<custom.Printer?> _pingPrinter(String ip, int port) async {
    try {
      final socket = await Socket.connect(ip, port,
          timeout: const Duration(milliseconds: 400));
      await socket.close();

      return custom.Printer(
        name: "Network Printer $ip",
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
    try {
      String? fallbackIP;
      for (var interface in await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      )) {
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
                // VERIFY this IP is actually reachable
                if (await _verifyIpIsActive(ip)) {
                  debugPrint(
                      "✅ Verified active WiFi IP from ${interface.name}: $ip");
                  return ip;
                } else {
                  fallbackIP ??= ip;
                  debugPrint("⚠️ Found IP but not verified: $ip");
                }
              }
            }
          }
        }
      }

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
      final parts = ip.split(".");
      final gateway = "${parts[0]}.${parts[1]}.${parts[2]}.1";

      final socket = await Socket.connect(
        gateway,
        80,
        timeout: const Duration(milliseconds: 300),
      );
      socket.destroy();
      return true;
    } catch (_) {
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
}
