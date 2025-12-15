import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:tenxglobal_pos/core/services/hive_services/business_info_service.dart';
import 'package:tenxglobal_pos/models/order_response_model.dart';
import 'package:tenxglobal_pos/provider/printing_agant_provider.dart';

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

      final data = await _generateKOTData(
        // Add await here
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
  static Future<Uint8List> _generateKOTData({
    required String orderId,
    String orderType = '',
    List<OrderItem>? items,
    int paperWidth = _width80mm,
    String? customerName,
    String? phoneNumber,
    String? paymentMethod,
  }) async {
    final businessInfo = await BusinessInfoBoxService.getBusinessInfo();
    final buffer = BytesBuilder();

    // Remove top margin
    buffer.add([0x1B, 0x32]);

    buffer.add(_escAlignCenter);

    buffer.add(_escSizeLarge);
    buffer.add(
        _encode(orderType.isNotEmpty ? orderType.toUpperCase() : 'EAT IN'));
    buffer.add(_newLine());
    buffer.add(_newLine());
    buffer.add(_escSizeNormal);
    buffer.add(_escBoldOff);

    buffer.add(_escSizeDouble);
    buffer.add(_escBold);
    buffer.add(_encode(orderId));
    buffer.add(_newLine());
    buffer.add(_escSizeNormal);
    buffer.add(_escBoldOff);

    buffer.add(_newLine());
    buffer.add(
      _encode(
        'Date: ${intl.DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
      ),
    );
    buffer.add(_newLine());
    buffer.add(_encode(_dashes(paperWidth)));
    buffer.add(_newLine());
    buffer.add(_escSizeLarge);
    buffer.add(_encode('KOT'));
    buffer.add(_escSizeNormal);
    buffer.add(_newLine());

    buffer.add(_encode(_dashes(paperWidth)));
    buffer.add(_newLine());
    // ============================================================
    // ================= ORDER DETAILS =============================
    // ============================================================

    buffer.add(_escAlignLeft);

    // Payment Type
    buffer.add(
      _encode(
        _formatLabelValueRight(
          'Payment Type:',
          paymentMethod ?? 'Cash',
          paperWidth,
        ),
      ),
    );
    buffer.add(_newLine());

    // Customer Name
    buffer.add(
      _encode(
        _formatLabelValueRight(
          'Customer Name:',
          customerName ?? 'Eat in',
          paperWidth,
        ),
      ),
    );
    buffer.add(_newLine());

    // Phone Number (optional)
    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      buffer.add(
        _encode(
          _formatLabelValueRight(
            'Contact Number:',
            phoneNumber,
            paperWidth,
          ),
        ),
      );
      buffer.add(_newLine());
    }

    buffer.add(_encode(_dashes(paperWidth)));
    buffer.add(_newLine());

    // ============================================================
    // ================= ITEMS TABLE ===============================
    // ============================================================

    buffer.add(_escAlignLeft);

    final itemColWidth = paperWidth - 8;
    final qtyColWidth = 8;

    buffer.add(_escBold);
    final headerLine =
        _padRight('Item', itemColWidth) + _padCenter('Qty', qtyColWidth);

    buffer.add(_encode(headerLine));
    buffer.add(_newLine());
    buffer.add(_escBoldOff);

    // Items
    if (items != null && items.isNotEmpty) {
      for (var item in items) {
        final name = _truncate(item.title ?? 'Item', itemColWidth);
        final qty = '${item.quantity ?? 0}';
// 1️ Print NAME (normal)
        buffer.add(_encode(_padRight(name, itemColWidth)));

// 2️ Turn BOLD ON
        buffer.add(_escBold);

// 3️ Print QTY (bold)
        buffer.add(_encode(_padCenter(qty, qtyColWidth)));

// 4️ Turn BOLD OFF
        buffer.add(_escBoldOff);
        //  Check removed ingredients
        if (item.removedIngredients != null &&
            item.removedIngredients!.isNotEmpty) {
          // Indent for "Remove"
          // const removeIndent = ''; // 4 spaces

          // buffer.add(_encode('$removeIndent Remove:'));

          // buffer.add(_newLine());

          // Indent further for each removed ingredient
          const ingredientIndent = ''; // 8 spaces
          for (var ing in item.removedIngredients!) {
            buffer.add(_encode('$ingredientIndent Remove ${ing.name}'));

            // buffer.add(_newLine());
          }
        }

        buffer.add(_newLine());

        // Notes if present
        if (item.note != null && item.note!.isNotEmpty) {
          final noteLines = _wrapText(
              '  Note: ${item.note?.split('.').first}', paperWidth - 2);
          for (var line in noteLines) {
            buffer.add(_encode(line));
            buffer.add(_newLine());
          }
        }
      }
    }

    buffer.add(_encode(_dashes(paperWidth)));
    buffer.add(_escAlignCenter);
    buffer.add(_encode('Order paid'));
    buffer.add(_newLine());
    buffer.add(_newLine());

    buffer.add(_escFeedLines);
    buffer.add(_escCut);

    return buffer.toBytes();
  }

// ============================================================
// ================= HELPER FUNCTIONS =========================
// ============================================================

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

    //buffer.add(_escInit);
    buffer.add([0x1B, 0x32]);
    // ============================================================
    // =============== PRINT LOGO AT START =========================
    // ============================================================
    // if (businessInfo?.business.logoUrl != null &&
    //     businessInfo!.business.logoUrl!.trim().isNotEmpty) {
    //   try {
    //     // Load image from URL
    //     final ByteData imgBytes = await NetworkAssetBundle(
    //       Uri.parse(businessInfo.business.logoUrl!),
    //     ).load("");

    //     final Uint8List imageData = imgBytes.buffer.asUint8List();

    //     // Decode image
    //     final img.Image? decodedImg = img.decodeImage(imageData);

    //     if (decodedImg != null) {
    //       // 🔥 Resize logo (WIDTH = 150px for small logo)
    //       final img.Image resized = img.copyResize(
    //         decodedImg,
    //         width: 150, // change to 120 / 100 if you want even smaller
    //         height: null,
    //       );

    //       final Generator generator = Generator(
    //         paperWidth == _width80mm ? PaperSize.mm80 : PaperSize.mm58,
    //         await CapabilityProfile.load(),
    //       );

    //       // Convert resized image to ESC/POS
    //       final List<int> bytes = generator.image(resized);

    //       buffer.add(bytes);
    //       buffer.add(generator.reset());
    //     }
    //   } catch (e) {
    //     debugPrint("Logo loading failed: $e");
    //   }
    // }

    // ============================================================
    // ================= BUSINESS HEADER ===========================
    // ============================================================

    buffer.add(_escAlignCenter);
    buffer.add(_escAlignCenter);

    buffer.add(_escSizeLarge);
    buffer.add(_encode(order?.orderType ?? 'Eatin'));
    buffer.add(_newLine2());
    buffer.add(_newLine());
    buffer.add(_escSizeNormal);
    buffer.add(_escBoldOff);

    buffer.add(_escSizeDouble);
    buffer.add(_escBold);
    buffer.add(_encode('${order?.id ?? 'N/A'}'));
    buffer.add(_newLine());
    buffer.add(_newLine());
    buffer.add(_escSizeNormal);
    buffer.add(_escBoldOff);
    // Business Name (Bold)
    buffer.add(paperWidth >= _width58mm ? _escSizeLarge : _escSizeNormal);
    buffer.add(_escBold);

    final businessName = businessInfo?.business.businessName ?? 'BUSINESS NAME';
    buffer.add(_encode(_truncate(businessName, paperWidth)));
    buffer.add(_newLine());
    buffer.add(_newLine());

    buffer.add(_escSizeNormal);
    buffer.add(_escBoldOff);

    // Order ID
    // buffer.add(_encode('Order ID: #${order?.id ?? 'N/A'}'));
    // buffer.add(_newLine());

    // Date
    buffer.add(
      _encode(
        'Date: ${intl.DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
      ),
    );
    buffer.add(_newLine());

    buffer.add(_encode(_dashes(paperWidth)));
    buffer.add(_newLine());

    // ============================================================
    // ================= ORDER DETAILS =============================
    // ============================================================

    buffer.add(_escAlignLeft);

    // Payment Type
    buffer.add(
      _encode(
        _formatLabelValueRight(
          'Payment Type:',
          order?.paymentMethod ?? 'Cash',
          paperWidth,
        ),
      ),
    );
    buffer.add(_newLine());

    // Order Type
    // buffer.add(
    //   _encode(
    //     _formatLabelValueRight(
    //       'Order Type:',
    //       order?.orderType ?? 'Eatin',
    //       paperWidth,
    //     ),
    //   ),
    // );
    // buffer.add(_newLine());

    // Customer Name
    buffer.add(
      _encode(
        _formatLabelValueRight(
          'Customer Name:',
          order?.customerName ?? 'Eat in',
          paperWidth,
        ),
      ),
    );

    // Phone Number (optional)
    if (order?.phoneNumber != null && order!.phoneNumber!.trim().isNotEmpty) {
      buffer.add(
        _encode(
          _formatLabelValueRight(
            'Contact Number:',
            order.phoneNumber!,
            paperWidth,
          ),
        ),
      );
      buffer.add(_newLine());
    }

    buffer.add(_newLine());
    buffer.add(_encode(_dashes(paperWidth)));
    buffer.add(_newLine());

    // ============================================================
    // ================= ITEMS TABLE ===============================
    // ============================================================

    buffer.add(_escAlignLeft);

    final itemColWidth = paperWidth - 18;
    final qtyColWidth = 8;
    final priceColWidth = 10;

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
        final qty = '${item.quantity ?? 0}';
        final price = '£${(item.price ?? 0).toStringAsFixed(2)}';
        // 1️ Print NAME (normal)
        buffer.add(_encode(_padRight(name, itemColWidth)));

        // 2️ Turn BOLD ON
        buffer.add(_escBold);

        // 3️ Print QTY + PRICE (bold)
        buffer.add(_encode(
          _padCenter(qty, qtyColWidth) + _padLeft(price, priceColWidth),
        ));

        // 4️ Turn BOLD OFF
        buffer.add(_escBoldOff);
        //  Check removed ingredients
        if (item.removedIngredients != null &&
            item.removedIngredients!.isNotEmpty) {
          // Indent for "Remove"
          // const removeIndent = ''; // 4 spaces

          // buffer.add(_encode('$removeIndent Remove'));

          // buffer.add(_newLine());

          // Indent further for each removed ingredient
          const ingredientIndent = ''; // 8 spaces
          for (var ing in item.removedIngredients!) {
            buffer.add(_encode('$ingredientIndent Remove ${ing.name}'));

            buffer.add(_newLine());
          }
        }
        if (item.removedIngredients != null &&
            item.removedIngredients!.isEmpty) {
          buffer.add(_newLine());
        }
      }
    }

    buffer.add(_encode(_dashes(paperWidth)));
    buffer.add(_newLine());

    // ============================================================
    // ================= TOTALS ===================================
    // ============================================================

    buffer.add(_escAlignLeft);

    final subtotal = order?.subTotal ?? 0;
    final approvedDiscount = order?.approvedDiscounts ?? 0;
    final salesDiscount = order?.salesDiscount ?? 0;
    final promoDiscount = order?.promoDiscount ?? 0;
    final deliveryCharges = order?.deliveryCharges ?? 0;
    final total = order?.totalAmount ?? 0;
    printLabelValueRightBold(
      buffer: buffer,
      label: 'Order Price:',
      value: '£${orderResponse.order?.subTotal?.toStringAsFixed(2)}',
      escBoldOn: _escBold,
      escBoldOff: _escBoldOff,
      encode: _encode,
      totalWidth: paperWidth,
    );

    printLabelValueRightBold(
      buffer: buffer,
      label: 'Services Charges:',
      value: '£${orderResponse.order?.serviceCharges?.toStringAsFixed(2)}',
      escBoldOn: _escBold,
      escBoldOff: _escBoldOff,
      encode: _encode,
      totalWidth: paperWidth,
    );

    buffer.add(_newLine());

    if (approvedDiscount > 0) {
      printLabelValueRightBold(
        buffer: buffer,
        label: 'Discount:',
        value: '-£${approvedDiscount.toStringAsFixed(2)}',
        escBoldOn: _escBold,
        escBoldOff: _escBoldOff,
        encode: _encode,
        totalWidth: paperWidth,
      );

      buffer.add(_newLine());
    }

    if (salesDiscount > 0) {
      printLabelValueRightBold(
        buffer: buffer,
        label: 'Sale:',
        value: '-£${salesDiscount.toStringAsFixed(2)}',
        escBoldOn: _escBold,
        escBoldOff: _escBoldOff,
        encode: _encode,
        totalWidth: paperWidth,
      );

      buffer.add(_newLine());
    }

    if (promoDiscount > 0) {
      printLabelValueRightBold(
        buffer: buffer,
        label: 'Promo Discount:',
        value: '-£${promoDiscount.toStringAsFixed(2)}',
        escBoldOn: _escBold,
        escBoldOff: _escBoldOff,
        encode: _encode,
        totalWidth: paperWidth,
      );

      buffer.add(_newLine());
    }

    if (orderResponse.type == 'Delivery' && deliveryCharges > 0) {
      printLabelValueRightBold(
        buffer: buffer,
        label: 'Delivery Charges:',
        value: '${deliveryCharges.toStringAsFixed(0)}%',
        escBoldOn: _escBold,
        escBoldOff: _escBoldOff,
        encode: _encode,
        totalWidth: paperWidth,
      );

      buffer.add(_newLine());
    }
    printLabelValueRightBold(
      buffer: buffer,
      label: 'Net Price:',
      value: '£${total.toStringAsFixed(2)}',
      escBoldOn: _escBold,
      escBoldOff: _escBoldOff,
      encode: _encode,
      totalWidth: paperWidth,
    );
    printLabelValueRightBold(
      buffer: buffer,
      label: 'Paid Amount:',
      value: '£${total.toStringAsFixed(2)}',
      escBoldOn: _escBold,
      escBoldOff: _escBoldOff,
      encode: _encode,
      totalWidth: paperWidth,
    );

    printLabelValueRightBold(
      buffer: buffer,
      label: 'Outstanding:',
      value: ' 0.0',
      escBoldOn: _escBold,
      escBoldOff: _escBoldOff,
      encode: _encode,
      totalWidth: paperWidth,
    );

    buffer.add(_escBoldOff);
    buffer.add(_newLine());

    buffer.add(_encode(_dashes(paperWidth)));
    buffer.add(_newLine());
    buffer.add(_escBold);
    buffer.add(
      _encode(
        'VAT/ Taxes',
      ),
    );
    buffer.add(_escBoldOff);
    buffer.add(_newLine());

    printLabelValueRightBold(
      buffer: buffer,
      label: 'Total VAT',
      value: '£${orderResponse.order?.tax?.toStringAsFixed(2)}',
      escBoldOn: _escBold,
      escBoldOff: _escBoldOff,
      encode: _encode,
      totalWidth: paperWidth,
    );

    buffer.add(_newLine());
    buffer.add(_encode(_dashes(paperWidth)));
    buffer.add(_newLine());

    // ============================================================
    // ================= FOOTER ===================================
    // ============================================================

    buffer.add(_escAlignCenter);
    // Phone
    if (businessInfo?.business.phone != null) {
      buffer.add(_encode(
        _truncate('Tel: ${businessInfo!.business.phone}', paperWidth),
      ));
      buffer.add(_newLine());
    }

    if (businessInfo?.user.email != null &&
        businessInfo!.user.email!.isNotEmpty) {
      buffer.add(_encode('Email: ${businessInfo.user.email}'));
      buffer.add(_newLine());
    }

    if (businessInfo!.business.address.isNotEmpty) {
      final lines =
          _wrapText('Location: ${businessInfo.business.address}', paperWidth);

      for (var line in lines) {
        buffer.add(_encode(line));
        buffer.add(_newLine());
      }
    }

    buffer.add(_newLine());
    buffer.add(_encode('Thank you for your order!'));
    buffer.add(_newLine());
    buffer.add(_newLine());

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

  static Uint8List _newLine2() {
    // 0x0A is the ASCII value for Line Feed (LF),
    // which is the standard new line character on Unix-like systems (and the internet).
    // 0x0D is the ASCII value for Carriage Return (CR).
    // CR + LF (0x0D, 0x0A) is the standard new line for Windows/DOS.

    // If you need a more explicit/common sequence, use CR+LF:
    return Uint8List.fromList([0x0D, 0x0A]);

    // Alternatively, just a single Line Feed (LF) is often sufficient:
    // return Uint8List.fromList([0x0A]);
  }

  static String _dashes(int count) => '-' * count;
  static String _equals(int count) => '=' * count;
  // static String _dots(int count) => '.' * count;
  static void printLabelValueRightBold({
    required BytesBuilder buffer,
    required String label,
    required String value,
    required int totalWidth,
    required List<int> escBoldOn,
    required List<int> escBoldOff,
    required List<int> Function(String) encode,
  }) {
    final spaceCount = totalWidth - label.length - value.length;

    // Label (NORMAL)
    buffer.add(
      encode(label + (' ' * (spaceCount > 0 ? spaceCount : 1))),
    );

    // Value (BOLD)
    buffer.add(escBoldOn);
    buffer.add(encode(value));
    buffer.add(escBoldOff);
  }

  /// Format label with right-aligned value (like in the receipt image)
  static String _formatLabelValueRight(
      String label, String value, int totalWidth) {
    final availableSpace = totalWidth - label.length - value.length;
    if (availableSpace <= 0) {
      // If no space, truncate value
      final maxValueLen = totalWidth - label.length - 1;
      return '$label ${maxValueLen > 0 ? _truncate(value, maxValueLen) : ''}';
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
