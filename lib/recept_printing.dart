import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:tenxglobal_pos/models/order_response_model.dart';
import 'package:tenxglobal_pos/provider/printing_agant_provider.dart';
import 'package:tenxglobal_pos/services/hive_services/business_info_services.dart';

class ReceiptPrinterMobile {
  /// ESC/POS Commands
  static final Uint8List _escInit = Uint8List.fromList([0x1B, 0x40]);
  static final Uint8List _escAlignCenter =
      Uint8List.fromList([0x1B, 0x61, 0x01]);
  static final Uint8List _escAlignLeft = Uint8List.fromList([0x1B, 0x61, 0x00]);
  static final Uint8List _escAlignRight =
      Uint8List.fromList([0x1B, 0x61, 0x02]);
  static final Uint8List _escBold = Uint8List.fromList([0x1B, 0x45, 0x01]);
  static final Uint8List _escBoldOff = Uint8List.fromList([0x1B, 0x45, 0x00]);
  static final Uint8List _escSizeNormal =
      Uint8List.fromList([0x1D, 0x21, 0x00]);
  static final Uint8List _escSizeLarge = Uint8List.fromList([0x1D, 0x21, 0x11]);
  static final Uint8List _escSizeDouble =
      Uint8List.fromList([0x1D, 0x21, 0x22]);
  static final Uint8List _escCut = Uint8List.fromList([0x1D, 0x56, 0x00]);
  static final Uint8List _escFeedLines = Uint8List.fromList([0x1B, 0x64, 0x03]);

  /// Paper width detection (characters per line)
  static const int _width80mm = 48; // 80mm paper = ~48 chars
  static const int _width58mm = 32; // 58mm paper = ~32 chars
  static const int _width52mm = 24; // 52mm paper = ~24 chars (NARROW)

  ///======================================================
  /// DETECT PAPER WIDTH FROM PRINTER
  ///======================================================
  static int _detectPaperWidth(String printerName) {
    final name = printerName.toLowerCase();

    // Check printer name for width indicators
    if (name.contains('52') || name.contains('52mm')) {
      return _width52mm;
    } else if (name.contains('58') || name.contains('58mm')) {
      return _width58mm;
    } else if (name.contains('80') ||
        name.contains('80mm') ||
        name.contains('90') ||
        name.contains('90mm')) {
      return _width80mm;
    }

    // Default to 80mm if unknown
    return _width80mm;
  }

  ///======================================================
  /// PRINT KOT (SILENT) - AUTO WIDTH DETECTION
  ///======================================================
  static Future<void> printKOT({
    required BuildContext context,
    required String orderId,
    String orderType = '',
    List<OrderItem>? items,
  }) async {
    try {
      final provider = Provider.of<PrintingAgentProviderMobile>(
        context,
        listen: false,
      );

      if (provider.kotPrinter == null) {
        throw Exception("KOT printer is not configured");
      }

      final urlParts = provider.kotPrinter!.url.split(':');
      final ip = urlParts[0];
      final port = int.parse(urlParts[1]);

      // Detect paper width
      final paperWidth = _detectPaperWidth(provider.kotPrinter!.name);
      debugPrint("🖨️  Detected KOT paper width: $paperWidth chars");

      final data = _generateKOTData(
        orderId: orderId,
        orderType: orderType,
        items: items,
        paperWidth: paperWidth,
      );

      await _sendToPrinter(ip, port, data);

      _showMessage(context, "✅ KOT printed successfully", Colors.green);
    } catch (e) {
      _showMessage(context, "❌ KOT printing failed: $e", Colors.red);
      rethrow;
    }
  }

  ///======================================================
  /// PRINT CUSTOMER RECEIPT (SILENT) - AUTO WIDTH DETECTION
  ///======================================================
  static Future<void> printReceipt({
    required BuildContext context,
    required OrderResponse orderResponse,
  }) async {
    try {
      final provider = Provider.of<PrintingAgentProviderMobile>(
        context,
        listen: false,
      );

      if (provider.customerPrinter == null) {
        throw Exception("Customer printer is not configured");
      }

      final urlParts = provider.customerPrinter!.url.split(':');
      final ip = urlParts[0];
      final port = int.parse(urlParts[1]);

      // Detect paper width
      final paperWidth = _detectPaperWidth(provider.customerPrinter!.name);
      debugPrint("🖨️  Detected Receipt paper width: $paperWidth chars");

      final data = await _generateReceiptData(
        orderResponse,
        paperWidth: paperWidth,
      );

      await _sendToPrinter(ip, port, data);

      _showMessage(context, "✅ Receipt printed successfully", Colors.green);
    } catch (e) {
      _showMessage(context, "❌ Receipt printing failed: $e", Colors.red);
      rethrow;
    }
  }

  ///======================================================
  /// SEND DATA TO PRINTER VIA SOCKET (SILENT)
  ///======================================================
  static Future<void> _sendToPrinter(
    String ip,
    int port,
    Uint8List data,
  ) async {
    Socket? socket;

    try {
      debugPrint("🖨️  Connecting to printer at $ip:$port");

      socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );

      debugPrint("✅ Connected to printer");

      socket.add(data);
      await socket.flush();

      debugPrint("✅ Data sent to printer (${data.length} bytes)");

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint("❌ Printer connection error: $e");
      rethrow;
    } finally {
      socket?.destroy();
      debugPrint("🔌 Socket closed");
    }
  }

  ///======================================================
  /// GENERATE KOT ESC/POS DATA - ADAPTIVE WIDTH
  ///======================================================
  static Uint8List _generateKOTData({
    required String orderId,
    String orderType = '',
    List<OrderItem>? items,
    int paperWidth = _width80mm,
  }) {
    final buffer = BytesBuilder();

    buffer.add(_escInit);

    // Header
    buffer.add(_escAlignCenter);
    if (paperWidth >= _width58mm) {
      buffer.add(_escSizeDouble);
    } else {
      buffer.add(_escSizeLarge); // Smaller for 52mm
    }
    buffer.add(_escBold);
    buffer.add(_encode('KITCHEN ORDER'));
    buffer.add(_newLine());
    buffer.add(_escSizeNormal);
    buffer.add(_escBoldOff);
    buffer.add(_newLine());

    // Order info
    buffer.add(_escBold);
    buffer.add(_encode('Order #$orderId'));
    buffer.add(_newLine());
    buffer.add(_escBoldOff);

    buffer
        .add(_encode(intl.DateFormat('dd/MM/yy HH:mm').format(DateTime.now())));
    buffer.add(_newLine());

    // Truncate order type for narrow paper
    final displayType = _truncate(orderType, paperWidth - 6);
    buffer.add(_encode('Type: $displayType'));
    buffer.add(_newLine());

    buffer.add(_encode(_dashes(paperWidth)));
    buffer.add(_newLine());

    // Items
    buffer.add(_escAlignLeft);
    if (items != null && items.isNotEmpty) {
      for (var item in items) {
        // Item name and quantity - adjust for paper width
        buffer.add(_escBold);
        final itemText = '${item.quantity}x ${item.title}';

        if (paperWidth == _width52mm) {
          // For 52mm, wrap long item names
          final lines = _wrapText(itemText, paperWidth);
          for (var line in lines) {
            buffer.add(_encode(line));
            buffer.add(_newLine());
          }
        } else {
          buffer.add(_encode(_truncate(itemText, paperWidth)));
          buffer.add(_newLine());
        }
        buffer.add(_escBoldOff);

        // Notes if present
        if (item.note != null && item.note!.isNotEmpty) {
          final noteLines = _wrapText('  * ${item.note}', paperWidth - 2);
          for (var line in noteLines) {
            buffer.add(_encode(line));
            buffer.add(_newLine());
          }
        }

        buffer.add(_newLine());
      }
    }

    buffer.add(_encode(_dashes(paperWidth)));
    buffer.add(_newLine());
    buffer.add(_newLine());

    // Footer
    buffer.add(_escAlignCenter);
    buffer.add(_encode('Thank You!'));
    buffer.add(_newLine());

    buffer.add(_escFeedLines);
    buffer.add(_escCut);

    return buffer.toBytes();
  }

  ///======================================================
  /// GENERATE CUSTOMER RECEIPT ESC/POS DATA - MATCHES PDF DESIGN
  ///======================================================
  static Future<Uint8List> _generateReceiptData(
    OrderResponse orderResponse, {
    int paperWidth = _width80mm,
  }) async {
    final businessInfo = await BusinessInfoBoxService.getBusinessInfo();
    final order = orderResponse.order;
    final buffer = BytesBuilder();

    buffer.add(_escInit);

    // Add some blank lines at the top to prevent cutoff
    buffer.add(_newLine());
    buffer.add(_newLine());

    // ========== BUSINESS HEADER (CENTERED) ==========
    buffer.add(_escAlignCenter);

    // Business Name (Large & Bold)
    if (paperWidth >= _width58mm) {
      buffer.add(_escSizeLarge);
    } else {
      buffer.add(_escSizeNormal);
    }
    buffer.add(_escBold);
    final businessName = businessInfo?.business.businessName ?? 'BUSINESS NAME';
    buffer.add(_encode(_truncate(businessName, paperWidth)));
    buffer.add(_newLine());
    buffer.add(_escSizeNormal);
    buffer.add(_escBoldOff);

    // Order ID
    buffer.add(_encode('Order ID: #${order?.id ?? 'N/A'}'));
    buffer.add(_newLine());

    // Phone
    if (businessInfo?.business.phone != null) {
      buffer.add(_encode(
          _truncate('Tel: ${businessInfo!.business.phone}', paperWidth)));
      buffer.add(_newLine());
    }

    // Date
    buffer.add(_encode(
        'Date: ${intl.DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'));
    buffer.add(_newLine());
    buffer.add(_newLine());

    // Dotted border
    buffer.add(_encode(_dots(paperWidth)));
    buffer.add(_newLine());

    // ========== ORDER DETAILS (LEFT ALIGNED) ==========
    buffer.add(_escAlignLeft);

    // Payment Type with right-aligned value
    final paymentType = order?.paymentMethod ?? 'Cash';
    buffer.add(_encode(
        _formatLabelValueRight('Payment Type:', paymentType, paperWidth)));
    buffer.add(_newLine());

    // Order Type with right-aligned value
    final orderType = order?.orderType ?? 'Eatin';
    buffer.add(
        _encode(_formatLabelValueRight('Order Type:', orderType, paperWidth)));
    buffer.add(_newLine());

    // Customer Name with right-aligned value
    final customerName = order?.customerName ?? 'Eat in';
    buffer.add(_encode(
        _formatLabelValueRight('Customer Name:', customerName, paperWidth)));
    buffer.add(_newLine());

    // Contact Number (if present) with right-aligned value
    if (order?.phoneNumber != null && order!.phoneNumber!.trim().isNotEmpty) {
      buffer.add(_encode(_formatLabelValueRight(
          'Contact Number:', order.phoneNumber!, paperWidth)));
      buffer.add(_newLine());
    }

    buffer.add(_newLine());
    buffer.add(_encode(_dots(paperWidth)));
    buffer.add(_newLine());
    buffer.add(_newLine());

    // ========== ITEMS TABLE HEADER ==========
    buffer.add(_escAlignLeft);

    // Column widths
    final itemColWidth = paperWidth - 18; // Item name takes most space
    final qtyColWidth = 8;
    final priceColWidth = 10;

    // Header row (Bold)
    buffer.add(_escBold);
    final headerLine = _padRight('Item', itemColWidth) +
        _padCenter('Qty', qtyColWidth) +
        _padLeft('Price', priceColWidth);
    buffer.add(_encode(headerLine));
    buffer.add(_newLine());
    buffer.add(_escBoldOff);

    // Items
    if (order?.items != null && order!.items!.isNotEmpty) {
      for (var item in order.items!) {
        final name = _truncate(item.title ?? 'Item', itemColWidth);
        final qty = 'x${item.quantity ?? 0}';
        final price = '£${(item.price ?? 0).toStringAsFixed(2)}';

        final itemLine = _padRight(name, itemColWidth) +
            _padCenter(qty, qtyColWidth) +
            _padLeft(price, priceColWidth);
        buffer.add(_encode(itemLine));
        buffer.add(_newLine());
      }
    }

    buffer.add(_encode(_dots(paperWidth)));
    buffer.add(_newLine());
    buffer.add(_newLine());

    // ========== TOTALS SECTION (RIGHT ALIGNED VALUES) ==========
    buffer.add(_escAlignLeft);

    final subtotal = order?.subTotal ?? 0;
    final approvedDiscount = order?.approvedDiscounts ?? 0;
    final salesDiscount = order?.salesDiscount ?? 0;
    final promoDiscount = order?.promoDiscount ?? 0;
    final deliveryCharges = order?.deliveryCharges ?? 0;
    final total = order?.totalAmount ?? 0;

    // Subtotal
    buffer.add(_encode(_formatLabelValueRight(
        'Subtotal:', '£${subtotal.toStringAsFixed(2)}', paperWidth)));
    buffer.add(_newLine());

    // Approved Discount (if applicable)
    if (approvedDiscount > 0) {
      buffer.add(_encode(_formatLabelValueRight('Discount:',
          '-£${approvedDiscount.toStringAsFixed(2)}', paperWidth)));
      buffer.add(_newLine());
    }

    // Sales Discount (if applicable)
    if (salesDiscount > 0) {
      buffer.add(_encode(_formatLabelValueRight(
          'Sale:', '-£${salesDiscount.toStringAsFixed(2)}', paperWidth)));
      buffer.add(_newLine());
    }

    // Promo Discount (if applicable)
    if (promoDiscount > 0) {
      buffer.add(_encode(_formatLabelValueRight('Promo Discount:',
          '-£${promoDiscount.toStringAsFixed(2)}', paperWidth)));
      buffer.add(_newLine());
    }

    // Delivery Charges (if applicable)
    if (orderResponse.type == 'Delivery' && deliveryCharges > 0) {
      buffer.add(_encode(_formatLabelValueRight('Delivery Charges:',
          '${deliveryCharges.toStringAsFixed(0)}%', paperWidth)));
      buffer.add(_newLine());
    }

    // Total Price (Bold)
    buffer.add(_escBold);
    buffer.add(_encode(_formatLabelValueRight(
        'Total Price:', '£${total.toStringAsFixed(2)}', paperWidth)));
    buffer.add(_escBoldOff);
    buffer.add(_newLine());

    buffer.add(_encode(_dots(paperWidth)));
    buffer.add(_newLine());
    buffer.add(_newLine());

    // ========== FOOTER (CENTERED) ==========
    buffer.add(_escAlignCenter);

    // Email
    if (businessInfo?.user.email != null &&
        businessInfo!.user.email!.isNotEmpty) {
      buffer.add(
          _encode(_truncate('Email: ${businessInfo.user.email}', paperWidth)));
      buffer.add(_newLine());
    }

    // Location
    if (businessInfo?.business.address != null &&
        businessInfo!.business.address.isNotEmpty) {
      final addressLines =
          _wrapText('Location: ${businessInfo.business.address}', paperWidth);
      for (var line in addressLines) {
        buffer.add(_encode(line));
        buffer.add(_newLine());
      }
    }

    buffer.add(_newLine());
    buffer.add(_encode('Thank you for your order!'));
    buffer.add(_newLine());
    buffer.add(_newLine());

    // Feed and cut
    buffer.add(_escFeedLines);
    buffer.add(_escCut);

    return buffer.toBytes();
  }

  ///======================================================
  /// HELPER FUNCTIONS
  ///======================================================

  static Uint8List _encode(String text) {
    return Uint8List.fromList(text.codeUnits);
  }

  static Uint8List _newLine() {
    return Uint8List.fromList([0x0A]);
  }

  static String _dashes(int count) => '-' * count;
  static String _equals(int count) => '=' * count;
  static String _dots(int count) => '.' * count;

  /// Format label with right-aligned value (like in the receipt image)
  static String _formatLabelValueRight(
      String label, String value, int totalWidth) {
    final availableSpace = totalWidth - label.length - value.length;
    if (availableSpace <= 0) {
      // If no space, truncate value
      final maxValueLen = totalWidth - label.length - 1;
      return label +
          ' ' +
          (maxValueLen > 0 ? _truncate(value, maxValueLen) : '');
    }
    return label + (' ' * availableSpace) + value;
  }

  static String _padRight(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    return text + ' ' * (width - text.length);
  }

  static String _padLeft(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    return ' ' * (width - text.length) + text;
  }

  static String _padCenter(String text, int width) {
    if (text.length >= width) return text.substring(0, width);
    final padding = width - text.length;
    final leftPad = padding ~/ 2;
    final rightPad = padding - leftPad;
    return ' ' * leftPad + text + ' ' * rightPad;
  }

  static String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - 3) + '...';
  }

  /// Word wrap text to fit within width
  static List<String> _wrapText(String text, int maxWidth) {
    if (text.length <= maxWidth) return [text];

    final lines = <String>[];
    final words = text.split(' ');
    String currentLine = '';

    for (var word in words) {
      if ((currentLine + word).length <= maxWidth) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
        }
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  static void _showMessage(BuildContext context, String msg, Color color) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
