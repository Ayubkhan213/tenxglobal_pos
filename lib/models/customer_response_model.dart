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
    return CartResponse(
      order: CartData.fromJson(json['order'] ?? {}),
      type: json['type'] ?? '',
      print: json['print'] ?? '',
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
    return CartData(
      items:
          (json['items'] as List? ?? []).map((e) => Item.fromJson(e)).toList(),
      customer: json['customer'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      deliveryLocation: json['delivery_location'] ?? '',
      orderType: json['orderType'] ?? '',
      table: json['table'],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      serviceCharges: (json['serviceCharges'] as num?)?.toDouble() ?? 0,
      deliveryCharges: (json['deliveryCharges'] as num?)?.toDouble() ?? 0,
      saleDiscount: (json['saleDiscount'] as num?)?.toDouble() ?? 0,
      promoDiscount: (json['promoDiscount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      note: json['note'] ?? '',
      appliedPromos: json['appliedPromos'] ?? [],
    );
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
    return Item(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      img: json['img'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      qty: json['qty'] ?? 0,
      variantName: json['variant_name'],
      addons: (json['addons'] as List? ?? [])
          .map((e) => Addon.fromJson(e))
          .toList(),
      resaleDiscountPerItem:
          (json['resale_discount_per_item'] as num?)?.toDouble() ?? 0,
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
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
