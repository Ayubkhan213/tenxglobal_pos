import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenxglobal_pos/provider/customer_provider.dart';

class RightSideMenuContent extends StatelessWidget {
  final VoidCallback onClose;

  const RightSideMenuContent({
    super.key,
    required this.onClose,
  });

  // Dummy data method
  void _addDummyData(BuildContext context) {
    final dummyJson = {
      "cartData": {
        "items": [
          {
            "id": 1,
            "title": "Margherita Pizza",
            "img": "https://via.placeholder.com/150",
            "price": 200.99,
            "qty": 2,
            "variant_name": "Large",
            "addons": [
              {"id": 1, "name": "Extra Cheese", "price": 2.50},
              {"id": 2, "name": "Olives", "price": 1.50}
            ],
            "resale_discount_per_item": 0.50
          },
          {
            "id": 2,
            "title": "Chicken Burger",
            "img": "https://via.placeholder.com/150",
            "price": 8.99,
            "qty": 1,
            "variant_name": "Regular",
            "addons": [
              {"id": 3, "name": "Bacon", "price": 2.00}
            ],
            "resale_discount_per_item": 0.00
          },
          {
            "id": 3,
            "title": "Caesar Salad",
            "img": "https://via.placeholder.com/150",
            "price": 7.50,
            "qty": 1,
            "variant_name": null,
            "addons": [],
            "resale_discount_per_item": 0.00
          },
          {
            "id": 3,
            "title": "Caesar Salad",
            "img": "https://via.placeholder.com/150",
            "price": 7.50,
            "qty": 1,
            "variant_name": null,
            "addons": [],
            "resale_discount_per_item": 0.00
          }
        ],
        "customer": "John Doe",
        "phone_number": "+44 7700 900123",
        "delivery_location": "123 Main Street, London",
        "orderType": "Delivery",
        "table": null,
        "subtotal": 42.47,
        "tax": 8.49,
        "serviceCharges": 2.50,
        "deliveryCharges": 3.50,
        "saleDiscount": 5.00,
        "promoDiscount": 2.00,
        "total": 249.96,
        "note": "Please ring the doorbell twice",
        "appliedPromos": ["WELCOME10", "FREESHIP"]
      }
    };

    Provider.of<CustomerProvider>(
      context,
      listen: false,
    ).addOrderFromJson(dummyJson);

    // Show a snackbar to confirm
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dummy order added successfully!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          final order = provider.orders == null || provider.orders.isEmpty
              ? null
              : provider.orders.first;
          final items = order == null ? [] : order.order.items ?? [];

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1670),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Order Type Badge
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        order != null ? order.order.orderType : 'Takeaway',
                        style: const TextStyle(
                          color: Color(0xFF1B1670),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Action Buttons
                    Row(
                      children: [
                        // Add Dummy Data Button
                        // IconButton(
                        //   icon:
                        //       const Icon(Icons.add_circle, color: Colors.white),
                        //   tooltip: 'Add Dummy Order',
                        //   onPressed: () => _addDummyData(context),
                        // ),
                        // const SizedBox(width: 8),
                        // Close Button
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: onClose,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20.0),

              // Content
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No order items',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _addDummyData(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Dummy Order'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B1670),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer Section
                            const Text(
                              'Customer',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order != null
                                        ? order.order.customer
                                        : 'Walk-in',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (order != null &&
                                      order.order.phoneNumber.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        order.order.phoneNumber,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            // Items List
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: ListView.separated(
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) => const Divider(
                                    thickness: 0.5,
                                    height: 24,
                                  ),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            item.img,
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stack) {
                                              return Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.fastfood,
                                                  size: 30,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Name and details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              if (item.variantName != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2.0),
                                                  child: Text(
                                                    "Variant: ${item.variantName}",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              if (item.addons.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4.0),
                                                  child: Wrap(
                                                    spacing: 4,
                                                    runSpacing: 4,
                                                    children: item.addons
                                                        .map<Widget>((addon) {
                                                      return Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.blue[50],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                          border: Border.all(
                                                            color: Colors
                                                                .blue[200]!,
                                                            width: 0.5,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          '${addon.name} (+£${addon.price.toStringAsFixed(2)})',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        // Quantity and Price
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1B1670),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'x${item.qty ?? 0}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '£${item.price?.toStringAsFixed(2) ?? '0.00'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 16.0),

                            // Totals Section
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildTotalRow(
                                      'Subtotal', order?.order.subtotal),
                                  const SizedBox(height: 8.0),
                                  _buildTotalRow('Tax', order?.order.tax),
                                  const SizedBox(height: 8.0),
                                  _buildTotalRow(
                                      'Service', order?.order.serviceCharges),
                                  const SizedBox(height: 8.0),
                                  _buildTotalRow(
                                      'Delivery', order?.order.deliveryCharges),
                                  const SizedBox(height: 8.0),
                                  _buildTotalRow(
                                    'Sale Discount',
                                    order?.order.saleDiscount,
                                    isNegative: true,
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    child: Divider(thickness: 1),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        order != null
                                            ? '£${order.order.total.toStringAsFixed(2)}'
                                            : '£0.00',
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B1670),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalRow(String label, double? amount,
      {bool isNegative = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isNegative ? Colors.red[700] : Colors.black87,
          ),
        ),
        Text(
          amount != null
              ? '${isNegative ? '- ' : ''}£${amount.toStringAsFixed(2)}'
              : '£0.00',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isNegative ? Colors.red[700] : Colors.black87,
          ),
        ),
      ],
    );
  }
}
