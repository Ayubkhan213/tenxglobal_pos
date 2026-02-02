// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tenxglobal_pos/provider/customer_provider.dart';

// class RightSideMenu extends StatelessWidget {
//   const RightSideMenu({super.key});

//   static void show(BuildContext context) {
//     // Capture the provider instance from the calling context
//     final customerProvider =
//         Provider.of<CustomerProvider>(context, listen: false);

//     showGeneralDialog(
//       context: context,
//       barrierDismissible:
//           false, // Changed to false - can't dismiss by tapping outside
//       barrierLabel: '',
//       barrierColor:
//           Colors.transparent, // Changed to transparent - no dark overlay
//       transitionDuration: const Duration(milliseconds: 300),
//       pageBuilder: (context, animation, secondaryAnimation) {
//         return Align(
//           alignment: Alignment.centerRight,
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.4,
//               height: MediaQuery.of(context).size.height,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 20,
//                     offset: const Offset(-5, 0),
//                   ),
//                 ],
//               ),
//               // Provide the captured provider to the dialog
//               child: ChangeNotifierProvider.value(
//                 value: customerProvider,
//                 child: const RightSideMenu(),
//               ),
//             ),
//           ),
//         );
//       },
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         return SlideTransition(
//           position: Tween<Offset>(
//             begin: const Offset(1.0, 0.0),
//             end: Offset.zero,
//           ).animate(CurvedAnimation(
//             parent: animation,
//             curve: Curves.easeInOut,
//           )),
//           child: child,
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Consumer<CustomerProvider>(
//         builder: (context, provider, _) {
//           final order = provider.orders == null || provider.orders.isEmpty
//               ? null
//               : provider.orders.first;
//           final items = order == null ? [] : order.cartData.items ?? [];

//           return Column(
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1B1670),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16.0),
//                       ),
//                       child: Text(
//                         order != null ? order.cartData.orderType : 'Takeaway',
//                         style: const TextStyle(
//                           color: Color(0xFF1B1670),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.white),
//                       onPressed: () =>
//                           Navigator.pop(context), // Only way to close
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20.0),

//               // Content
//               Expanded(
//                 child: items.isEmpty
//                     ? const Center(
//                         child: Text(
//                           'No order items',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey,
//                           ),
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
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 5.0),
//                             Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.all(8.0),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8.0),
//                                 border: Border.all(
//                                   width: 0.5,
//                                   color: Colors.grey.shade500,
//                                 ),
//                               ),
//                               child: Text(
//                                 order != null
//                                     ? order.cartData.customer
//                                     : 'Walk-in',
//                               ),
//                             ),
//                             const SizedBox(height: 12.0),

//                             // Items List
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.all(12.0),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   border: Border.all(
//                                     width: 0.5,
//                                     color: Colors.grey.shade300,
//                                   ),
//                                 ),
//                                 child: ListView.separated(
//                                   itemCount: items.length,
//                                   separatorBuilder: (_, __) => const Divider(
//                                     thickness: 0.3,
//                                   ),
//                                   itemBuilder: (context, index) {
//                                     final item = items[index];
//                                     return Row(
//                                       children: [
//                                         Image.network(
//                                           item.img,
//                                           height: 45,
//                                           errorBuilder:
//                                               (context, error, stack) {
//                                             return const Icon(
//                                               Icons.fastfood,
//                                               size: 45,
//                                             );
//                                           },
//                                         ),
//                                         const SizedBox(width: 8),

//                                         // Name and details
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Text(item.title ?? ''),
//                                               if (item.variantName != null)
//                                                 Text(
//                                                   "Variant: ${item.variantName}",
//                                                   style: TextStyle(
//                                                     fontSize: 11,
//                                                     color: Colors.grey[600],
//                                                   ),
//                                                 ),
//                                               Wrap(
//                                                 children: item.addons
//                                                     .map<Widget>((addon) {
//                                                   return Padding(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                       horizontal: 2.0,
//                                                       vertical: 0.0,
//                                                     ),
//                                                     child: Container(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                         4.0,
//                                                       ),
//                                                       child: Text(
//                                                         '${addon.name} (£${addon.price.toStringAsFixed(2)})',
//                                                         style: const TextStyle(
//                                                           fontSize: 11.0,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   );
//                                                 }).toList(),
//                                               ),
//                                             ],
//                                           ),
//                                         ),

//                                         // Quantity
//                                         Container(
//                                           padding: const EdgeInsets.all(8),
//                                           decoration: const BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Color.fromARGB(
//                                               255,
//                                               231,
//                                               231,
//                                               229,
//                                             ),
//                                           ),
//                                           child: Text(
//                                             'x${item.qty ?? 0}',
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),

//                                         // Price
//                                         Text(
//                                           '£${item.price?.toStringAsFixed(2) ?? '0.00'}',
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 5.0),
//                             const Divider(thickness: 0.5),
//                             const SizedBox(height: 15.0),

//                             // Totals Section
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Subtotal'),
//                                 Text(
//                                   order != null
//                                       ? '£${order.cartData.subtotal.toStringAsFixed(2)}'
//                                       : '0.00',
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 5.0),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Tax'),
//                                 Text(
//                                   order != null
//                                       ? '£${order.cartData.tax.toStringAsFixed(2)}'
//                                       : '0.00',
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 5.0),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Service'),
//                                 Text(
//                                   order != null
//                                       ? '£${order.cartData.serviceCharges.toStringAsFixed(2)}'
//                                       : '0.00',
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 5.0),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [9
//                                 const Text(
//                                   'Sale Discount',
//                                   style: TextStyle(color: Colors.red),
//                                 ),
//                                 Text(
//                                   order != null
//                                       ? '-£${order.cartData.saleDiscount.toStringAsFixed(2)}'
//                                       : '0.00',
//                                   style: const TextStyle(color: Colors.red),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 5.0),
//                             const Divider(thickness: 0.5),
//                             const SizedBox(height: 5.0),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text(
//                                   'Total',
//                                   style: TextStyle(
//                                     fontSize: 16.0,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   order != null
//                                       ? '£${order.cartData.total.toStringAsFixed(2)}'
//                                       : '0.00',
//                                   style: const TextStyle(
//                                     fontSize: 16.0,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
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
// }
