import 'package:flutter/material.dart';
import 'package:tenxglobal_pos/data/models/customer_response_model.dart';

class CustomerProvider extends ChangeNotifier {
  List<CartResponse> _orders = [];

  List<CartResponse> get orders => _orders;
  void addOrderFromJson(Map<String, dynamic> json) {
    print('═══════════════════════════════════════');
    print('📦 CustomerProvider: Received data');
    print('Raw JSON keys: ${json.keys.toList()}');

    try {
      // ✅ UNWRAP if MethodChannel sent {data: {...}}
      final Map<String, dynamic> payload = json.containsKey('data')
          ? Map<String, dynamic>.from(json['data'])
          : json;

      final cartResponse = CartResponse.fromJson(payload);

      print('✅ Successfully parsed order');
      print('   Customer: ${cartResponse.order.customer}');
      print('   Items: ${cartResponse.order.items.length}');
      print('   Total: £${cartResponse.order.total.toStringAsFixed(2)}');

      _orders
        ..clear()
        ..add(cartResponse);

      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ Error parsing order data: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
