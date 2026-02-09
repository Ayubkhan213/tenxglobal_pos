// import 'dart:convert';

// // ==========================
// // RESPONSE MODEL
// // ==========================
// class CartResponse {
//   final CartData cartData;

//   CartResponse({required this.cartData});

//   factory CartResponse.fromJson(Map<String, dynamic> json) {
//     return CartResponse(cartData: CartData.fromJson(json['cartData']));
//   }

//   Map<String, dynamic> toJson() => {'cartData': cartData.toJson()};
// }

// // ==========================
// // CART DATA
// // ==========================
// class CartData {
//   final List<Item> items;
//   final String customer;
//   final String phoneNumber;
//   final String deliveryLocation;
//   final String orderType;
//   final String? table;
//   final double subtotal;
//   final double tax;
//   final double serviceCharges;
//   final double deliveryCharges;
//   final double saleDiscount;
//   final double promoDiscount;
//   final double total;
//   final String note;
//   final List<dynamic> appliedPromos;

//   CartData({
//     required this.items,
//     required this.customer,
//     required this.phoneNumber,
//     required this.deliveryLocation,
//     required this.orderType,
//     this.table,
//     required this.subtotal,
//     required this.tax,
//     required this.serviceCharges,
//     required this.deliveryCharges,
//     required this.saleDiscount,
//     required this.promoDiscount,
//     required this.total,
//     required this.note,
//     required this.appliedPromos,
//   });

//   factory CartData.fromJson(Map<String, dynamic> json) {
//     return CartData(
//       items:
//           (json['items'] as List).map((item) => Item.fromJson(item)).toList(),
//       customer: json['customer'] ?? '',
//       phoneNumber: json['phone_number'] ?? '',
//       deliveryLocation: json['delivery_location'] ?? '',
//       orderType: json['orderType'] ?? '',
//       table: json['table'],
//       subtotal: (json['subtotal'] as num).toDouble(),
//       tax: (json['tax'] as num).toDouble(),
//       serviceCharges: (json['serviceCharges'] as num).toDouble(),
//       deliveryCharges: (json['deliveryCharges'] as num).toDouble(),
//       saleDiscount: (json['saleDiscount'] as num).toDouble(),
//       promoDiscount: (json['promoDiscount'] as num).toDouble(),
//       total: (json['total'] as num).toDouble(),
//       note: json['note'] ?? '',
//       appliedPromos: json['appliedPromos'] ?? [],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'items': items.map((e) => e.toJson()).toList(),
//         'customer': customer,
//         'phone_number': phoneNumber,
//         'delivery_location': deliveryLocation,
//         'orderType': orderType,
//         'table': table,
//         'subtotal': subtotal,
//         'tax': tax,
//         'serviceCharges': serviceCharges,
//         'deliveryCharges': deliveryCharges,
//         'saleDiscount': saleDiscount,
//         'promoDiscount': promoDiscount,
//         'total': total,
//         'note': note,
//         'appliedPromos': appliedPromos,
//       };
// }

// // ==========================
// // ITEM MODEL
// // ==========================
// class Item {
//   final int id;
//   final String title;
//   final String img;
//   final double price;
//   final int qty;
//   final String? variantName;
//   final List<Addon> addons;
//   final double resaleDiscountPerItem;

//   Item({
//     required this.id,
//     required this.title,
//     required this.img,
//     required this.price,
//     required this.qty,
//     this.variantName,
//     required this.addons,
//     required this.resaleDiscountPerItem,
//   });

//   factory Item.fromJson(Map<String, dynamic> json) {
//     return Item(
//       id: json['id'],
//       title: json['title'],
//       img: json['img'],
//       price: (json['price'] as num).toDouble(),
//       qty: json['qty'],
//       variantName: json['variant_name'],
//       addons: (json['addons'] as List)
//           .map((addon) => Addon.fromJson(addon))
//           .toList(),
//       resaleDiscountPerItem:
//           (json['resale_discount_per_item'] as num).toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'title': title,
//         'img': img,
//         'price': price,
//         'qty': qty,
//         'variant_name': variantName,
//         'addons': addons.map((e) => e.toJson()).toList(),
//         'resale_discount_per_item': resaleDiscountPerItem,
//       };
// }

// // ==========================
// // ADDON MODEL
// // ==========================
// class Addon {
//   final int id;
//   final String name;
//   final double price;

//   Addon({required this.id, required this.name, required this.price});

//   factory Addon.fromJson(Map<String, dynamic> json) {
//     return Addon(
//       id: json['id'],
//       name: json['name'],
//       price: (json['price'] as num).toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};
// }

// // ==========================
// // USAGE EXAMPLE
// // ==========================
class CartResponse {
  final CartData order;
  final String type;
  final String print;

  CartResponse({
    required this.order,
    required this.type,
    required this.print,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? orderJson;

    // Case 1: { data: { order: {...} } }
    if (json['data'] is Map && (json['data'] as Map).containsKey('order')) {
      orderJson = (json['data'] as Map<String, dynamic>)['order']
          as Map<String, dynamic>;
    }

    // Case 2: { order: {...} }
    else if (json['order'] is Map) {
      orderJson = json['order'] as Map<String, dynamic>;
    }

    // Case 3: order object directly
    else {
      orderJson = json;
    }

    return CartResponse(
      order: CartData.fromJson(orderJson),
      type: json['type']?.toString() ?? '',
      print: json['print']?.toString() ?? 'no',
    );
  }
}

class CartData {
  final List<Item> items;
  final String customer;
  final String phoneNumber;
  final String deliveryLocation;
  final String orderType;
  final String? table;
  final double subtotal;
  final double tax;
  final double serviceCharges;
  final double deliveryCharges;
  final double saleDiscount;
  final double promoDiscount;
  final double total;
  final String note;
  final List<dynamic> appliedPromos;

  CartData({
    required this.items,
    required this.customer,
    required this.phoneNumber,
    required this.deliveryLocation,
    required this.orderType,
    this.table,
    required this.subtotal,
    required this.tax,
    required this.serviceCharges,
    required this.deliveryCharges,
    required this.saleDiscount,
    required this.promoDiscount,
    required this.total,
    required this.note,
    required this.appliedPromos,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];

    final itemsList = (itemsRaw is List)
        ? itemsRaw.whereType<Map<String, dynamic>>().map(Item.fromJson).toList()
        : <Item>[];

    String getString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        if (json[key] != null) return json[key].toString();
      }
      return fallback;
    }

    return CartData(
      items: itemsList,
      customer: getString(['customer'], fallback: 'Walk-in Customer'),
      phoneNumber: getString(['phoneNumber', 'phone_number']),
      deliveryLocation: getString(['deliveryLocation', 'delivery_location']),
      orderType: getString(['orderType', 'order_type'], fallback: 'Takeaway'),
      table: json['table']?.toString(),
      subtotal: _parseDouble(json['subtotal']),
      tax: _parseDouble(json['tax']),
      serviceCharges:
          _parseDouble(json['serviceCharges'] ?? json['service_charges']),
      deliveryCharges:
          _parseDouble(json['deliveryCharges'] ?? json['delivery_charges']),
      saleDiscount: _parseDouble(json['saleDiscount'] ?? json['sale_discount']),
      promoDiscount:
          _parseDouble(json['promoDiscount'] ?? json['promo_discount']),
      total: _parseDouble(json['total']),
      note: json['note']?.toString() ?? '',
      appliedPromos: json['appliedPromos'] ?? json['applied_promos'] ?? [],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class Item {
  final int id;
  final String title;
  final String img;
  final double price;
  final int qty;
  final String? variantName;
  final List<Addon> addons;
  final double resaleDiscountPerItem;

  Item({
    required this.id,
    required this.title,
    required this.img,
    required this.price,
    required this.qty,
    this.variantName,
    required this.addons,
    required this.resaleDiscountPerItem,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    // Parse addons safely
    final List<Addon> addonsList = [];
    if (json['addons'] is List) {
      for (final addon in json['addons']) {
        try {
          addonsList.add(Addon.fromJson(addon));
        } catch (_) {}
      }
    }

    return Item(
      id: json['id'] ?? 0, // ✅ SAFE DEFAULT
      title: json['title']?.toString() ?? 'Unknown Item',
      img: json['img']?.toString() ?? 'https://via.placeholder.com/100',
      price: CartData._parseDouble(json['price']),
      qty: json['qty'] ?? 1,
      variantName: json['variantName']?.toString(),
      addons: addonsList,
      resaleDiscountPerItem:
          CartData._parseDouble(json['resaleDiscountPerItem']),
    );
  }
}

class Addon {
  final int id;
  final String name;
  final double price;

  Addon({
    required this.id,
    required this.name,
    required this.price,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'Unknown Addon',
      price: CartData._parseDouble(json['price']),
    );
  }
}
