import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenxglobal_pos/provider/printing_agant_provider.dart';

class PrinterSelectionWidget extends StatefulWidget {
  final bool selectKitchen;
  const PrinterSelectionWidget({super.key, this.selectKitchen = true});

  @override
  State<PrinterSelectionWidget> createState() => _PrinterSelectionWidgetState();
}

class _PrinterSelectionWidgetState extends State<PrinterSelectionWidget> {
  @override
  Widget build(BuildContext context) => Consumer<PrintingAgentProviderMobile>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Scanning for printers...'),
                  ],
                ),
              ),
            );
          }

          final available = provider.availablePrinters;
          final customerPrinter = provider.customerPrinter;
          final kotPrinter = provider.kotPrinter;

          // ✅ Remove duplicates by URL and create combined list
          final uniquePrinters = <String, dynamic>{};
          for (var printer in available) {
            uniquePrinters[printer.url] = printer;
          }

          // Add selected printers if they're not in the available list
          if (customerPrinter != null &&
              !uniquePrinters.containsKey(customerPrinter.url)) {
            uniquePrinters[customerPrinter.url] = customerPrinter;
          }
          if (kotPrinter != null &&
              !uniquePrinters.containsKey(kotPrinter.url)) {
            uniquePrinters[kotPrinter.url] = kotPrinter;
          }

          final printerList = uniquePrinters.values.toList();

          // Separate printers by type
          final networkPrinters =
              printerList.where((p) => !p.url.startsWith('usb:')).toList();
          final usbPrinters =
              printerList.where((p) => p.url.startsWith('usb:')).toList();

          // ✅ Validate selected values exist in list
          final customerValue = customerPrinter != null &&
                  uniquePrinters.containsKey(customerPrinter.url)
              ? customerPrinter.url
              : null;

          final kotValue =
              kotPrinter != null && uniquePrinters.containsKey(kotPrinter.url)
                  ? kotPrinter.url
                  : null;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning message
                  if (available.isEmpty &&
                      customerPrinter == null &&
                      kotPrinter == null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "No printers found. Please connect your printer via USB or network.",
                              style: TextStyle(color: Colors.orange.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Customer Printer Section
                  const Text(
                    "Customer Receipt Printer",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // None/Clear selection option
                        RadioListTile<String?>(
                          title: const Text("None"),
                          value: null,
                          groupValue: customerValue,
                          dense: true,
                          onChanged: (value) {
                            provider.selectCustomerPrinter(null);
                          },
                        ),

                        // USB Printers Section
                        if (usbPrinters.isNotEmpty) ...[
                          const Divider(height: 1),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            color: Colors.blue.shade50,
                            child: Row(
                              children: [
                                Icon(Icons.usb,
                                    size: 16, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  "USB Printers",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...usbPrinters.map((printer) {
                            return Column(
                              children: [
                                RadioListTile<String?>(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          printer.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          "USB",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    printer.location ?? 'USB Connected',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  value: printer.url,
                                  groupValue: customerValue,
                                  dense: true,
                                  onChanged: (value) {
                                    provider.selectCustomerPrinter(printer);
                                  },
                                ),
                                if (printer != usbPrinters.last)
                                  const Divider(height: 1),
                              ],
                            );
                          }).toList(),
                        ],

                        // Network Printers Section
                        if (networkPrinters.isNotEmpty) ...[
                          const Divider(height: 1),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            color: Colors.green.shade50,
                            child: Row(
                              children: [
                                Icon(Icons.wifi,
                                    size: 16, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  "Network Printers",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...networkPrinters.map((printer) {
                            return Column(
                              children: [
                                RadioListTile<String?>(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          printer.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          "Network",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    printer.location ?? 'Unknown location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  value: printer.url,
                                  groupValue: customerValue,
                                  dense: true,
                                  onChanged: (value) {
                                    provider.selectCustomerPrinter(printer);
                                  },
                                ),
                                if (printer != networkPrinters.last)
                                  const Divider(height: 1),
                              ],
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // KOT Printer Section
                  const Text(
                    "Kitchen Order Ticket (KOT) Printer",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // None/Clear selection option
                        RadioListTile<String?>(
                          title: const Text("None"),
                          value: null,
                          groupValue: kotValue,
                          dense: true,
                          onChanged: (value) {
                            provider.selectKOTPrinter(null);
                          },
                        ),

                        // USB Printers Section
                        if (usbPrinters.isNotEmpty) ...[
                          const Divider(height: 1),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            color: Colors.blue.shade50,
                            child: Row(
                              children: [
                                Icon(Icons.usb,
                                    size: 16, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  "USB Printers",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...usbPrinters.map((printer) {
                            return Column(
                              children: [
                                RadioListTile<String?>(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          printer.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          "USB",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    printer.location ?? 'USB Connected',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  value: printer.url,
                                  groupValue: kotValue,
                                  dense: true,
                                  onChanged: (value) {
                                    provider.selectKOTPrinter(printer);
                                  },
                                ),
                                if (printer != usbPrinters.last)
                                  const Divider(height: 1),
                              ],
                            );
                          }).toList(),
                        ],

                        // Network Printers Section
                        if (networkPrinters.isNotEmpty) ...[
                          const Divider(height: 1),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            color: Colors.green.shade50,
                            child: Row(
                              children: [
                                Icon(Icons.wifi,
                                    size: 16, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  "Network Printers",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...networkPrinters.map((printer) {
                            return Column(
                              children: [
                                RadioListTile<String?>(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          printer.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          "Network",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    printer.location ?? 'Unknown location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  value: printer.url,
                                  groupValue: kotValue,
                                  dense: true,
                                  onChanged: (value) {
                                    provider.selectKOTPrinter(printer);
                                  },
                                ),
                                if (printer != networkPrinters.last)
                                  const Divider(height: 1),
                              ],
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Refresh button with printer count
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: provider.loadPrinters,
                        icon: const Icon(Icons.refresh,
                            size: 16, color: Colors.blue),
                        label: const Text(
                          "Refresh Printers",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${usbPrinters.length} USB • ${networkPrinters.length} Network",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  // Show currently selected printers
                  if (customerPrinter != null || kotPrinter != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        //  color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 16, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Text(
                                "Currently Selected:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (customerPrinter != null)
                            Text(
                              "📄 Customer: ${customerPrinter.name} ${customerPrinter.url.startsWith('usb:') ? '(USB)' : '(${customerPrinter.location ?? customerPrinter.url})'}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          if (kotPrinter != null)
                            Text(
                              "🍳 KOT: ${kotPrinter.name} ${kotPrinter.url.startsWith('usb:') ? '(USB)' : '(${kotPrinter.location ?? kotPrinter.url})'}",
                              style: const TextStyle(fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
}
