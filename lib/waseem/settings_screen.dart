// import 'package:flutter/material.dart';
// import 'printer_service.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool _loading = false;

//   @override
//   Widget build(BuildContext context) {
//     final printers = PrinterService.instance.availablePrinters;
//     final customerPrinter = PrinterService.instance.customerPrinter;
//     final kitchenPrinter = PrinterService.instance.kitchenPrinter;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Printing Settings'),
//         centerTitle: true,
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : printers.isEmpty
//               ? const Center(
//                   child: Text(
//                     'No printers found.\n(TODO: implement discovery)',
//                     textAlign: TextAlign.center,
//                   ),
//                 )
//               : Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: ListView(
//                     children: [
//                       const Text(
//                         'Customer Receipt Printer',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Card(
//                         child: Column(
//                           children: printers
//                               .map(
//                                 (p) => RadioListTile<String>(
//                                   value: p.id,
//                                   groupValue: customerPrinter?.id,
//                                   title: Text(p.name),
//                                   subtitle: Text(p.type.toUpperCase()),
//                                   onChanged: (value) async {
//                                     setState(() => _loading = true);
//                                     await PrinterService.instance
//                                         .setCustomerPrinter(p);
//                                     setState(() => _loading = false);
//                                   },
//                                 ),
//                               )
//                               .toList(),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       const Text(
//                         'Kitchen Printer (KOT)',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Card(
//                         child: Column(
//                           children: printers
//                               .map(
//                                 (p) => RadioListTile<String>(
//                                   value: p.id,
//                                   groupValue: kitchenPrinter?.id,
//                                   title: Text(p.name),
//                                   subtitle: Text(p.type.toUpperCase()),
//                                   onChanged: (value) async {
//                                     setState(() => _loading = true);
//                                     await PrinterService.instance
//                                         .setKitchenPrinter(p);
//                                     setState(() => _loading = false);
//                                   },
//                                 ),
//                               )
//                               .toList(),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       Row(
//                         children: [
//                           ElevatedButton.icon(
//                             onPressed: () async {
//                               // Simple test print for Customer
//                               setState(() => _loading = true);
//                               await PrinterService.instance
//                                   .printCustomerReceipt(
//                                 {
//                                   'test': true,
//                                   'message': 'Test customer receipt'
//                                 },
//                               );
//                               setState(() => _loading = false);
//                             },
//                             icon: const Icon(Icons.print),
//                             label: const Text('Test Customer'),
//                           ),
//                           const SizedBox(width: 12),
//                           ElevatedButton.icon(
//                             onPressed: () async {
//                               // Simple test print for Kitchen
//                               setState(() => _loading = true);
//                               await PrinterService.instance.printKitchenOrder(
//                                 {'test': true, 'message': 'Test kitchen KOT'},
//                               );
//                               setState(() => _loading = false);
//                             },
//                             icon: const Icon(Icons.print_outlined),
//                             label: const Text('Test Kitchen'),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//     );
//   }
// }
