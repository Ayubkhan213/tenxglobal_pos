double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  return double.tryParse(v.toString()) ?? 0.0;
}

double? _toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  return double.tryParse(v.toString());
}

// -------------------- ROOT --------------------
class OrderResponse {
  OrderData? order;
  String? type;
  String? print;

  OrderResponse({this.order, this.type, this.print});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      order: json['order'] != null
          ? OrderData.fromJson(json['order'])
          : json['flatOrder'] != null
              ? OrderData.fromJson(json['flatOrder'])
              : null,
      type: json['type'],
      print: json['print'],
    );
  }
}

// -------------------- ORDER --------------------
class OrderData {
  int? userId;
  int? shiftId;
  String? customerName;
  String? customerPhone;
  String? customerEmail;
  String? deliveryAddress;
  double? subTotal;
  double? totalAmount;
  double? tax;
  double? serviceCharges;
  double? deliveryCharges;
  double? salesDiscount;
  double? approvedDiscounts;
  String? status;
  String? note;
  String? kitchenNote;
  String? orderDate;
  String? orderTime;
  String? updatedAt;
  String? createdAt;
  int? id;
  List<OrderItem>? items;

  KotData? kot;
  List<dynamic>? promo;
  String? phoneNumber;
  String? deliveryLocation;
  List<dynamic>? approvedDiscountDetails;
  double? promoDiscount;
  List<dynamic>? appliedPromos;
  String? orderType;
  String? tableNumber;
  String? paymentMethod;
  bool? autoPrintKot;
  double? cashReceived;
  double? change;
  String? paymentType;
  double? cashAmount;
  double? cardAmount;
  String? paymentStatus;
  bool? confirmMissingIngredients;

  List<Payment>? payments;

  double? outstanding;
  double? remainingBalance;
  double? totalAddons;
  OrderData({
    this.customerEmail,
    this.customerPhone,
    this.deliveryAddress,
    this.userId,
    this.shiftId,
    this.customerName,
    this.subTotal,
    this.totalAmount,
    this.tax,
    this.serviceCharges,
    this.deliveryCharges,
    this.salesDiscount,
    this.approvedDiscounts,
    this.status,
    this.note,
    this.kitchenNote,
    this.orderDate,
    this.orderTime,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.items,
    this.kot,
    this.promo,
    this.phoneNumber,
    this.deliveryLocation,
    this.approvedDiscountDetails,
    this.promoDiscount,
    this.appliedPromos,
    this.orderType,
    this.tableNumber,
    this.paymentMethod,
    this.autoPrintKot,
    this.cashReceived,
    this.change,
    this.paymentType,
    this.cashAmount,
    this.cardAmount,
    this.paymentStatus,
    this.confirmMissingIngredients,
    this.payments,
    this.outstanding,
    this.remainingBalance,
    this.totalAddons,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      customerEmail: json['customer_email'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      userId: json['user_id'],
      shiftId: json['shift_id'],
      customerName: json['customer_name'],
      subTotal: _toDouble(json['sub_total']),
      totalAmount: _toDouble(json['total_amount']),
      tax: _toDouble(json['tax']),
      serviceCharges: _toDouble(json['service_charges']),
      deliveryCharges: _toDouble(json['delivery_charges']),
      salesDiscount: _toDouble(json['sales_discount']),
      approvedDiscounts: _toDouble(json['approved_discounts']),
      status: json['status'],
      note: json['note'],
      kitchenNote: json['kitchen_note'],
      orderDate: json['order_date'],
      orderTime: json['order_time'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      id: json['id'],
      items:
          (json['items'] as List?)?.map((e) => OrderItem.fromJson(e)).toList(),
      kot: json['kot'] != null ? KotData.fromJson(json['kot']) : null,
      promo: json['promo'],
      phoneNumber: json['phone_number'],
      deliveryLocation: json['delivery_location'],
      approvedDiscountDetails: json['approved_discount_details'],
      promoDiscount: _toDouble(json['promo_discount']),
      appliedPromos: json['applied_promos'],
      orderType: json['order_type'] ?? 'Eat In',
      tableNumber: json['table_number']?.toString(),
      paymentMethod: json['payment_method'],
      autoPrintKot: json['auto_print_kot'],
      cashReceived: _toDouble(json['cash_received']),
      change: _toDouble(json['change']),
      paymentType: json['payment_type'] ?? 'Cash',
      cashAmount: _toDoubleOrNull(json['cash_amount']),
      cardAmount: _toDoubleOrNull(json['card_amount']),
      paymentStatus: json['payment_status'],
      confirmMissingIngredients: json['confirm_missing_ingredients'],
      payments:
          (json['payments'] as List?)?.map((e) => Payment.fromJson(e)).toList(),
      outstanding: _toDoubleOrNull(json['outstanding']),
      remainingBalance: _toDoubleOrNull(json['remaining_balance']),
      totalAddons: _toDoubleOrNull(json['total_addons']),
    );
  }
}

class ChoiceGroup {
  final String name;
  final List<ChoiceItem> items;

  ChoiceGroup({
    required this.name,
    required this.items,
  });

  factory ChoiceGroup.fromJson(Map<String, dynamic> json) {
    return ChoiceGroup(
      name: json['name'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => ChoiceItem.fromJson(e))
          .toList(),
    );
  }
}

class ChoiceItem {
  final int id;
  final String name;
  final double price;
  final List<dynamic> ingredients;
  final List<Addon> addons;
  final String? kitchenNote;
  final List<RemovedIngredient> removedIngredients;
  final int? variantId;

  ChoiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.ingredients,
    required this.addons,
    this.kitchenNote,
    required this.removedIngredients,
    this.variantId,
  });

  factory ChoiceItem.fromJson(Map<String, dynamic> json) {
    return ChoiceItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      price: _toDouble(json['price']),
      ingredients: json['ingredients'] ?? [],
      addons: (json['addons'] as List? ?? [])
          .map((e) => Addon.fromJson(e))
          .toList(),
      kitchenNote: json['kitchen_note'],
      removedIngredients: (json['removed_ingredients'] as List? ?? [])
          .map((e) => RemovedIngredient.fromJson(e))
          .toList(),
      variantId: json['variant_id'],
    );
  }
}

class MenuItemModel {
  final int id;
  final String name;
  final double price;
  final List<dynamic> ingredients;
  final List<Addon> addons;
  final String? kitchenNote;
  final List<RemovedIngredient> removedIngredients;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.ingredients,
    required this.addons,
    this.kitchenNote,
    required this.removedIngredients,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      price: _toDouble(json['price']),
      ingredients: json['ingredients'] ?? [],
      addons: (json['addons'] as List? ?? [])
          .map((e) => Addon.fromJson(e))
          .toList(),
      kitchenNote: json['kitchen_note'],
      removedIngredients: (json['removed_ingredients'] as List? ?? [])
          .map((e) => RemovedIngredient.fromJson(e))
          .toList(),
    );
  }
}

class Payment {
  final int id;
  final double amountReceived;
  final double cashAmount;
  final double cardAmount;
  final String? paymentType;
  final String? paymentStatus;
  final String? currencyCode;

  Payment({
    required this.id,
    required this.amountReceived,
    required this.cashAmount,
    required this.cardAmount,
    this.paymentType,
    this.paymentStatus,
    this.currencyCode,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      amountReceived: _toDouble(json['amount_received']),
      cashAmount: _toDouble(json['cash_amount']),
      cardAmount: _toDouble(json['card_amount']),
      paymentType: json['payment_type']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      currencyCode: json['currency_code']?.toString(),
    );
  }
}

// -------------------- ORDER ITEM --------------------
class OrderItem {
  int? productId;
  String? title;
  int? quantity;
  double? price;
  String? note;
  String? kitchenNote;
  double? unitPrice;
  String? itemKitchenNote;
  double? taxPercentage;
  double? taxAmount;
  int? variantId;
  String? variantName;
  List<Addon>? addons;
  double? saleDiscountPerItem;
  List<RemovedIngredient>? removedIngredients;
  List<ChoiceGroup>? choiceGroups;
  List<MenuItemModel>? menuItems;

  OrderItem({
    this.productId,
    this.title,
    this.quantity,
    this.price,
    this.note,
    this.kitchenNote,
    this.unitPrice,
    this.itemKitchenNote,
    this.taxPercentage,
    this.taxAmount,
    this.variantId,
    this.variantName,
    this.addons,
    this.saleDiscountPerItem,
    this.removedIngredients,
    this.choiceGroups,
    this.menuItems,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    print(
        "addon list is -------------------------------------------------------------------  ${json['addons']}");
    return OrderItem(
      productId: json['product_id'],
      title: json['title'],
      quantity: json['quantity'],
      price: _toDouble(json['price']),
      unitPrice: _toDouble(json['unit_price']),
      taxPercentage: _toDouble(json['tax_percentage']),
      taxAmount: _toDouble(json['tax_amount']),
      saleDiscountPerItem: _toDouble(json['sale_discount_per_item']),
      note: json['item_kitchen_note'],
      kitchenNote: json['kitchen_note'],
      itemKitchenNote: json['item_kitchen_note'],
      variantId: json['variant_id'],
      variantName: json['variant_name'],
      // FIX: Handle null addons list
      addons: json['addons'] != null
          ? (json['addons'] as List)
              .map((addon) => Addon.fromJson(addon))
              .toList()
          : [], // Return empty list if null
      removedIngredients: (json['removed_ingredients'] as List?)
          ?.map((e) => RemovedIngredient.fromJson(e))
          .toList(),
      choiceGroups: (json['choice_groups'] as List? ?? [])
          .map((e) => ChoiceGroup.fromJson(e))
          .toList(),

      menuItems: (json['menu_items'] as List? ?? [])
          .map((e) => MenuItemModel.fromJson(e))
          .toList(),
    );
  }
}

// -------------------- KOT --------------------
class KotData {
  int? id;
  int? posOrderTypeId;
  String? orderTime; // FIX
  String? orderDate; // FIX
  String? note;
  String? kitchenNote;
  String? createdAt;
  String? updatedAt;
  List<KotItem>? items;

  KotData({
    this.id,
    this.posOrderTypeId,
    this.orderTime,
    this.orderDate,
    this.note,
    this.kitchenNote,
    this.createdAt,
    this.updatedAt,
    this.items,
  });

  factory KotData.fromJson(Map<String, dynamic> json) {
    return KotData(
      id: int.tryParse(json['id'].toString()),
      posOrderTypeId: int.tryParse(json['pos_order_type_id'].toString()),
      orderTime: json['order_time']?.toString(),
      orderDate: json['order_date']?.toString(),
      note: json['note'],
      kitchenNote: json['kitchen_note'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      items: (json['items'] as List?)?.map((e) => KotItem.fromJson(e)).toList(),
    );
  }
}

// -------------------- KOT ITEM --------------------
class KotItem {
  final int id;
  final int kitchenOrderId;
  final String itemName;
  final String? variantName; // <-- MAKE NULLABLE
  final int quantity;
  final List<dynamic> ingredients;
  final String? itemKitchenNote;
  final String status;
  final String createdAt;
  final String updatedAt;

  KotItem({
    required this.id,
    required this.kitchenOrderId,
    required this.itemName,
    this.variantName, // <-- allow null
    required this.quantity,
    required this.ingredients,
    this.itemKitchenNote,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KotItem.fromJson(Map<String, dynamic> json) {
    return KotItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      kitchenOrderId: int.tryParse(json['kitchen_order_id'].toString()) ?? 0,
      itemName: json['item_name']?.toString() ?? '',
      variantName: json['variant_name']?.toString(),
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      ingredients: json['ingredients'] ?? [],
      itemKitchenNote: json['item_kitchen_note'],
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class RemovedIngredient {
  final int id;
  final String name;

  RemovedIngredient({
    required this.id,
    required this.name,
  });

  factory RemovedIngredient.fromJson(Map<String, dynamic> json) {
    return RemovedIngredient(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class Addon {
  final int id;
  final String name;
  final double price;
  final int? quantity;

  Addon({
    required this.id,
    required this.name,
    required this.price,
    this.quantity,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['addon_name']?.toString() ?? json['name']?.toString() ?? '',
      price: _toDouble(json['price']),
      quantity: (json['quantity']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
      };
}
// double _toDouble(dynamic v) {
//   if (v == null) return 0.0;
//   return double.tryParse(v.toString()) ?? 0.0;
// }

// double? _toDoubleOrNull(dynamic v) {
//   if (v == null) return null;
//   return double.tryParse(v.toString());
// }

// // -------------------- ROOT --------------------
// class OrderResponse {
//   OrderData? order;
//   String? type;
//   String? print;

//   OrderResponse({this.order, this.type, this.print});

//   factory OrderResponse.fromJson(Map<String, dynamic> json) {
//     return OrderResponse(
//       order: json['order'] != null ? OrderData.fromJson(json['order']) : null,
//       type: json['type'],
//       print: json['print'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'order': order?.toJson(),
//     'type': type,
//     'print': print,
//   };
// }

// // -------------------- ORDER DATA --------------------
// class OrderData {
//   int? userId;
//   int? shiftId;
//   String? customerName;
//   String? customerPhone;
//   String? customerEmail;
//   String? deliveryAddress;
//   double? subTotal;
//   double? totalAmount;
//   double? tax;
//   double? serviceCharges;
//   double? deliveryCharges;
//   double? salesDiscount;
//   double? approvedDiscounts;
//   String? status;
//   String? note;
//   String? kitchenNote;
//   String? orderDate;
//   String? orderTime;
//   String? updatedAt;
//   String? createdAt;
//   int? id;
//   String? source;
//   List<OrderItem>? items;
//   List<Payment>? payments;
//   double? outstanding;
//   double? change;
//   double? remainingBalance;
//   double? totalAddons;
//   String? orderType;

//   OrderData({
//     this.customerEmail,
//     this.customerPhone,
//     this.deliveryAddress,
//     this.userId,
//     this.shiftId,
//     this.customerName,
//     this.subTotal,
//     this.totalAmount,
//     this.tax,
//     this.serviceCharges,
//     this.deliveryCharges,
//     this.salesDiscount,
//     this.approvedDiscounts,
//     this.status,
//     this.note,
//     this.kitchenNote,
//     this.orderDate,
//     this.orderTime,
//     this.updatedAt,
//     this.createdAt,
//     this.id,
//     this.source,
//     this.items,
//     this.payments,
//     this.outstanding,
//     this.change,
//     this.remainingBalance,
//     this.totalAddons,
//     this.orderType,
//   });

//   factory OrderData.fromJson(Map<String, dynamic> json) {
//     return OrderData(
//       customerEmail: json['customer_email'] ?? '',
//       customerPhone: json['customer_phone'] ?? '',
//       deliveryAddress: json['delivery_address'] ?? '',
//       userId: json['user_id'],
//       shiftId: json['shift_id'],
//       customerName: json['customer_name'],
//       subTotal: _toDouble(json['sub_total']),
//       totalAmount: _toDouble(json['total_amount']),
//       tax: _toDouble(json['tax']),
//       serviceCharges: _toDouble(json['service_charges']),
//       deliveryCharges: _toDouble(json['delivery_charges']),
//       salesDiscount: _toDouble(json['sales_discount']),
//       approvedDiscounts: _toDouble(json['approved_discounts']),
//       status: json['status'],
//       note: json['note'],
//       kitchenNote: json['kitchen_note'],
//       orderDate: json['order_date'],
//       orderTime: json['order_time'],
//       updatedAt: json['updated_at'],
//       createdAt: json['created_at'],
//       id: json['id'],
//       source: json['source'],
//       items: (json['items'] as List?)
//           ?.map((e) => OrderItem.fromJson(e))
//           .toList(),
//       payments: (json['payments'] as List?)
//           ?.map((e) => Payment.fromJson(e))
//           .toList(),
//       outstanding: _toDoubleOrNull(json['outstanding']),
//       change: _toDoubleOrNull(json['change']),
//       remainingBalance: _toDoubleOrNull(json['remaining_balance']),
//       totalAddons: _toDoubleOrNull(json['total_addons']),
//       orderType: json['order_type'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'customer_email': customerEmail,
//     'customer_phone': customerPhone,
//     'delivery_address': deliveryAddress,
//     'user_id': userId,
//     'shift_id': shiftId,
//     'customer_name': customerName,
//     'sub_total': subTotal,
//     'total_amount': totalAmount,
//     'tax': tax,
//     'service_charges': serviceCharges,
//     'delivery_charges': deliveryCharges,
//     'sales_discount': salesDiscount,
//     'approved_discounts': approvedDiscounts,
//     'status': status,
//     'note': note,
//     'kitchen_note': kitchenNote,
//     'order_date': orderDate,
//     'order_time': orderTime,
//     'updated_at': updatedAt,
//     'created_at': createdAt,
//     'id': id,
//     'source': source,
//     'items': items?.map((e) => e.toJson()).toList(),
//     'payments': payments?.map((e) => e.toJson()).toList(),
//     'outstanding': outstanding,
//     'change': change,
//     'remaining_balance': remainingBalance,
//     'total_addons': totalAddons,
//     'order_type': orderType,
//   };
// }

// // -------------------- ORDER ITEM --------------------
// class OrderItem {
//   int? productId;
//   String? title;
//   int? quantity;
//   double? price;
//   String? note;
//   String? kitchenNote;
//   double? unitPrice;
//   String? itemKitchenNote;
//   int? variantId;
//   String? variantName;
//   List<Addon>? addons;
//   double? saleDiscountPerItem;
//   List<RemovedIngredient>? removedIngredients;
//   List<MenuItem>? menuItems;
//   List<ChoiceGroup>? choiceGroups;

//   OrderItem({
//     this.productId,
//     this.title,
//     this.quantity,
//     this.price,
//     this.note,
//     this.kitchenNote,
//     this.unitPrice,
//     this.itemKitchenNote,
//     this.variantId,
//     this.variantName,
//     this.addons,
//     this.saleDiscountPerItem,
//     this.removedIngredients,
//     this.menuItems,
//     this.choiceGroups,
//   });

//   factory OrderItem.fromJson(Map<String, dynamic> json) {
//     return OrderItem(
//       productId: json['product_id'],
//       title: json['title'],
//       quantity: json['quantity'],
//       price: _toDouble(json['price']),
//       unitPrice: _toDouble(json['unit_price']),
//       saleDiscountPerItem: _toDouble(json['sale_discount_per_item']),
//       note: json['item_kitchen_note'],
//       kitchenNote: json['kitchen_note'],
//       itemKitchenNote: json['item_kitchen_note'],
//       variantId: json['variant_id'],
//       variantName: json['variant_name'],
//       addons: (json['addons'] as List?)?.map((e) => Addon.fromJson(e)).toList(),
//       removedIngredients: (json['removed_ingredients'] as List?)
//           ?.map((e) => RemovedIngredient.fromJson(e))
//           .toList(),
//       menuItems: (json['menu_items'] as List?)
//           ?.map((e) => MenuItem.fromJson(e))
//           .toList(),
//       choiceGroups: (json['choice_groups'] as List?)
//           ?.map((e) => ChoiceGroup.fromJson(e))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'product_id': productId,
//     'title': title,
//     'quantity': quantity,
//     'price': price,
//     'unit_price': unitPrice,
//     'sale_discount_per_item': saleDiscountPerItem,
//     'item_kitchen_note': note,
//     'kitchen_note': kitchenNote,
//     'variant_id': variantId,
//     'variant_name': variantName,
//     'addons': addons?.map((e) => e.toJson()).toList(),
//     'removed_ingredients': removedIngredients?.map((e) => e.toJson()).toList(),
//     'menu_items': menuItems?.map((e) => e.toJson()).toList(),
//     'choice_groups': choiceGroups?.map((e) => e.toJson()).toList(),
//   };
// }

// // -------------------- ADDON --------------------
// class Addon {
//   final int id;
//   final String name;
//   final double price;
//   final int? quantity;

//   Addon({
//     required this.id,
//     required this.name,
//     required this.price,
//     this.quantity,
//   });

//   factory Addon.fromJson(Map<String, dynamic> json) {
//     return Addon(
//       id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
//       name: json['name']?.toString() ?? '',
//       price: _toDouble(json['price']),
//       quantity: json['quantity'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'price': price,
//     'quantity': quantity,
//   };
// }

// // -------------------- REMOVED INGREDIENT --------------------
// class RemovedIngredient {
//   final int id;
//   final String name;
//   final String? type;

//   RemovedIngredient({required this.id, required this.name, this.type});

//   factory RemovedIngredient.fromJson(Map<String, dynamic> json) {
//     return RemovedIngredient(
//       id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
//       name: json['name']?.toString() ?? '',
//       type: json['type']?.toString(),
//     );
//   }

//   Map<String, dynamic> toJson() => {'id': id, 'name': name, 'type': type};
// }

// // -------------------- MENU ITEM --------------------
// class MenuItem {
//   final int id;
//   final String name;
//   final double price;

//   MenuItem({required this.id, required this.name, required this.price});

//   factory MenuItem.fromJson(Map<String, dynamic> json) {
//     return MenuItem(
//       id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
//       name: json['name']?.toString() ?? '',
//       price: _toDouble(json['price']),
//     );
//   }

//   Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};
// }

// // -------------------- CHOICE GROUP --------------------
// class ChoiceGroup {
//   final String name;
//   final List<MenuItem> items;

//   ChoiceGroup({required this.name, required this.items});

//   factory ChoiceGroup.fromJson(Map<String, dynamic> json) {
//     return ChoiceGroup(
//       name: json['name']?.toString() ?? '',
//       items: (json['items'] as List).map((e) => MenuItem.fromJson(e)).toList(),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'name': name,
//     'items': items.map((e) => e.toJson()).toList(),
//   };
// }

// // -------------------- PAYMENT --------------------
// class Payment {
//   final int id;
//   final double amountReceived;
//   final double cashAmount;
//   final double cardAmount;
//   final String? paymentType;
//   final String? paymentStatus;
//   final List<PaidItem>? paidItems;

//   Payment({
//     required this.id,
//     required this.amountReceived,
//     required this.cashAmount,
//     required this.cardAmount,
//     this.paymentType,
//     this.paymentStatus,
//     this.paidItems,
//   });

//   factory Payment.fromJson(Map<String, dynamic> json) {
//     return Payment(
//       id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
//       amountReceived: _toDouble(json['amount_received']),
//       cashAmount: _toDouble(json['cash_amount']),
//       cardAmount: _toDouble(json['card_amount']),
//       paymentType: json['payment_type']?.toString(),
//       paymentStatus: json['payment_status']?.toString(),
//       paidItems: (json['paid_items'] as List?)
//           ?.map((e) => PaidItem.fromJson(e))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'amount_received': amountReceived,
//     'cash_amount': cashAmount,
//     'card_amount': cardAmount,
//     'payment_type': paymentType,
//     'payment_status': paymentStatus,
//     'paid_items': paidItems?.map((e) => e.toJson()).toList(),
//   };
// }

// class PaidItem {
//   final int id;
//   final String title;
//   final int quantity;
//   final double price;
//   final double amount;

//   PaidItem({
//     required this.id,
//     required this.title,
//     required this.quantity,
//     required this.price,
//     required this.amount,
//   });

//   factory PaidItem.fromJson(Map<String, dynamic> json) {
//     return PaidItem(
//       id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
//       title: json['title']?.toString() ?? '',
//       quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
//       price: _toDouble(json['price']),
//       amount: _toDouble(json['amount']),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'title': title,
//     'quantity': quantity,
//     'price': price,
//     'amount': amount,
//   };
// }
