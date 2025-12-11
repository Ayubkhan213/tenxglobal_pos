import 'package:shared_preferences/shared_preferences.dart';

class PrinterInfo {
  final String id;
  final String name;
  final String type; // 'bluetooth', 'lan', 'usb'

  PrinterInfo({
    required this.id,
    required this.name,
    required this.type,
  });
}

class PrinterService {
  PrinterService._();

  static final PrinterService instance = PrinterService._();

  List<PrinterInfo> _availablePrinters = [];
  PrinterInfo? _customerPrinter;
  PrinterInfo? _kitchenPrinter;

  List<PrinterInfo> get availablePrinters => _availablePrinters;
  PrinterInfo? get customerPrinter => _customerPrinter;
  PrinterInfo? get kitchenPrinter => _kitchenPrinter;

  static const _customerKey = 'customer_printer_id';
  static const _kitchenKey = 'kitchen_printer_id';

  Future<void> init() async {
    // TODO: replace this with real discovery (Bluetooth / LAN / USB)
    _availablePrinters = [
      PrinterInfo(id: 'p1', name: 'BlackCopper Customer', type: 'bluetooth'),
      PrinterInfo(id: 'p2', name: 'BlackCopper Kitchen', type: 'bluetooth'),
      PrinterInfo(id: 'p3', name: 'Network Printer 192.168.1.50', type: 'lan'),
    ];

    final prefs = await SharedPreferences.getInstance();
    final savedCustomerId = prefs.getString(_customerKey);
    final savedKitchenId = prefs.getString(_kitchenKey);

    _customerPrinter = _availablePrinters
        .where((p) => p.id == savedCustomerId)
        .cast<PrinterInfo?>()
        .firstWhere((p) => p != null, orElse: () => null);

    _kitchenPrinter = _availablePrinters
        .where((p) => p.id == savedKitchenId)
        .cast<PrinterInfo?>()
        .firstWhere((p) => p != null, orElse: () => null);

    print('🖨️ PrinterService init');
    print('   Available printers: ${_availablePrinters.map((e) => e.name).join(', ')}');
    print('   Selected customer: ${_customerPrinter?.name ?? 'None'}');
    print('   Selected kitchen: ${_kitchenPrinter?.name ?? 'None'}');
  }

  Future<void> setCustomerPrinter(PrinterInfo? printer) async {
    _customerPrinter = printer;
    final prefs = await SharedPreferences.getInstance();
    if (printer == null) {
      await prefs.remove(_customerKey);
    } else {
      await prefs.setString(_customerKey, printer.id);
    }
  }

  Future<void> setKitchenPrinter(PrinterInfo? printer) async {
    _kitchenPrinter = printer;
    final prefs = await SharedPreferences.getInstance();
    if (printer == null) {
      await prefs.remove(_kitchenKey);
    } else {
      await prefs.setString(_kitchenKey, printer.id);
    }
  }

  Future<void> printCustomerReceipt(dynamic order) async {
    // TODO: use _customerPrinter to select correct device and print
    print('🧾 [Customer Receipt] printing to ${_customerPrinter?.name ?? 'NO PRINTER SELECTED'}');
    print(order);
  }

  Future<void> printKitchenOrder(dynamic order) async {
    // TODO: use _kitchenPrinter to select correct device and print
    print('👩‍🍳 [Kitchen KOT] printing to ${_kitchenPrinter?.name ?? 'NO PRINTER SELECTED'}');
    print(order);
  }
}
