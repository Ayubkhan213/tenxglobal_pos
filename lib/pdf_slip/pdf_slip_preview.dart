import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart' as pf;
import 'package:provider/provider.dart';
import 'package:tenxglobal_pos/core/services/hive_services/business_info_service.dart';
import 'package:tenxglobal_pos/data/models/order_response_model.dart';
import 'package:tenxglobal_pos/presentation/provider/printing_agant_provider.dart';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class PdfReceiptPrinter {
  ///======================================================
  /// PREVIEW KOT IN DIALOG (FOR DEBUGGING)
  ///======================================================
  static Future<void> previewKOTDialog({
    required BuildContext context,
    required String orderId,
    String orderType = '',
    List<OrderItem>? items,
  }) async {
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _PdfPreviewDialog(
          title: 'KOT Preview #$orderId',
          pdfGenerator: (paperWidth) => _generateKotPDF(
            orderId: orderId,
            orderType: orderType,
            items: items,
            paperWidthMM: paperWidth,
          ),
          paperWidthMM: 80.0,
        ),
      );
    } catch (e) {
      _showMessage(context, "Preview failed: $e", Colors.red);
    }
  }

  ///======================================================
  /// PREVIEW KOT BEFORE PRINTING (FULLSCREEN)
  ///======================================================
  static Future<void> previewKOT({
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

      // Detect paper width
      final paperWidth = provider.kotPrinter != null
          ? _detectPaperWidth(provider.kotPrinter!.name)
          : 80.0; // Default 80mm

      final pdf = await _generateKotPDF(
        orderId: orderId,
        orderType: orderType,
        items: items,
        paperWidthMM: paperWidth,
      );

      // Show preview
      await pf.Printing.layoutPdf(
        onLayout: (_) async => pdf.save(),
        name: 'KOT_Preview_$orderId',
        format: _getPdfFormat(paperWidth),
      );
    } catch (e) {
      _showMessage(context, "Preview failed: $e", Colors.red);
    }
  }

  ///======================================================
  /// PREVIEW RECEIPT IN DIALOG (FOR DEBUGGING)
  ///======================================================
  static Future<void> previewReceiptDialog({
    required BuildContext context,
    required OrderResponse orderResponse,
  }) async {
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _PdfPreviewDialog(
          title: 'Receipt Preview #${orderResponse.order?.id ?? "N/A"}',
          pdfGenerator: (paperWidth) => _generateReceiptPDF(
            orderResponse,
            paperWidthMM: paperWidth,
          ),
          paperWidthMM: 80.0,
        ),
      );
    } catch (e) {
      _showMessage(context, "Preview failed: $e", Colors.red);
    }
  }

  // ///======================================================
  // /// PREVIEW RECEIPT BEFORE PRINTING (FULLSCREEN)
  // ///======================================================
  // static Future<void> previewReceipt({
  //   required BuildContext context,
  //   required OrderResponse orderResponse,
  // }) async {
  //   try {
  //     final provider = Provider.of<PrintingAgentProviderMobile>(
  //       context,
  //       listen: false,
  //     );

  //     // Detect paper width
  //     final paperWidth = provider.customerPrinter != null
  //         ? _detectPaperWidth(provider.customerPrinter!.name)
  //         : 80.0; // Default 80mm

  //     final pdf = await _generateReceiptPDF(
  //       orderResponse,
  //       paperWidthMM: paperWidth,
  //     );

  //     // Show preview
  //     await pf.Printing.layoutPdf(
  //       onLayout: (_) async => pdf.save(),
  //       name: 'Receipt_Preview_${orderResponse.order?.id}',
  //       format: _getPdfFormat(paperWidth),
  //     );
  //   } catch (e) {
  //     _showMessage(context, "Preview failed: $e", Colors.red);
  //   }
  // }

  ///======================================================
  /// PRINT KOT (SILENT - NO PREVIEW)
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

      final paperWidth = _detectPaperWidth(provider.kotPrinter!.name);

      final pdf = await _generateKotPDF(
        orderId: orderId,
        orderType: orderType,
        items: items,
        paperWidthMM: paperWidth,
      );

      final pdfBytes = await pdf.save();

      // Silent print
      await pf.Printing.directPrintPdf(
        printer: pf.Printer(
          name: provider.kotPrinter!.name,
          url: provider.kotPrinter!.url,
        ),
        onLayout: (_) async => pdfBytes,
        name: 'KOT_$orderId',
        format: _getPdfFormat(paperWidth),
      );

      _showMessage(context, "✅ KOT printed successfully", Colors.green);
    } catch (e) {
      _showMessage(context, "❌ KOT printing failed: $e", Colors.red);
    }
  }

  ///======================================================
  /// PRINT RECEIPT - with optional preview dialog
  ///======================================================
  static Future<void> printReceipt({
    required BuildContext context,
    required OrderResponse orderResponse,
    bool showPreviewDialog = false, // ✅ NEW: Show dialog before printing
  }) async {
    try {
      // ✅ If preview dialog requested, show it first
      if (showPreviewDialog) {
        await previewReceiptDialog(
          context: context,
          orderResponse: orderResponse,
        );
        return; // Exit after preview
      }

      // ✅ Silent print (no dialog)
      final provider = Provider.of<PrintingAgentProviderMobile>(
        context,
        listen: false,
      );

      if (provider.customerPrinter == null) {
        throw Exception("Customer printer is not configured");
      }

      final paperWidth = _detectPaperWidth(provider.customerPrinter!.name);

      final pdf = await _generateReceiptPDF(
        orderResponse,
        paperWidthMM: paperWidth,
      );

      final pdfBytes = await pdf.save();

      // Silent print
      await pf.Printing.directPrintPdf(
        printer: pf.Printer(
          name: provider.customerPrinter!.name,
          url: provider.customerPrinter!.url,
        ),
        onLayout: (_) async => pdfBytes,
        name: 'Receipt_${orderResponse.order?.id}',
        format: _getPdfFormat(paperWidth),
      );

      _showMessage(context, "✅ Receipt printed successfully", Colors.green);
    } catch (e) {
      _showMessage(context, "❌ Receipt printing failed: $e", Colors.red);
    }
  }

  ///======================================================
  /// DETECT PAPER WIDTH (in MM)
  ///======================================================
  static double _detectPaperWidth(String printerName) {
    final name = printerName.toLowerCase();

    if (name.contains('52') || name.contains('52mm')) {
      return 52.0;
    } else if (name.contains('58') || name.contains('58mm')) {
      return 58.0;
    } else if (name.contains('80') || name.contains('80mm')) {
      return 80.0;
    } else if (name.contains('90') || name.contains('90mm')) {
      return 90.0;
    }

    return 80.0; // Default
  }

  ///======================================================
  /// GET PDF FORMAT FOR PAPER WIDTH
  ///======================================================
  static PdfPageFormat _getPdfFormat(double widthMM) {
    if (widthMM <= 52) {
      return const PdfPageFormat(52 * PdfPageFormat.mm, double.infinity);
    } else if (widthMM <= 58) {
      return const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity);
    } else if (widthMM <= 80) {
      return PdfPageFormat.roll80;
    } else {
      // 90mm
      return const PdfPageFormat(90 * PdfPageFormat.mm, double.infinity);
    }
  }

  ///======================================================
  /// GENERATE KOT PDF - ADAPTIVE DESIGN
  ///======================================================
  static Future<pw.Document> _generateKotPDF({
    required String orderId,
    String orderType = '',
    List<OrderItem>? items,
    double paperWidthMM = 80.0,
  }) async {
    final pdf = pw.Document();
    final font = await pf.PdfGoogleFonts.robotoRegular();
    final boldFont = await pf.PdfGoogleFonts.robotoBold();

    // Adjust font sizes based on paper width
    final titleSize = paperWidthMM >= 70 ? 16.0 : 14.0;
    final headerSize = paperWidthMM >= 70 ? 12.0 : 10.0;
    final bodySize = paperWidthMM >= 70 ? 10.0 : 8.0;

    pdf.addPage(
      pw.Page(
        pageFormat: _getPdfFormat(paperWidthMM),
        margin: const pw.EdgeInsets.all(8),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ========== HEADER ==========
              pw.Center(
                child: pw.Text(
                  'KITCHEN ORDER TICKET',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: titleSize,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 8),

              // ========== ORDER INFO ==========
              pw.Text(
                'Order #$orderId',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: headerSize,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Type: $orderType',
                style: pw.TextStyle(font: font, fontSize: bodySize),
              ),
              pw.Text(
                'Time: ${intl.DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(font: font, fontSize: bodySize),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 4),

              // ========== ITEMS ==========
              pw.Text(
                'ITEMS:',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: headerSize,
                ),
              ),
              pw.SizedBox(height: 4),

              if (items != null && items.isNotEmpty)
                ...items.map((item) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${item.quantity}x ${item.title}',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: bodySize + 1,
                          ),
                        ),
                        if (item.note != null && item.note!.isNotEmpty)
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 12, top: 2),
                            child: pw.Text(
                              '⚠ ${item.note}',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: bodySize - 1,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList()
              else
                pw.Text(
                  'No items',
                  style: pw.TextStyle(font: font, fontSize: bodySize),
                ),

              pw.Divider(thickness: 2),
              pw.SizedBox(height: 8),

              // ========== FOOTER ==========
              pw.Center(
                child: pw.Text(
                  'Please prepare this order',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: bodySize,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Convert image bytes to black & white (for thermal printer)
  static Uint8List convertToBW(Uint8List inputBytes) {
    final original = img.decodeImage(inputBytes);
    if (original == null) return inputBytes;

    final bw = img.grayscale(original);
    return Uint8List.fromList(img.encodePng(bw));
  }

  static Future<pw.ImageProvider?> getBWLogo(String? url) async {
    if (url == null || url.isEmpty) return null;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final bwBytes = convertToBW(bytes);
        return pw.MemoryImage(bwBytes);
      }
    } catch (e) {
      debugPrint('Failed to load logo: $e');
    }

    return null;
  }

  ///======================================================
  /// GENERATE CUSTOMER RECEIPT PDF - ADAPTIVE DESIGN
  ///======================================================
  static Future<pw.Document> _generateReceiptPDF(
    OrderResponse orderResponse, {
    double paperWidthMM = 80.0,
  }) async {
    final businessInfo = await BusinessInfoBoxService.getBusinessInfo();
    final order = orderResponse.order;
    final pdf = pw.Document();
    print("bussiness logo url ${businessInfo?.business.logoUrl}");
    final logo = await getBWLogo(businessInfo?.business.logoUrl);
    final font = await pw.Font.helvetica();
    final boldFont = await pw.Font.helveticaBold();
    final times = await pw.Font.times();
    final safeItems = orderResponse.order?.items ?? [];

    double subtotal = (safeItems).fold(
      0,
      (prev, item) => prev + ((item.quantity ?? 0) * (item.price ?? 0)),
    );
    double totalPrice = subtotal +
        (order?.deliveryCharges ?? 0.0) +
        (order?.tax ?? 0.0) -
        (order?.salesDiscount ?? 0.0) -
        (order?.approvedDiscounts ?? 0.0);
    // Adjust sizes based on paper width
    final titleSize = paperWidthMM >= 70 ? 16.0 : 14.0;
    // final headerSize = paperWidthMM >= 70 ? 12.0 : 10.0;
    // final bodySize = paperWidthMM >= 70 ? 10.0 : 8.0;
    final smallSize = paperWidthMM >= 70 ? 8.0 : 7.0;
    // final isNarrow = paperWidthMM <= 58;

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          72 * PdfPageFormat.mm,
          double.infinity,
        ),
        margin: const pw.EdgeInsets.all(8),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (businessInfo?.business.logoUrl != null)
                pw.Center(
                    child: pw.Text(
                  '${'businessInfo?.business.logoUrl'}',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: titleSize,
                  ),
                )),
              pw.SizedBox(height: 5),
              // ========== BUSINESS HEADER ==========
              pw.Center(
                child: pw.Text(
                  businessInfo?.business.businessName ?? 'BUSINESS NAME',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: titleSize,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Order ID: #${order?.id}',
                  style: pw.TextStyle(fontSize: 9, font: font),
                ),
              ),
              if (businessInfo?.business.phone != null)
                pw.Center(
                  child: pw.Text(
                    'Tel: ${businessInfo!.business.phone}',
                    style: pw.TextStyle(font: font, fontSize: smallSize),
                  ),
                ),
              pw.Center(
                child: pw.Text(
                  'Date: ${intl.DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 9, font: times),
                ),
              ),
              pw.SizedBox(height: 5),
              dottedBorder(),
              // if (businessInfo?.business.address != null)
              //   pw.Center(
              //     child: pw.Text(
              //       businessInfo!.business.address!,
              //       style: pw.TextStyle(font: font, fontSize: smallSize),
              //       textAlign: pw.TextAlign.center,
              //     ),
              //   ),
              _labelValue(
                'Payment Type',
                order?.payments?.first.paymentType ?? 'Cash',
                font,
              ),
              _labelValue(
                'Order Type',
                order?.orderType ?? 'Eatin',
                font,
              ),
              _labelValue(
                'Customer Name',
                order?.customerName ?? 'Eat in',
                font,
              ),
              if (order?.customerPhone != null &&
                  order?.customerPhone?.trim() != '')
                _labelValue(
                  'Contact Number',
                  order?.customerPhone ?? '',
                  font,
                ),
              pw.SizedBox(height: 5),
              dottedBorder(),
              pw.SizedBox(height: 5),

              pw.Padding(
                padding: pw.EdgeInsets.only(right: 4.0),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Item',
                        style: pw.TextStyle(font: boldFont, fontSize: 7.0),
                      ),
                    ),
                    pw.SizedBox(width: 40),
                    pw.Text(
                      'Qty',
                      style: pw.TextStyle(fontSize: 7.0, font: boldFont),
                    ),
                    pw.SizedBox(width: 40),
                    pw.Text(
                      'Price',
                      style: pw.TextStyle(fontSize: 7.0, font: boldFont),
                    ),
                  ],
                ),
              ),
              ...safeItems
                  .map(
                    (item) => pw.Column(
                      children: [
                        pw.SizedBox(height: 5),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                item.title ?? '',
                                style: pw.TextStyle(fontSize: 7.0),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Center(
                                child: pw.Text(
                                  'x${item.quantity ?? 0}',
                                  style: pw.TextStyle(fontSize: 7.0),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  '£${item.price!.toStringAsFixed(2)}',
                                  style: pw.TextStyle(fontSize: 7.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  .toList(),
              dottedBorder(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 5),
                  _labelValue(
                    'Subtotal',
                    '£${order?.subTotal?.toStringAsFixed(2)}',
                    font,
                  ),
                  if ((order?.approvedDiscounts ?? 0.0) > 0.0)
                    _labelValue(
                      'Discount',
                      '£${(order?.approvedDiscounts ?? 0.0).toStringAsFixed(2)}',
                      font,
                    ),
                  if ((order?.salesDiscount ?? 0.0) > 0.0)
                    _labelValue(
                      'sale',
                      '-£${order?.salesDiscount!.toStringAsFixed(2)}',
                      font,
                    ),
                  if ((order?.promoDiscount ?? 0.0) > 0.0)
                    _labelValue(
                      'Promo Discount',
                      '-£${order?.promoDiscount!.toStringAsFixed(2)}',
                      font,
                    ),
                  if (orderResponse.type == 'Delivery')
                    _labelValue(
                      'Delivery Charges',
                      '${order?.deliveryCharges?.toStringAsFixed(0)}%',
                      font,
                    ),
                  _labelValue(
                    'Total Price',
                    '£${order?.totalAmount?.toStringAsFixed(2)}',
                    font,
                  ),
                  dottedBorder(),
                  pw.SizedBox(height: 5),
                  _labelFooter(
                    'Email: ${businessInfo?.user.email ?? ''}',
                    font,
                  ),
                  _labelFooter(
                    'Location: ${businessInfo?.business.address ?? ''}',
                    font,
                  ),
                  pw.Center(
                    child: pw.Text(
                      'Thank you for your order!',
                      style: pw.TextStyle(font: font, fontSize: 8),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  ///======================================================
  /// HELPER: Build Total Line
  ///======================================================
  static pw.Widget _buildTotalLine(
    String label,
    double amount,
    pw.Font font,
    double fontSize,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(font: font, fontSize: fontSize),
          ),
          pw.Text(
            '£${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(font: font, fontSize: fontSize),
          ),
        ],
      ),
    );
  }

  static pw.Widget dottedBorder() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 2),
      height: 1.1,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.black,
            width: 1,
            style: pw.BorderStyle.dashed,
          ),
        ),
      ),
    );
  }

  static pw.Widget _itemRow(OrderItem item, pw.Font font) {
    final name = item.title ?? '';
    final qty = item.quantity ?? 0;
    final price = item.price ?? 0;
    final total = (qty * price).toStringAsFixed(2);

    return pw.Padding(
      padding: pw.EdgeInsets.only(right: 4.0),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(name, style: pw.TextStyle(font: font, fontSize: 9)),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              qty.toString(),
              style: pw.TextStyle(font: font, fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              price.toStringAsFixed(2),
              style: pw.TextStyle(font: font, fontSize: 9),
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              total,
              style: pw.TextStyle(font: font, fontSize: 9),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _labelValue(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2, right: 4.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, font: font)),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, font: font)),
        ],
      ),
    );
  }

  static pw.Widget _labelFooter(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 6, font: font),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  static void _showMessage(BuildContext context, String msg, Color color) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
    } else {
      debugPrint('⚠️ Snackbar skipped: context not mounted. Message: $msg');
    }
  }
}

//======================================================
/// INTERNAL PREVIEW DIALOG WIDGET
///======================================================
class _PdfPreviewDialog extends StatefulWidget {
  final Future<pw.Document> Function(double paperWidth) pdfGenerator;
  final String title;
  final double paperWidthMM;
  final VoidCallback? onDirectPrint; // ✅ NEW: Callback for direct print

  const _PdfPreviewDialog({
    Key? key,
    required this.pdfGenerator,
    required this.title,
    this.paperWidthMM = 80.0,
    this.onDirectPrint,
  }) : super(key: key);

  @override
  State<_PdfPreviewDialog> createState() => _PdfPreviewDialogState();
}

class _PdfPreviewDialogState extends State<_PdfPreviewDialog> {
  late Future<Uint8List> _pdfFuture;
  double _currentWidth = 80.0;

  @override
  void initState() {
    super.initState();
    _currentWidth = widget.paperWidthMM;
    _loadPdf();
  }

  void _loadPdf() {
    _pdfFuture = widget.pdfGenerator(_currentWidth).then((doc) => doc.save());
  }

  void _reloadWithWidth(double width) {
    setState(() {
      _currentWidth = width;
      _loadPdf();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[100],
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🖨️ Paper Width: ${_currentWidth.toInt()}mm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildWidthChip(52.0, '52mm'),
                            _buildWidthChip(58.0, '58mm'),
                            _buildWidthChip(80.0, '80mm'),
                            _buildWidthChip(90.0, '90mm'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // PDF Preview
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FutureBuilder<Uint8List>(
                    future: _pdfFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Generating PDF...',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 64,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Error generating PDF',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return Center(child: Text('No PDF data'));
                      }

                      return pf.PdfPreview(
                        build: (_) async => snapshot.data!,
                        allowSharing: true,
                        allowPrinting: true,
                        canChangePageFormat: false,
                        canChangeOrientation: false,
                        canDebug: false,
                        pdfFileName: widget.title.replaceAll(' ', '_'),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '💡 Change paper width above to test different sizes',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => _reloadWithWidth(_currentWidth),
                    icon: Icon(Icons.refresh),
                    label: Text('Reload'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.check),
                    label: Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidthChip(double width, String label) {
    final isSelected = _currentWidth == width;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _reloadWithWidth(width);
        }
      },
      selectedColor: Colors.blue[700],
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
