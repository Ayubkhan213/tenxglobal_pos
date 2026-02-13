// import 'package:flutter/services.dart';
// import 'package:tenxglobal_pos/core/services/customer_view_display_service/customer_display_eventbus.dart';

// class CustomerDisplayService {
//   // Channel to LAUNCH customer display (talks to MainActivity)
//   static const MethodChannel _launchChannel =
//       MethodChannel('uk.co.tenxglobal.tenxglobal_pos/customer_display');

//   /// Show customer display with order data
//   static Future<void> show({
//     required String title,
//     required double total,
//     required List<Map<String, dynamic>> items,
//     String? customer,
//     String? phoneNumber,
//     String? orderType,
//     double? subtotal,
//     double? tax,
//     double? serviceCharges,
//     double? deliveryCharges,
//     double? saleDiscount,
//   }) async {
//     try {
//       // Prepare the data structure
//       final Map<String, dynamic> displayData = {
//         'order': {
//           'customer': customer ?? 'Walk-in Customer',
//           'phoneNumber': phoneNumber ?? '',
//           'orderType': orderType ?? 'Takeaway',
//           'total': total,
//           'subtotal': subtotal ?? total,
//           'tax': tax ?? 0.0,
//           'serviceCharges': serviceCharges ?? 0.0,
//           'deliveryCharges': deliveryCharges ?? 0.0,
//           'saleDiscount': saleDiscount ?? 0.0,
//           'items': items.map((item) {
//             return {
//               'title': item['title'] ?? 'Unknown Item',
//               'img': item['img'] ?? 'https://via.placeholder.com/100',
//               'price': item['price'] ?? 0.0,
//               'qty': item['qty'] ?? 1,
//               'variantName': item['variantName'],
//               'addons': item['addons'] ?? [],
//             };
//           }).toList(),
//         }
//       };

//       print(' CustomerDisplayService.show() called');
//       print(' Data being sent: $displayData');

//       // Send to native MainActivity to launch CustomerDisplayActivity
//       await _launchChannel.invokeMethod('showCustomerDisplay', {
//         'data': displayData,
//       });

//       // ALSO publish to event bus for local main app updates
//       CustomerDisplayEventBus().publish(displayData);

//       print(' Customer display launch command sent');
//     } catch (e) {
//       print(' Error showing customer display: $e');
//       rethrow;
//     }
//   }

//   /// Update existing customer display
//   static Future<void> update({
//     required String title,
//     required double total,
//     required List<Map<String, dynamic>> items,
//     String? customer,
//     String? phoneNumber,
//     String? orderType,
//     double? subtotal,
//     double? tax,
//     double? serviceCharges,
//     double? deliveryCharges,
//     double? saleDiscount,
//   }) async {
//     try {
//       final Map<String, dynamic> displayData = {
//         'order': {
//           'customer': customer ?? 'Walk-in Customer',
//           'phoneNumber': phoneNumber ?? '',
//           'orderType': orderType ?? 'Takeaway',
//           'total': total,
//           'subtotal': subtotal ?? total,
//           'tax': tax ?? 0.0,
//           'serviceCharges': serviceCharges ?? 0.0,
//           'deliveryCharges': deliveryCharges ?? 0.0,
//           'saleDiscount': saleDiscount ?? 0.0,
//           'items': items.map((item) {
//             return {
//               'title': item['title'] ?? 'Unknown Item',
//               'img': item['img'] ?? 'https://via.placeholder.com/100',
//               'price': item['price'] ?? 0.0,
//               'qty': item['qty'] ?? 1.0,
//               'variantName': item['variantName'],
//               'addons': item['addons'] ?? [],
//             };
//           }).toList(),
//         }
//       };

//       print('🔄 CustomerDisplayService.update() called');
//       print('📦 Update data: $displayData');

//       // Send update to MainActivity (it will broadcast to CustomerDisplayActivity)
//       await _launchChannel.invokeMethod('updateCustomerDisplay', {
//         'data': displayData,
//       });

//       // Also broadcast to event bus for local main app
//       CustomerDisplayEventBus().publish(displayData);

//       print('✅ Customer display update sent');
//     } catch (e) {
//       print('❌ Error updating customer display: $e');
//       rethrow;
//     }
//   }

//   /// Send the full server JSON directly to CustomerDisplay
//   static Future<void> updateFullData(Map<String, dynamic> fullData) async {
//     try {
//       print('🔄 CustomerDisplayService.updateFullData() called');

//       // ✅ ALWAYS extract order
//       final Map<String, dynamic> payload =
//           fullData.containsKey('order') ? fullData['order'] : fullData;

//       final displayData = {
//         'order': payload,
//       };

//       print('📦 Normalized data: $displayData');

//       await _launchChannel.invokeMethod(
//         'updateCustomerDisplay',
//         {'data': displayData},
//       );

//       CustomerDisplayEventBus().publish(displayData);

//       print('✅ Customer display full JSON sent');
//     } catch (e) {
//       print('❌ Error sending full JSON: $e');
//       rethrow;
//     }
//   }

//   /// Hide customer display
//   static Future<void> hide() async {
//     try {
//       print('🚫 CustomerDisplayService.hide() called');
//       await _launchChannel.invokeMethod('hideCustomerDisplay');
//       print('✅ Customer display hide command sent');
//     } catch (e) {
//       print('❌ Error hiding customer display: $e');
//       rethrow;
//     }
//   }
// }
import 'package:flutter/services.dart';

class CustomerDisplayService {
  static const MethodChannel _channel =
      MethodChannel('uk.co.tenxglobal.tenxglobal_pos/customer_display');

  static Future<void> updateFullData(Map<String, dynamic> data) async {
    try {
      print('📤 Sending to customer display');

      await _channel.invokeMethod('updateCustomerDisplay', {
        'data': data,
      });

      print('✅ Sent to native');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  static Future<void> showForTesting() async {
    try {
      final data = {
        'order': {
          'customer': 'TEST CUSTOMER',
          'orderType': 'Dine In',
          'total': 99.99,
          'subtotal': 85.00,
          'tax': 10.00,
          'serviceCharges': 4.99,
          'saleDiscount': 0.0,
          'items': [
            {
              'title': 'Test Burger',
              'price': 85.00,
              'qty': 1,
              'variantName': 'Large',
            }
          ]
        }
      };

      // This will trigger the broadcast
      await _channel.invokeMethod('updateCustomerDisplay', {'data': data});
    } catch (e) {
      print('Error: $e');
    }
  }
}
