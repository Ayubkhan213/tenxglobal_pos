// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:tenxglobal_pos/core/services/customer_display_service.dart';
// // import 'package:tenxglobal_pos/provider/customer_provider.dart';

// // class RightSideMenuContent extends StatelessWidget {
// //   final VoidCallback onClose;

// //   const RightSideMenuContent({
// //     super.key,
// //     required this.onClose,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return SafeArea(
// //       child: Consumer<CustomerProvider>(
// //         builder: (context, provider, _) {
// //           final order = provider.orders == null || provider.orders.isEmpty
// //               ? null
// //               : provider.orders.first;
// //           final items = order == null ? [] : order.order.items ?? [];

// //           return Column(
// //             children: [
// //               // Header
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFF1B1670),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black.withValues(alpha: 0.1),
// //                       blurRadius: 4,
// //                       offset: const Offset(0, 2),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     // Order Type Badge
// //                     Container(
// //                       padding: const EdgeInsets.all(8.0),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(16.0),
// //                       ),
// //                       child: Text(
// //                         order != null ? order.order.orderType : 'Takeaway',
// //                         style: const TextStyle(
// //                           color: Color(0xFF1B1670),
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 14,
// //                         ),
// //                       ),
// //                     ),
// //                     ElevatedButton.icon(
// //                       onPressed: () {
// //                         CustomerDisplayService.show(
// //                           title: 'Test Customer Display',
// //                           total: 100.0,
// //                           items: [],
// //                         );
// //                         Navigator.of(context).pop();
// //                       },
// //                       icon: const Icon(Icons.add),
// //                       label: const Text('Add Dummy Order'),
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFF1B1670),
// //                         foregroundColor: Colors.white,
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 24,
// //                           vertical: 12,
// //                         ),
// //                       ),
// //                     ),

// //                     // Action Buttons
// //                     Row(
// //                       children: [
// //                         // Add Dummy Data Button
// //                         // IconButton(
// //                         //   icon:
// //                         //       const Icon(Icons.add_circle, color: Colors.white),
// //                         //   tooltip: 'Add Dummy Order',
// //                         //   onPressed: () => _addDummyData(context),
// //                         // ),
// //                         // const SizedBox(width: 8),
// //                         // Close Button
// //                         IconButton(
// //                           icon: const Icon(Icons.close, color: Colors.white),
// //                           onPressed: onClose,
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               const SizedBox(height: 20.0),

// //               // Content
// //               Expanded(
// //                 child: items.isEmpty
// //                     ? Center(
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             const Text(
// //                               'No order items',
// //                               style: TextStyle(
// //                                 fontSize: 16,
// //                                 color: Colors.black54,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 16),
// //                             ElevatedButton.icon(
// //                               onPressed: () {
// //                                 CustomerDisplayService.show(
// //                                   title: 'Test Customer Display',
// //                                   total: 100.0,
// //                                   items: [],
// //                                 );
// //                                 Navigator.of(context).pop();
// //                               },
// //                               icon: const Icon(Icons.add),
// //                               label: const Text('Add Dummy Order'),
// //                               style: ElevatedButton.styleFrom(
// //                                 backgroundColor: const Color(0xFF1B1670),
// //                                 foregroundColor: Colors.white,
// //                                 padding: const EdgeInsets.symmetric(
// //                                   horizontal: 24,
// //                                   vertical: 12,
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       )
// //                     : Padding(
// //                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             // Customer Section
// //                             const Text(
// //                               'Customer',
// //                               style: TextStyle(
// //                                 fontSize: 15.0,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: Colors.black87,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 8.0),
// //                             Container(
// //                               width: double.infinity,
// //                               padding: const EdgeInsets.all(12.0),
// //                               decoration: BoxDecoration(
// //                                 color: Colors.grey[50],
// //                                 borderRadius: BorderRadius.circular(8.0),
// //                                 border: Border.all(
// //                                   width: 1,
// //                                   color: Colors.grey.shade300,
// //                                 ),
// //                               ),
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Text(
// //                                     order != null
// //                                         ? order.order.customer
// //                                         : 'Walk-in',
// //                                     style: const TextStyle(
// //                                       fontWeight: FontWeight.w600,
// //                                       fontSize: 15,
// //                                       color: Colors.black87,
// //                                     ),
// //                                   ),
// //                                   if (order != null &&
// //                                       order.order.phoneNumber.isNotEmpty)
// //                                     Padding(
// //                                       padding: const EdgeInsets.only(top: 4.0),
// //                                       child: Text(
// //                                         order.order.phoneNumber,
// //                                         style: const TextStyle(
// //                                           fontSize: 13,
// //                                           color: Colors.black54,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                 ],
// //                               ),
// //                             ),
// //                             const SizedBox(height: 16.0),

// //                             // Items List
// //                             Expanded(
// //                               child: Container(
// //                                 padding: const EdgeInsets.all(12.0),
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.white,
// //                                   borderRadius: BorderRadius.circular(12.0),
// //                                   border: Border.all(
// //                                     width: 1,
// //                                     color: Colors.grey.shade300,
// //                                   ),
// //                                 ),
// //                                 child: ListView.separated(
// //                                   itemCount: items.length,
// //                                   separatorBuilder: (_, __) => const Divider(
// //                                     thickness: 0.5,
// //                                     height: 24,
// //                                   ),
// //                                   itemBuilder: (context, index) {
// //                                     final item = items[index];
// //                                     return Row(
// //                                       crossAxisAlignment:
// //                                           CrossAxisAlignment.start,
// //                                       children: [
// //                                         ClipRRect(
// //                                           borderRadius:
// //                                               BorderRadius.circular(8),
// //                                           child: Image.network(
// //                                             item.img,
// //                                             height: 50,
// //                                             width: 50,
// //                                             fit: BoxFit.cover,
// //                                             errorBuilder:
// //                                                 (context, error, stack) {
// //                                               return Container(
// //                                                 height: 50,
// //                                                 width: 50,
// //                                                 decoration: BoxDecoration(
// //                                                   color: Colors.grey[200],
// //                                                   borderRadius:
// //                                                       BorderRadius.circular(8),
// //                                                 ),
// //                                                 child: const Icon(
// //                                                   Icons.fastfood,
// //                                                   size: 30,
// //                                                   color: Colors.grey,
// //                                                 ),
// //                                               );
// //                                             },
// //                                           ),
// //                                         ),
// //                                         const SizedBox(width: 12),

// //                                         // Name and details
// //                                         Expanded(
// //                                           child: Column(
// //                                             crossAxisAlignment:
// //                                                 CrossAxisAlignment.start,
// //                                             children: [
// //                                               Text(
// //                                                 item.title ?? '',
// //                                                 style: const TextStyle(
// //                                                   fontWeight: FontWeight.w600,
// //                                                   fontSize: 14,
// //                                                   color: Colors.black87,
// //                                                 ),
// //                                               ),
// //                                               if (item.variantName != null)
// //                                                 Padding(
// //                                                   padding:
// //                                                       const EdgeInsets.only(
// //                                                           top: 2.0),
// //                                                   child: Text(
// //                                                     "Variant: ${item.variantName}",
// //                                                     style: const TextStyle(
// //                                                       fontSize: 12,
// //                                                       color: Colors.black54,
// //                                                     ),
// //                                                   ),
// //                                                 ),
// //                                               if (item.addons.isNotEmpty)
// //                                                 Padding(
// //                                                   padding:
// //                                                       const EdgeInsets.only(
// //                                                           top: 4.0),
// //                                                   child: Wrap(
// //                                                     spacing: 4,
// //                                                     runSpacing: 4,
// //                                                     children: item.addons
// //                                                         .map<Widget>((addon) {
// //                                                       return Container(
// //                                                         padding:
// //                                                             const EdgeInsets
// //                                                                 .symmetric(
// //                                                           horizontal: 8,
// //                                                           vertical: 3,
// //                                                         ),
// //                                                         decoration:
// //                                                             BoxDecoration(
// //                                                           color:
// //                                                               Colors.blue[50],
// //                                                           borderRadius:
// //                                                               BorderRadius
// //                                                                   .circular(4),
// //                                                           border: Border.all(
// //                                                             color: Colors
// //                                                                 .blue[200]!,
// //                                                             width: 0.5,
// //                                                           ),
// //                                                         ),
// //                                                         child: Text(
// //                                                           '${addon.name} (+£${addon.price.toStringAsFixed(2)})',
// //                                                           style:
// //                                                               const TextStyle(
// //                                                             fontSize: 11,
// //                                                             color:
// //                                                                 Colors.black87,
// //                                                             fontWeight:
// //                                                                 FontWeight.w500,
// //                                                           ),
// //                                                         ),
// //                                                       );
// //                                                     }).toList(),
// //                                                   ),
// //                                                 ),
// //                                             ],
// //                                           ),
// //                                         ),

// //                                         const SizedBox(width: 8),

// //                                         // Quantity and Price
// //                                         Column(
// //                                           crossAxisAlignment:
// //                                               CrossAxisAlignment.end,
// //                                           children: [
// //                                             Container(
// //                                               padding:
// //                                                   const EdgeInsets.symmetric(
// //                                                 horizontal: 10,
// //                                                 vertical: 6,
// //                                               ),
// //                                               decoration: BoxDecoration(
// //                                                 color: const Color(0xFF1B1670),
// //                                                 borderRadius:
// //                                                     BorderRadius.circular(20),
// //                                               ),
// //                                               child: Text(
// //                                                 'x${item.qty ?? 0}',
// //                                                 style: const TextStyle(
// //                                                   fontSize: 12,
// //                                                   fontWeight: FontWeight.bold,
// //                                                   color: Colors.white,
// //                                                 ),
// //                                               ),
// //                                             ),
// //                                             const SizedBox(height: 6),
// //                                             Text(
// //                                               '£${item.price?.toStringAsFixed(2) ?? '0.00'}',
// //                                               style: const TextStyle(
// //                                                 fontWeight: FontWeight.bold,
// //                                                 fontSize: 15,
// //                                                 color: Colors.black87,
// //                                               ),
// //                                             ),
// //                                           ],
// //                                         ),
// //                                       ],
// //                                     );
// //                                   },
// //                                 ),
// //                               ),
// //                             ),

// //                             const SizedBox(height: 16.0),

// //                             // Totals Section
// //                             Container(
// //                               padding: const EdgeInsets.all(16.0),
// //                               decoration: BoxDecoration(
// //                                 color: Colors.grey[50],
// //                                 borderRadius: BorderRadius.circular(12.0),
// //                                 border: Border.all(
// //                                   width: 1,
// //                                   color: Colors.grey.shade300,
// //                                 ),
// //                               ),
// //                               child: Column(
// //                                 children: [
// //                                   _buildTotalRow(
// //                                       'Subtotal', order?.order.subtotal),
// //                                   const SizedBox(height: 8.0),
// //                                   _buildTotalRow('Tax', order?.order.tax),
// //                                   const SizedBox(height: 8.0),
// //                                   _buildTotalRow(
// //                                       'Service', order?.order.serviceCharges),
// //                                   const SizedBox(height: 8.0),
// //                                   _buildTotalRow(
// //                                       'Delivery', order?.order.deliveryCharges),
// //                                   const SizedBox(height: 8.0),
// //                                   _buildTotalRow(
// //                                     'Sale Discount',
// //                                     order?.order.saleDiscount,
// //                                     isNegative: true,
// //                                   ),
// //                                   const Padding(
// //                                     padding:
// //                                         EdgeInsets.symmetric(vertical: 8.0),
// //                                     child: Divider(thickness: 1),
// //                                   ),
// //                                   Row(
// //                                     mainAxisAlignment:
// //                                         MainAxisAlignment.spaceBetween,
// //                                     children: [
// //                                       const Text(
// //                                         'Total',
// //                                         style: TextStyle(
// //                                           fontSize: 18.0,
// //                                           fontWeight: FontWeight.bold,
// //                                           color: Colors.black87,
// //                                         ),
// //                                       ),
// //                                       Text(
// //                                         order != null
// //                                             ? '£${order.order.total.toStringAsFixed(2)}'
// //                                             : '£0.00',
// //                                         style: const TextStyle(
// //                                           fontSize: 18.0,
// //                                           fontWeight: FontWeight.bold,
// //                                           color: Color(0xFF1B1670),
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             const SizedBox(height: 20.0),
// //                           ],
// //                         ),
// //                       ),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildTotalRow(String label, double? amount,
// //       {bool isNegative = false}) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: 14,
// //             fontWeight: FontWeight.w500,
// //             color: isNegative ? Colors.red[700] : Colors.black87,
// //           ),
// //         ),
// //         Text(
// //           amount != null
// //               ? '${isNegative ? '- ' : ''}£${amount.toStringAsFixed(2)}'
// //               : '£0.00',
// //           style: TextStyle(
// //             fontSize: 14,
// //             fontWeight: FontWeight.w600,
// //             color: isNegative ? Colors.red[700] : Colors.black87,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tenxglobal_pos/core/services/customer_view_display_service/customer_display_service.dart';
// import 'package:tenxglobal_pos/presentation/provider/customer_provider.dart';

// class RightSideMenuContent extends StatelessWidget {
//   final VoidCallback onClose;

//   const RightSideMenuContent({
//     super.key,
//     required this.onClose,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Consumer<CustomerProvider>(
//         builder: (context, provider, _) {
//           final order = provider.orders == null || provider.orders.isEmpty
//               ? null
//               : provider.orders.first;
//           final items = order == null ? [] : order.order.items ?? [];

//           return Column(
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1B1670),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Order Type Badge
//                     Container(
//                       padding: const EdgeInsets.all(8.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16.0),
//                       ),
//                       child: Text(
//                         order != null ? order.order.orderType : 'Takeaway',
//                         style: const TextStyle(
//                           color: Color(0xFF1B1670),
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),

//                     // Close Button
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.white),
//                       onPressed: onClose,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20.0),

//               // Test Buttons Section
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Card(
//                     color: Colors.purple[50],
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               const Icon(Icons.science, color: Colors.purple),
//                               const SizedBox(width: 8),
//                               const Text(
//                                 'Customer Display Tests',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const Divider(),
//                           const SizedBox(height: 8),

//                           // Test Button 1: Empty Order
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               onPressed: () => _showEmptyOrder(context),
//                               icon: const Icon(Icons.add),
//                               label: const Text('Show Empty Display'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF1B1670),
//                                 foregroundColor: Colors.white,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           // Test Button 2: Sample Order
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               onPressed: () => _showSampleOrder(context),
//                               icon: const Icon(Icons.shopping_cart),
//                               label: const Text('Show Sample Order'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 foregroundColor: Colors.white,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           // Test Button 3: Large Order
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               onPressed: () => _showLargeOrder(context),
//                               icon: const Icon(Icons.restaurant),
//                               label: const Text('Show Large Order'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.orange,
//                                 foregroundColor: Colors.white,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 8),

//                           // Hide Display Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               onPressed: () => _hideDisplay(context),
//                               icon: const Icon(Icons.close),
//                               label: const Text('Hide Display'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                                 foregroundColor: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20.0),

//               // Content
//               Expanded(
//                 child: items.isEmpty
//                     ? Center(
//                         child: ListView(
//                           // mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             Icon(
//                               Icons.shopping_cart_outlined,
//                               size: 64,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(height: 16),
//                             Text(
//                               'No order items',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               'Use test buttons above to preview',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Customer Section
//                             const Text(
//                               'Customer',
//                               style: TextStyle(
//                                 fontSize: 15.0,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             const SizedBox(height: 8.0),
//                             Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.all(12.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[50],
//                                 borderRadius: BorderRadius.circular(8.0),
//                                 border: Border.all(
//                                   width: 1,
//                                   color: Colors.grey.shade300,
//                                 ),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     order != null
//                                         ? order.order.customer
//                                         : 'Walk-in',
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 15,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                   if (order != null &&
//                                       order.order.phoneNumber.isNotEmpty)
//                                     Padding(
//                                       padding: const EdgeInsets.only(top: 4.0),
//                                       child: Text(
//                                         order.order.phoneNumber,
//                                         style: const TextStyle(
//                                           fontSize: 13,
//                                           color: Colors.black54,
//                                         ),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 16.0),

//                             // Items List
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.all(12.0),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   border: Border.all(
//                                     width: 1,
//                                     color: Colors.grey.shade300,
//                                   ),
//                                 ),
//                                 child: ListView.separated(
//                                   itemCount: items.length,
//                                   separatorBuilder: (_, __) => const Divider(
//                                     thickness: 0.5,
//                                     height: 24,
//                                   ),
//                                   itemBuilder: (context, index) {
//                                     final item = items[index];
//                                     return Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         ClipRRect(
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                           child: Image.network(
//                                             item.img,
//                                             height: 50,
//                                             width: 50,
//                                             fit: BoxFit.cover,
//                                             errorBuilder:
//                                                 (context, error, stack) {
//                                               return Container(
//                                                 height: 50,
//                                                 width: 50,
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.grey[200],
//                                                   borderRadius:
//                                                       BorderRadius.circular(8),
//                                                 ),
//                                                 child: const Icon(
//                                                   Icons.fastfood,
//                                                   size: 30,
//                                                   color: Colors.grey,
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),

//                                         // Name and details
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 item.title ?? '',
//                                                 style: const TextStyle(
//                                                   fontWeight: FontWeight.w600,
//                                                   fontSize: 14,
//                                                   color: Colors.black87,
//                                                 ),
//                                               ),
//                                               if (item.variantName != null)
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                           top: 2.0),
//                                                   child: Text(
//                                                     "Variant: ${item.variantName}",
//                                                     style: const TextStyle(
//                                                       fontSize: 12,
//                                                       color: Colors.black54,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               if (item.addons.isNotEmpty)
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                           top: 4.0),
//                                                   child: Wrap(
//                                                     spacing: 4,
//                                                     runSpacing: 4,
//                                                     children: item.addons
//                                                         .map<Widget>((addon) {
//                                                       return Container(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .symmetric(
//                                                           horizontal: 8,
//                                                           vertical: 3,
//                                                         ),
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color:
//                                                               Colors.blue[50],
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(4),
//                                                           border: Border.all(
//                                                             color: Colors
//                                                                 .blue[200]!,
//                                                             width: 0.5,
//                                                           ),
//                                                         ),
//                                                         child: Text(
//                                                           '${addon.name} (+£${addon.price.toStringAsFixed(2)})',
//                                                           style:
//                                                               const TextStyle(
//                                                             fontSize: 11,
//                                                             color:
//                                                                 Colors.black87,
//                                                             fontWeight:
//                                                                 FontWeight.w500,
//                                                           ),
//                                                         ),
//                                                       );
//                                                     }).toList(),
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         ),

//                                         const SizedBox(width: 8),

//                                         // Quantity and Price
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.end,
//                                           children: [
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                 horizontal: 10,
//                                                 vertical: 6,
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 color: const Color(0xFF1B1670),
//                                                 borderRadius:
//                                                     BorderRadius.circular(20),
//                                               ),
//                                               child: Text(
//                                                 'x${item.qty ?? 0}',
//                                                 style: const TextStyle(
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.white,
//                                                 ),
//                                               ),
//                                             ),
//                                             const SizedBox(height: 6),
//                                             Text(
//                                               '£${item.price?.toStringAsFixed(2) ?? '0.00'}',
//                                               style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: 15,
//                                                 color: Colors.black87,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 16.0),

//                             // Totals Section
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.all(16.0),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[50],
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   border: Border.all(
//                                     width: 1,
//                                     color: Colors.grey.shade300,
//                                   ),
//                                 ),
//                                 child: ListView(
//                                   children: [
//                                     _buildTotalRow(
//                                         'Subtotal', order?.order.subtotal),
//                                     const SizedBox(height: 8.0),
//                                     _buildTotalRow('Tax', order?.order.tax),
//                                     const SizedBox(height: 8.0),
//                                     _buildTotalRow(
//                                         'Service', order?.order.serviceCharges),
//                                     const SizedBox(height: 8.0),
//                                     _buildTotalRow('Delivery',
//                                         order?.order.deliveryCharges),
//                                     const SizedBox(height: 8.0),
//                                     _buildTotalRow(
//                                       'Sale Discount',
//                                       order?.order.saleDiscount,
//                                       isNegative: true,
//                                     ),
//                                     const Padding(
//                                       padding:
//                                           EdgeInsets.symmetric(vertical: 8.0),
//                                       child: Divider(thickness: 1),
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         const Text(
//                                           'Total',
//                                           style: TextStyle(
//                                             fontSize: 18.0,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.black87,
//                                           ),
//                                         ),
//                                         Text(
//                                           order != null
//                                               ? '£${order.order.total.toStringAsFixed(2)}'
//                                               : '£0.00',
//                                           style: const TextStyle(
//                                             fontSize: 18.0,
//                                             fontWeight: FontWeight.bold,
//                                             color: Color(0xFF1B1670),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 20.0),
//                           ],
//                         ),
//                       ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTotalRow(String label, double? amount,
//       {bool isNegative = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: isNegative ? Colors.red[700] : Colors.black87,
//           ),
//         ),
//         Text(
//           amount != null
//               ? '${isNegative ? '- ' : ''}£${amount.toStringAsFixed(2)}'
//               : '£0.00',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: isNegative ? Colors.red[700] : Colors.black87,
//           ),
//         ),
//       ],
//     );
//   }

//   // Test Functions
//   void _showEmptyOrder(BuildContext context) async {
//     try {
//       // await CustomerDisplayService.show(
//       //   title: 'Welcome',
//       //   total: 0.0,
//       //   items: [],
//       //   customer: 'Walk-in Customer',
//       //   orderType: 'Dine-in',
//       // );

//       _showSuccessSnackbar(context, '✅ Empty display shown');
//     } catch (e) {
//       _showErrorSnackbar(context, '❌ Error: $e');
//     }
//   }

//   void _showSampleOrder(BuildContext context) async {
//     try {
//       // await CustomerDisplayService.show(
//       //   title: 'Sample Order',
//       //   total: 45.97,
//       //   subtotal: 42.97,
//       //   tax: 3.00,
//       //   serviceCharges: 0.0,
//       //   deliveryCharges: 0.0,
//       //   saleDiscount: 0.0,
//       //   customer: 'John Smith',
//       //   phoneNumber: '+44 7911 123456',
//       //   orderType: 'Takeaway',
//       //   items: [
//       //     {
//       //       'title': 'Cheeseburger',
//       //       'price': 12.99,
//       //       'qty': 2,
//       //       'img':
//       //           'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=100',
//       //       'variantName': 'Large',
//       //       'addons': [
//       //         {'name': 'Extra Cheese', 'price': 1.50},
//       //         {'name': 'Bacon', 'price': 2.00},
//       //       ],
//       //     },
//       //     {
//       //       'title': 'French Fries',
//       //       'price': 4.99,
//       //       'qty': 1,
//       //       'img':
//       //           'https://images.unsplash.com/photo-1630384082525-39f618d03f7d?w=100',
//       //       'addons': [],
//       //     },
//       //     {
//       //       'title': 'Cola',
//       //       'price': 2.99,
//       //       'qty': 3,
//       //       'img':
//       //           'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=100',
//       //       'variantName': 'Regular',
//       //       'addons': [],
//       //     },
//       //   ],
//       // );

//       _showSuccessSnackbar(context, '✅ Sample order shown');
//     } catch (e) {
//       _showErrorSnackbar(context, '❌ Error: $e');
//     }
//   }

//   void _showLargeOrder(BuildContext context) async {
//     try {
//       // ✅ GET DATA FROM PROVIDER INSTEAD OF DUMMY DATA
//       final provider = Provider.of<CustomerProvider>(context, listen: false);

//       if (provider.orders.isEmpty) {
//         _showErrorSnackbar(context, '❌ No server data available');
//         return;
//       }

//       final order = provider.orders.first.order;

//       // Convert to display format
//       final items = order.items
//           .map((item) => {
//                 'title': item.title,
//                 'price': item.price,
//                 'qty': item.qty,
//                 'img': item.img,
//                 'variantName': item.variantName,
//                 'addons': item.addons
//                     .map((a) => {'name': a.name, 'price': a.price})
//                     .toList(),
//               })
//           .toList();

//       // await CustomerDisplayService.show(
//       //   title: order.orderType,
//       //   total: order.total,
//       //   subtotal: order.subtotal,
//       //   tax: order.tax,
//       //   serviceCharges: order.serviceCharges,
//       //   deliveryCharges: order.deliveryCharges,
//       //   saleDiscount: order.saleDiscount,
//       //   customer: order.customer,
//       //   phoneNumber: order.phoneNumber,
//       //   orderType: order.orderType,
//       //   items: items,
//       // );

//       _showSuccessSnackbar(context, '✅ Server data shown');
//     } catch (e) {
//       print('dadada');
//       _showErrorSnackbar(context, '❌ Error: $e');
//     }
//   }

//   void _hideDisplay(BuildContext context) async {
//     try {
//       // await CustomerDisplayService.hide();
//       _showSuccessSnackbar(context, '✅ Display hidden');
//     } catch (e) {
//       _showErrorSnackbar(context, '❌ Error: $e');
//     }
//   }

//   void _showSuccessSnackbar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 1),
//       ),
//     );
//   }

//   void _showErrorSnackbar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }
