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
                child: CircularProgressIndicator(),
              ),
            );
          }

          final available = provider.availablePrinters;
          final customerPrinter = provider.customerPrinter;
          final kotPrinter = provider.kotPrinter;

          // ✅ FIX: Remove duplicates by URL and create combined list
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

          // ✅ FIX: Validate selected values exist in list
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
                        const Divider(height: 1),
                        // Printer options
                        ...printerList.map((printer) {
                          return Column(
                            children: [
                              RadioListTile<String?>(
                                title: Text(
                                  printer.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
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
                              if (printer != printerList.last)
                                const Divider(height: 1),
                            ],
                          );
                        }).toList(),
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
                        const Divider(height: 1),
                        // Printer options
                        ...printerList.map((printer) {
                          return Column(
                            children: [
                              RadioListTile<String?>(
                                title: Text(
                                  printer.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
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
                              if (printer != printerList.last)
                                const Divider(height: 1),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  // // Customer Printer Dropdown
                  // const Text(
                  //   "Customer Receipt Printer",
                  //   style: TextStyle(fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 8),
                  // DropdownButtonFormField<String>(
                  //   decoration: const InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     isDense: true,
                  //   ),
                  //   value: customerValue,
                  //   items: [
                  //     const DropdownMenuItem<String>(
                  //       value: null,
                  //       child: Text("Select Customer Printer"),
                  //     ),
                  //     //  FIX: Use unique printer list
                  //     ...printerList.map(
                  //       (p) => DropdownMenuItem(
                  //         value: p.url,
                  //         child: Text(
                  //           "${p.name} • ${p.location ?? 'Unknown'}",
                  //           overflow: TextOverflow.ellipsis,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  //   onChanged: (url) {
                  //     if (url == null) {
                  //       provider.selectCustomerPrinter(null);
                  //     } else {
                  //       final printer = printerList.firstWhere(
                  //         (p) => p.url == url,
                  //         orElse: () => printerList.first,
                  //       );
                  //       provider.selectCustomerPrinter(printer);
                  //     }
                  //   },
                  // ),
                  // const SizedBox(height: 16),
                  // // KOT Printer Dropdown
                  // const Text(
                  //   "Kitchen Order Ticket (KOT) Printer",
                  //   style: TextStyle(fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 8),
                  // DropdownButtonFormField<String>(
                  //   decoration: const InputDecoration(
                  //     border: OutlineInputBorder(),
                  //     isDense: true,
                  //   ),
                  //   value: kotValue,
                  //   items: [
                  //     const DropdownMenuItem<String>(
                  //       value: null,
                  //       child: Text("Select KOT Printer"),
                  //     ),
                  //     // ✅ FIX: Use unique printer list
                  //     ...printerList.map(
                  //       (p) => DropdownMenuItem(
                  //         value: p.url,
                  //         child: Text(
                  //           "${p.name} • ${p.location ?? 'Unknown'}",
                  //           overflow: TextOverflow.ellipsis,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  //   onChanged: (url) {
                  //     if (url == null) {
                  //       provider.selectKOTPrinter(null);
                  //     } else {
                  //       final printer = printerList.firstWhere(
                  //         (p) => p.url == url,
                  //         orElse: () => printerList.first,
                  //       );
                  //       provider.selectKOTPrinter(printer);
                  //     }
                  //   },
                  // ),
                  // const SizedBox(height: 16),

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
                        "${printerList.length} printer(s) found",
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
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Currently Selected:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (customerPrinter != null)
                            Text(
                              "📄 Customer: ${customerPrinter.name} (${customerPrinter.location ?? customerPrinter.url})",
                              style: const TextStyle(fontSize: 13),
                            ),
                          if (kotPrinter != null)
                            Text(
                              "🍳 KOT: ${kotPrinter.name} (${kotPrinter.location ?? kotPrinter.url})",
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
