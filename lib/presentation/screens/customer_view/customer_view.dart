import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tenxglobal_pos/core/services/customer_view_display_service/customer_display_eventbus.dart';
import 'package:tenxglobal_pos/presentation/provider/customer_provider.dart';

/// This is the entry point for the customer display (secondary screen)
class CustomerView extends StatelessWidget {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerProvider(),
      child: MaterialApp(
        title: 'Customer Display',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const CustomerDisplayScreen(),
      ),
    );
  }
}

/// The actual customer display screen
class CustomerDisplayScreen extends StatefulWidget {
  const CustomerDisplayScreen({super.key});

  @override
  State<CustomerDisplayScreen> createState() => _CustomerDisplayScreenState();
}

class _CustomerDisplayScreenState extends State<CustomerDisplayScreen> {
  static const MethodChannel _channel = MethodChannel(
      'uk.co.tenxglobal.tenxglobal_pos/customer_display_receiver');
  StreamSubscription<Map<String, dynamic>>? _eventBusSubscription;
  @override
  void initState() {
    super.initState();
    print('🎬 CustomerDisplayScreen initialized');
    _setupMethodChannel();
  }

  void _setupMethodChannel() {
    print('📡 Setting up method channel listener...');

    _channel.setMethodCallHandler((call) async {
      print('🎯 CustomerDisplayScreen received method: ${call.method}');

      switch (call.method) {
        case 'showCustomerDisplay':
        case 'updateCustomerDisplay':
          final data = call.arguments as Map?;
          if (data != null) {
            print('✅ Valid data received, updating view...');
            _updateCustomerView(data);
          } else {
            print('❌ No data in arguments!');
          }
          break;
        default:
          print('⚠️ Unknown method: ${call.method}');
      }
    });

    print('✅ Method channel handler set up successfully');
  }

  void _updateCustomerView(Map data) {
    print('═══════════════════════════════════════');
    print('📥 UPDATING CUSTOMER VIEW');
    print('Data keys: ${data.keys.toList()}');
    print('═══════════════════════════════════════');

    try {
      if (!mounted) return;

      // ✅ FIX: Deep convert Map<Object?, Object?> → Map<String, dynamic>
      Map<String, dynamic> deepConvert(dynamic input) {
        if (input is Map) {
          return Map<String, dynamic>.from(
            input.map((key, value) => MapEntry(
                  key.toString(),
                  value is Map
                      ? deepConvert(value)
                      : value is List
                          ? value
                              .map((e) => e is Map ? deepConvert(e) : e)
                              .toList()
                          : value,
                )),
          );
        }
        return {};
      }

      final normalized = deepConvert(data);

      // Unwrap "data" if exists
      final finalPayload = normalized.containsKey('data')
          ? deepConvert(normalized['data'])
          : normalized;

      final provider = Provider.of<CustomerProvider>(context, listen: false);
      provider.addOrderFromJson(finalPayload);

      print('✅ Provider updated from MethodChannel');
    } catch (e, stackTrace) {
      print('❌ Error updating provider: $e');
      print(stackTrace);
    }
  }

  @override
  void dispose() {
    _eventBusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 Building CustomerDisplayScreen...');

    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        print('══════════════════════════════════════');
        print('🔄 Consumer rebuilding...');
        print('   Provider orders count: ${provider.orders.length}');

        final order = provider.orders.isEmpty ? null : provider.orders.first;
        final items = order?.order.items ?? [];

        print('   Current order: ${order != null ? 'EXISTS' : 'NULL'}');
        print('   Items count: ${items.length}');
        print('══════════════════════════════════════');

        return Scaffold(
          body: SafeArea(
            minimum: EdgeInsets.zero,
            child: Row(
              children: [
                // Left side - Branding/Image
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/smashNGrub.jpeg',
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stack) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.blue.shade900,
                                    Colors.black,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.restaurant,
                                      size: 100,
                                      color: Colors.white54,
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      'Welcome',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // DEBUG INFO OVERLAY
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white30, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🔍 Debug Info',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(color: Colors.white30, height: 8),
                              Text(
                                'Orders: ${provider.orders.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'Items: ${items.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                order != null ? '✅ HAS DATA' : '❌ NO DATA',
                                style: TextStyle(
                                  color: order != null
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (order != null) ...[
                                const Divider(color: Colors.white30, height: 8),
                                Text(
                                  order.order.customer,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  '£${order.order.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right side - Order details
                items.isEmpty
                    ? Expanded(
                        flex: 2,
                        child: Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Waiting for order...',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Container(
                                height: 70.0,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1B1670),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Text(
                                      order?.order.orderType ?? 'Takeaway',
                                      style: const TextStyle(
                                        color: Color(0xFF1B1670),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20.0),

                              // Content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Customer Info
                                      const Text(
                                        'Customer',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            width: 0.5,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                        child: Text(
                                          order?.order.customer ?? 'Walk-in',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12.0),

                                      // Items List
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(12.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                              width: 0.5,
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: ListView.separated(
                                            itemCount: items.length,
                                            separatorBuilder: (_, __) =>
                                                const Divider(thickness: 0.3),
                                            itemBuilder: (context, index) {
                                              final item = items[index];
                                              return Row(
                                                children: [
                                                  // Image
                                                  Image.network(
                                                    item.img,
                                                    height: 45,
                                                    errorBuilder: (context,
                                                        error, stack) {
                                                      return const Icon(
                                                        Icons.fastfood,
                                                        size: 45,
                                                        color: Colors.grey,
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 8),

                                                  // Details
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item.title,
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        if (item.variantName !=
                                                            null)
                                                          Text(
                                                            "Variant: ${item.variantName}",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                          ),
                                                        if (item
                                                            .addons.isNotEmpty)
                                                          Wrap(
                                                            children: item
                                                                .addons
                                                                .map((addon) {
                                                              return Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2.0),
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          4.0),
                                                                  child: Text(
                                                                    '${addon.name} (£${addon.price.toStringAsFixed(2)})',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11.0,
                                                                      color: Colors
                                                                          .black54,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Quantity
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color.fromARGB(
                                                          255, 231, 231, 229),
                                                    ),
                                                    child: Text(
                                                      'x${item.qty}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(width: 8),

                                                  // Price
                                                  Text(
                                                    '£${item.price.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 5.0),
                                      const Divider(thickness: 0.5),
                                      const SizedBox(height: 15.0),

                                      // Totals
                                      _buildTotalRow(
                                          'Subtotal', order?.order.subtotal),
                                      const SizedBox(height: 5.0),
                                      _buildTotalRow('Tax', order?.order.tax),
                                      const SizedBox(height: 5.0),
                                      _buildTotalRow('Service',
                                          order?.order.serviceCharges),
                                      const SizedBox(height: 5.0),
                                      _buildTotalRow(
                                        'Sale Discount',
                                        order?.order.saleDiscount,
                                        isNegative: true,
                                      ),
                                      const SizedBox(height: 5.0),
                                      const Divider(thickness: 0.5),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            '£${order?.order.total.toStringAsFixed(2) ?? '0.00'}',
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1B1670),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
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
            color: isNegative ? Colors.red : Colors.black87,
          ),
        ),
        Text(
          '${isNegative ? '- ' : ''}£${amount?.toStringAsFixed(2) ?? '0.00'}',
          style: TextStyle(
            color: isNegative ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
