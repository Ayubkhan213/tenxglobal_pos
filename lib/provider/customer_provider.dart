import 'package:flutter/material.dart';
import 'package:tenxglobal_pos/models/customer_response_model.dart';

class CustomerProvider extends ChangeNotifier {
  ///  List of parsed orders
  final List<CartResponse> _orders = [];

  ///  Public getter
  List<CartResponse> get orders => List.unmodifiable(_orders);

  ///  Add order from JSON
  void addOrderFromJson(Map<String, dynamic> json) {
    print('------------------ DAta In Provider --------------');
    print(json);

    print('---------------------------    ${json}');
    final orderResponse = CartResponse.fromJson(json);
    print(orderResponse.order.customer);
    _orders.clear();
    _orders.add(orderResponse);
    notifyListeners();
  }

  ///  Add multiple orders (API list)
  void addOrdersFromJsonList(List<dynamic> jsonList) {
    for (final item in jsonList) {
      _orders.add(CartResponse.fromJson(item));
    }
    notifyListeners();
  }

  ///  Clear orders
  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
