// ignore_for_file: avoid_print

import 'dart:io'; // ADD THIS LINE!
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tenxglobal_pos/core/screen/customer/right_side_menu.dart';
import 'package:tenxglobal_pos/core/screen/customer/right_side_menu_context.dart';
import 'package:tenxglobal_pos/core/services/server/app_info_service.dart';

import 'package:tenxglobal_pos/core/services/server/server.dart';
import 'package:tenxglobal_pos/login.dart';
import 'package:tenxglobal_pos/models/business_info_model.dart';
import 'package:tenxglobal_pos/models/printer_model.dart' hide Printer;
import 'package:tenxglobal_pos/provider/customer_provider.dart';
import 'package:tenxglobal_pos/provider/login_provider.dart';
import 'package:tenxglobal_pos/provider/printing_agant_provider.dart';
import 'config.dart';

// import 'package:flutter/rendering.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInfoService.instance.init();

  // debugPaintSizeEnabled = true;
  // Initialize Hive
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  // Register all Hive adapters
  Hive.registerAdapter(BusinessInfoModelAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(BusinessAdapter());
  Hive.registerAdapter(PrinterAdapter());

  // Open boxes
  await Hive.openBox<BusinessInfoModel>('businessInfo');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => PrintingAgentProviderMobile()),
      ],
      child: const POSAgentApp(),
    ),
  );
}

class POSAgentApp extends StatelessWidget {
  const POSAgentApp({super.key});

  // static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerProvider(),
      child: MaterialApp(
        title: 'POS Agent',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _serverStarted = false;
  int _posTapCount = 0;
  DateTime? _lastTapTime;
  bool _showRightMenu = false; // Track menu visibility

  final List<GlobalKey<POSWebViewScreenState>> _pageKeys = [
    GlobalKey<POSWebViewScreenState>(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_serverStarted) {
        _serverStarted = true;
        ServerServices.startLocalServer(context);
        print("Local server initialization started");
      }
    });
  }

  final _pages = const [
    POSWebViewScreen(),
    LoginScreen(),
  ];

  void _handlePOSTap() {
    final now = DateTime.now();

    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 500)) {
      // Double tap detected - Toggle right side menu
      setState(() {
        _showRightMenu = !_showRightMenu;
      });
      _posTapCount = 0;
    } else {
      // Single tap - navigate normally
      setState(() => _currentIndex = 0);
      _posTapCount = 1;
    }

    _lastTapTime = now;
  }

  void _closeRightMenu() {
    setState(() {
      _showRightMenu = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            IndexedStack(
              index: _currentIndex,
              children: [
                POSWebViewScreen(key: _pageKeys[0]),
                _pages[1],
              ],
            ),

            // Right side menu (animated slide-in)
            if (_showRightMenu)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 0.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(
                        MediaQuery.of(context).size.width * 0.4 * value,
                        0,
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(-5, 0),
                        ),
                      ],
                    ),
                    child: RightSideMenuContent(
                      onClose: _closeRightMenu,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 0) {
            _handlePOSTap();
          } else {
            setState(() => _currentIndex = i);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'POS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.print),
            label: 'Printing',
          ),
        ],
      ),
    );
  }
}

class POSWebViewScreen extends StatefulWidget {
  const POSWebViewScreen({super.key});

  @override
  State<POSWebViewScreen> createState() => POSWebViewScreenState();
}

class POSWebViewScreenState extends State<POSWebViewScreen> {
  InAppWebViewController? _webViewController;
  late PullToRefreshController _pullToRefreshController;
  double _progress = 0;

  @override
  void initState() {
    super.initState();

    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blueAccent,
        backgroundColor: Colors.white,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          _webViewController?.reload();
        } else if (Platform.isIOS) {
          _webViewController?.loadUrl(
              urlRequest: URLRequest(url: await _webViewController?.getUrl()));
        }
      },
    );
  }

  // Call this to reload the WebView
  void reloadWebView() {
    if (_webViewController != null) {
      _webViewController!.reload();
      print("WebView reloaded!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_webViewController != null) {
          final canGoBack = await _webViewController!.canGoBack();
          if (canGoBack) {
            _webViewController!.goBack();
            return false;
          }
        }
        return false;
      },
      child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(AppConfig.posUrl)),
            pullToRefreshController: _pullToRefreshController,
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              supportZoom: false,
              useOnDownloadStart: true,
              useShouldOverrideUrlLoading: true,
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              print("WebView created");
            },
            onLoadStart: (controller, url) {
              setState(() => _progress = 0);
            },
            onLoadStop: (controller, url) async {
              setState(() => _progress = 0);
              _pullToRefreshController.endRefreshing();
            },
            onProgressChanged: (controller, progress) {
              setState(() => _progress = progress / 100);
            },
            onReceivedError: (controller, request, error) {
              print('WebView error: $error');
              _pullToRefreshController.endRefreshing();
            },
          ),
          if (_progress > 0 && _progress < 1)
            Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey.shade800,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                minHeight: 3,
              ),
            ),
        ],
      ),
    );
  }
}








// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:tenxglobal_pos/core/constants/utils.dart';
// import 'package:tenxglobal_pos/login.dart';
// import 'package:tenxglobal_pos/models/business_info_model.dart';
// import 'package:tenxglobal_pos/models/order_response_model.dart';
// import 'package:tenxglobal_pos/models/printer_model.dart' hide Printer;
// import 'package:tenxglobal_pos/pdf_slip/pdf_slip_preview.dart';
// import 'package:tenxglobal_pos/print_server.dart';
// import 'package:tenxglobal_pos/provider/login_provider.dart';
// import 'package:tenxglobal_pos/provider/printing_agant_provider.dart';
// import 'package:tenxglobal_pos/recept_printing.dart';

// import 'config.dart';
// import 'printer_service.dart';
// import 'settings_screen.dart';

// // Add this line after all your imports, before any functions
// String? _serverIp;
// Future<List<String>> getAllLocalIps() async {
//   List<String> ips = [];
//   try {
//     for (var interface in await NetworkInterface.list()) {
//       for (var addr in interface.addresses) {
//         if (addr.type == InternetAddressType.IPv4 &&
//             !addr.address.startsWith('127')) {
//           ips.add("${interface.name}: ${addr.address}");
//         }
//       }
//     }
//   } catch (e) {
//     print("Error getting local IPs: $e");
//   }
//   return ips;
// }

// Future<String> getLocalIp() async {
//   try {
//     // Prioritize WiFi and Ethernet interfaces
//     final interfaces = await NetworkInterface.list();

//     // First, try to find WiFi or Ethernet
//     for (var interface in interfaces) {
//       final name = interface.name.toLowerCase();
//       if (name.contains('wlan') ||
//           name.contains('wi-fi') ||
//           name.contains('wifi') ||
//           name.contains('en0') ||
//           name.contains('eth')) {
//         for (var addr in interface.addresses) {
//           if (addr.type == InternetAddressType.IPv4 &&
//               !addr.address.startsWith('127') &&
//               !addr.address.startsWith('169.254')) {
//             print("✅ Primary Network IP: ${addr.address} (${interface.name})");
//             return addr.address;
//           }
//         }
//       }
//     }

//     // Fallback: any non-localhost IPv4
//     for (var interface in interfaces) {
//       for (var addr in interface.addresses) {
//         if (addr.type == InternetAddressType.IPv4 &&
//             !addr.address.startsWith('127') &&
//             !addr.address.startsWith('169.254')) {
//           print(⚠️  Using IP: ${addr.address} (${interface.name})");
//           return addr.address;
//         }
//       }
//     }
//   } catch (e) {
//     print("Error getting local IP: $e");
//   }
//   return "127.0.0.1"; // Changed from 0.0.0.0
// }

// void startLocalServer(BuildContext context) async {
//   try {
//     // Bind to all network interfaces (0.0.0.0) to accept external connections
//     final server = await HttpServer.bind(
//       InternetAddress.anyIPv4,
//       8085,
//       shared: true, // Changed to false for better compatibility
//     );

//     // Set backlog for incoming connections
//     server.autoCompress = true;

//     final localIp = await getLocalIp();
//     _serverIp = localIp;
//     final allIps = await getAllLocalIps();

//     print("════════════════════════════════════════");
//     print("🚀 SERVER STARTED SUCCESSFULLY");
//     print("════════════════════════════════════════");
//     print("📍 Local Access:     http://localhost:8085");
//     print("📍 Primary IP:       http://$localIp:8085");
//     print("════════════════════════════════════════");
//     print("🌐 ALL AVAILABLE NETWORK INTERFACES:");
//     for (var ip in allIps) {
//       print("   $ip");
//     }
//     print("════════════════════════════════════════");
//     print("📋 Available Endpoints:");
//     print("   POST http://$localIp:8085/print");
//     print("   GET  http://$localIp:8085/status");
//     print("════════════════════════════════════════");
//     print("⚠️  TROUBLESHOOTING:");
//     print("   1. Use Desktop Agent in Postman (not Cloud)");
//     print("   2. Make sure firewall allows port 8085");
//     print("   3. Both devices on same WiFi network");
//     print("   4. Try pinging: ping $localIp");
//     print("════════════════════════════════════════\n");

//     await for (HttpRequest request in server) {
//       print('--------------------');
//       print(request);

//       // Enhanced CORS headers for web access
//       request.response.headers.add('Access-Control-Allow-Origin', '*');
//       request.response.headers.add(
//         'Access-Control-Allow-Methods',
//         'GET, POST, PUT, DELETE, OPTIONS',
//       );
//       request.response.headers.add(
//         'Access-Control-Allow-Headers',
//         'Origin, Content-Type, Accept, Authorization, X-Requested-With',
//       );
//       request.response.headers.add('Access-Control-Max-Age', '86400');
//       request.response.headers.add('Content-Type', 'application/json');

//       // Log incoming requests with more details
//       print(
//         "📥 ${request.method} ${request.uri.path} from ${request.connectionInfo?.remoteAddress.address}",
//       );
//       print("   Headers: ${request.headers.value('content-type')}");
//       print("   Origin: ${request.headers.value('origin') ?? 'N/A'}");

//       // Handle CORS preflight requests
//       if (request.method == 'OPTIONS') {
//         print(" CORS preflight passed - waiting for actual request...");
//         request.response
//           ..statusCode = 204
//           ..close();
//         continue;
//       }

//       if (request.method == 'POST' && request.uri.path == '/print') {
//         try {
//           print("📨 Reading request body...");
//           String body = await utf8.decoder.bind(request).join();
//           print(
//             "📦 Body received: ${body.substring(0, body.length > 200 ? 200 : body.length)}...",
//           );

//           var data = jsonDecode(body);
//           print('==================================');
//           print(data);
//           print('==================================');
//           var res = OrderResponse.fromJson(data);
//           print('----------------');
//           Utils.resApiResponse = res;

//           print(res);
//           print('----------------------');
//           print("📄 Print request received: $data");

//           // Validate required fields
//           if (res.order == null) {
//             _sendErrorResponse(
//               request,
//               400,
//               'VALIDATION_ERROR',
//               'Missing required field: order_id',
//             );
//             continue;
//           }

//           List<String> successMessages = [];
//           List<String> errorMessages = [];
//           bool anyPrintSuccess = false;
//           print('------------------ Printer type ----------------');
//           print(res.type);
//           // ========================================
//           // STEP 2: HANDLE KOT PRINTING
//           // ========================================
//           if (res.type == 'customer') {
//             print('2222222222222222222');
//             // Validate Customer printer
//             // final validCustomerPrinter = await provider.validatePrinter(
//             //   provider.customerPrinter,
//             // );

//             // if (validCustomerPrinter == null) {
//             //   if (provider.customerPrinter == null) {
//             //     errorMessages.add(
//             //       'Customer printer not configured. Please select a customer printer in settings.',
//             //     );
//             //   } else {
//             //     errorMessages.add(
//             //       'Customer printer "${provider.customerPrinter!.name}" is not connected. Please check the printer connection.',
//             //     );
//             //   }
//             // } else {
//             try {
//               print('----------------- Customer Reept ----------------');
//               await ReceiptPrinterMobile.printReceipt(
//                 context: context,
//                 orderResponse: res,
//               );
//               successMessages.add(
//                 'Customer receipt printed successfully on ""',
//               );
//               anyPrintSuccess = true;
//               print("✅ Customer receipt printed successfully");
//             } catch (e) {
//               errorMessages.add(
//                 'Customer receipt printing failed: ${e.toString()}',
//               );
//               print("❌ Customer receipt printing failed: $e");
//             }
//           }
//           if (res.type == 'kot') {
//             // Validate KOT printer
//             // final validKotPrinter = await provider.validatePrinter(
//             //   provider.kotPrinter,
//             // );

//             //   // if (validKotPrinter == null) {
//             //   if (provider.kotPrinter == null) {
//             //     errorMessages.add(
//             //       'KOT printer not configured. Please select a KOT printer in settings.',
//             //     );
//             //   } else {
//             //     try {
//             //       print('------------------ KOT Printer -------------------');
//             //       await ReceiptPrinter.printKOT(
//             //         context: context,
//             //         orderId: orderId,
//             //         orderType: orderType,
//             //         items: items,
//             //       );
//             //       successMessages.add('KOT printed successfully on');
//             //       anyPrintSuccess = true;
//             //       print("✅ KOT printed successfully");
//             //     } catch (e) {
//             //       errorMessages.add('KOT printing failed: ${e.toString()}');
//             //       print("❌ KOT printing failed: $e");
//             //     }
//             //     errorMessages.add(
//             //       'KOT printer "${provider.kotPrinter!.name}" is not connected. Please check the printer connection.',
//             //     );
//             //   }
//             // }
//             // // else {
//             // //   try {
//             // //     print('------------------ KOT Printer -------------------');
//             // //     await ReceiptDialogPreviewer.showKOTPreview(
//             // //       context: context,
//             // //       orderId: orderId,
//             // //       orderType: orderType,
//             // //       items: items,
//             // //     );
//             // //     successMessages.add('KOT printed successfully on');
//             // //     anyPrintSuccess = true;
//             // //     print("✅ KOT printed successfully");
//             // //   } catch (e) {
//             // //     errorMessages.add('KOT printing failed: ${e.toString()}');
//             // //     print("❌ KOT printing failed: $e");
//             // //   }
//             // //   // }
//             // // }

//             // // ========================================
//             // // STEP 3: HANDLE CUSTOMER RECEIPT PRINTING
//             // // ========================================
//           }

//           // // ========================================
//           // // STEP 4: SEND RESPONSE
//           // // ========================================
//           // if (anyPrintSuccess) {
//           //   // Partial or full success
//           //   if (errorMessages.isEmpty) {
//           //     _sendSuccessResponse(
//           //       request,
//           //       200,
//           //       'SUCCESS',
//           //       'All print jobs completed successfully',
//           //       successMessages: successMessages,
//           //     );
//           //   } else {
//           //     _sendPartialSuccessResponse(
//           //       request,
//           //       207, // Multi-Status
//           //       'PARTIAL_SUCCESS',
//           //       'Some print jobs completed, but others failed',
//           //       successMessages: successMessages,
//           //       errorMessages: errorMessages,
//           //     );
//           //   }
//           // } else {
//           //   // Complete failure
//           //   _sendErrorResponse(
//           //     request,
//           //     503, // Service Unavailable
//           //     'PRINTER_ERROR',
//           //     'No print jobs could be completed',
//           //     errors: errorMessages,
//           //   );
//           // }
//         } catch (e, stackTrace) {
//           print("❌ Server error: $e");
//           print("Stack trace: $stackTrace");
//           _sendErrorResponse(
//             request,
//             500,
//             'SERVER_ERROR',
//             'An unexpected error occurred while processing the print request',
//             errors: [e.toString()],
//           );
//         }
//       } else if (request.method == 'GET' && request.uri.path == '/status') {
//         // Health check endpoint
//         // final provider = Provider.of<PrintingAgentProvider>(
//         //   context,
//         //   listen: false,
//         // );

//         // await provider.loadPrinters();

//         print("✅ Status check completed");

//         // request.response
//         //   ..statusCode = 200
//         //   ..write(
//         //     jsonEncode({
//         //       'status': 'online',
//         //       'server_ip': await getLocalIp(),
//         //       'timestamp': DateTime.now().toIso8601String(),
//         //       'printers': {
//         //         'customer': provider.customerPrinter != null
//         //             ? {
//         //                 'name': provider.customerPrinter!.name,
//         //                 'connected': provider.availablePrinters.any(
//         //                   (p) => p.url == provider.customerPrinter!.url,
//         //                 ),
//         //               }
//         //             : null,
//         //         'kot': provider.kotPrinter != null
//         //             ? {
//         //                 'name': provider.kotPrinter!.name,
//         //                 'connected': provider.availablePrinters.any(
//         //                   (p) => p.url == provider.kotPrinter!.url,
//         //                 ),
//         //               }
//         //             : null,
//         //       },
//         //       'available_printers_count': provider.availablePrinters.length,
//         //     }),
//         //   )
//         //   ..close();
//       } else {
//         _sendErrorResponse(
//           request,
//           404,
//           'NOT_FOUND',
//           'Endpoint not found. Available endpoints: POST /print, GET /status',
//         );
//       }
//     }
//   } catch (e, stackTrace) {
//     print("❌ Failed to start server: $e");
//     print("Stack trace: $stackTrace");
//   }
// }

// // ========================================
// // RESPONSE HELPER FUNCTIONS
// // ========================================

// void _sendSuccessResponse(
//   HttpRequest request,
//   int statusCode,
//   String status,
//   String message, {
//   List<String>? successMessages,
// }) {
//   request.response
//     ..statusCode = statusCode
//     ..write(
//       jsonEncode({
//         'status': status,
//         'message': message,
//         'timestamp': DateTime.now().toIso8601String(),
//         if (successMessages != null && successMessages.isNotEmpty)
//           'details': successMessages,
//       }),
//     )
//     ..close();
// }

// void _sendPartialSuccessResponse(
//   HttpRequest request,
//   int statusCode,
//   String status,
//   String message, {
//   List<String>? successMessages,
//   List<String>? errorMessages,
// }) {
//   request.response
//     ..statusCode = statusCode
//     ..write(
//       jsonEncode({
//         'status': status,
//         'message': message,
//         'timestamp': DateTime.now().toIso8601String(),
//         if (successMessages != null && successMessages.isNotEmpty)
//           'successful': successMessages,
//         if (errorMessages != null && errorMessages.isNotEmpty)
//           'errors': errorMessages,
//       }),
//     )
//     ..close();
// }

// void _sendErrorResponse(
//   HttpRequest request,
//   int statusCode,
//   String errorCode,
//   String message, {
//   List<String>? errors,
// }) {
//   request.response
//     ..statusCode = statusCode
//     ..write(
//       jsonEncode({
//         'status': 'ERROR',
//         'error_code': errorCode,
//         'message': message,
//         'timestamp': DateTime.now().toIso8601String(),
//         if (errors != null && errors.isNotEmpty) 'errors': errors,
//       }),
//     )
//     ..close();
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Hive
//   final directory = await getApplicationDocumentsDirectory();
//   Hive.init(directory.path);
//   // Register all Hive adapters
//   Hive.registerAdapter(BusinessInfoModelAdapter());
//   Hive.registerAdapter(UserAdapter());
//   Hive.registerAdapter(BusinessAdapter()); // Register adapters
//   Hive.registerAdapter(PrinterAdapter());

//   // Open boxes
//   // await Hive.openBox<Printer>('printerBoxs');
//   // Open with type
//   await Hive.openBox<BusinessInfoModel>('businessInfo');
//   // await Hive.openBox('printerBox');
//   // await PrinterService.instance.init();
//   // final printServer = PrintServer();
//   // await printServer.start();

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => LoginProvider()),
//         // ChangeNotifierProvider(create: (_) => PrintingAgentProvider()),
//         ChangeNotifierProvider(create: (_) => PrintingAgentProviderMobile()),
//       ],
//       child: const POSAgentApp(
//           // printServer:
//           // printServer
//           ),
//     ),
//   );
// }

// class POSAgentApp extends StatelessWidget {
//   // final PrintServer printServer;

//   const POSAgentApp({
//     super.key,
//     // required this.printServer
//   });
//   static final navigatorKey = GlobalKey<NavigatorState>();
//   static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'POS Agent',
//       debugShowCheckedModeBanner: false,
//       navigatorKey: navigatorKey,
//       scaffoldMessengerKey: scaffoldMessengerKey,
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: Colors.black,
//       ),
//       home: const MainShell(),
//     );
//   }
// }

// class MainShell extends StatefulWidget {
//   const MainShell({super.key});

//   @override
//   State<MainShell> createState() => _MainShellState();
// }

// class _MainShellState extends State<MainShell> {
//   int _currentIndex = 0;
//   bool _serverStarted = false;
//   final _pages = const [
//     POSWebViewScreen(),
//     LoginScreen(),
//   ];
//   @override
//   void initState() {
//     super.initState();
//     // START SERVER WHEN APP LAUNCHES
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_serverStarted) {
//         _serverStarted = true;
//         startLocalServer(context);
//         print("🚀 Local server initialization started");
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: IndexedStack(
//           index: _currentIndex,
//           children: _pages,
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.grey.shade900,
//         selectedItemColor: Colors.blueAccent,
//         unselectedItemColor: Colors.grey,
//         currentIndex: _currentIndex,
//         onTap: (i) => setState(() => _currentIndex = i),
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.storefront),
//             label: 'POS',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.print),
//             label: 'Printing',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class POSWebViewScreen extends StatefulWidget {
//   const POSWebViewScreen({super.key});

//   @override
//   State<POSWebViewScreen> createState() => _POSWebViewScreenState();
// }

// class _POSWebViewScreenState extends State<POSWebViewScreen> {
//   InAppWebViewController? _webViewController;
//   double _progress = 0;
//   bool _serverIpInjected = false;

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_webViewController != null) {
//           final canGoBack = await _webViewController!.canGoBack();
//           if (canGoBack) {
//             _webViewController!.goBack();
//             return false;
//           }
//         }
//         return false;
//       },
//       child: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(
//               url: WebUri(AppConfig.posUrl),
//             ),
//             initialSettings: InAppWebViewSettings(
//               javaScriptEnabled: true,
//               mediaPlaybackRequiresUserGesture: false,
//               supportZoom: false,
//               useOnDownloadStart: true,
//               useShouldOverrideUrlLoading: true,
//               mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//               allowFileAccessFromFileURLs: true,
//               allowUniversalAccessFromFileURLs: true,
//             ),
//             onWebViewCreated: (controller) {
//               _webViewController = controller;
//               print("✅ WebView created");
//             },
//             onLoadStart: (controller, url) {
//               setState(() => _progress = 0);
//               print("✅ WebView created");
//               print('🌐 WebView loading: $url');
//             },
//             onLoadStop: (controller, url) async {
//               setState(() => _progress = 0);
//               print('✅ WebView loaded: $url');
//               print('✅ WebView load done: $url');
//               // ✅ ADD THIS ENTIRE BLOCK - INJECT SERVER IP
//               if (!_serverIpInjected && _serverIp != null) {
//                 try {
//                   await controller.evaluateJavascript(source: '''
//                     window.FLUTTER_SERVER_IP = "$_serverIp";
//                     window.FLUTTER_SERVER_URL = "http://$_serverIp:8085";
//                     window.FLUTTER_LOCAL_SERVER = "http://127.0.0.1:8085";
                    
//                     console.log("✅✅✅ Flutter Server IP Injected:", "$_serverIp");
//                     console.log("✅✅✅ Use this URL:", window.FLUTTER_SERVER_URL);
//                     console.log("✅✅✅ Or localhost:", window.FLUTTER_LOCAL_SERVER);
                    
//                     window.dispatchEvent(new CustomEvent('flutter-server-ready', {
//                       detail: {
//                         serverIp: "$_serverIp",
//                         serverUrl: "http://$_serverIp:8085",
//                         localUrl: "http://127.0.0.1:8085"
//                       }
//                     }));
//                   ''');

//                   _serverIpInjected = true;
//                   print("✅ Server IP injected into WebView: $_serverIp");
//                 } catch (e) {
//                   print("❌ Failed to inject server IP: $e");
//                 }
//               }
//             },
//             onProgressChanged: (controller, progress) {
//               setState(() => _progress = progress / 100);
//             },
//             onReceivedError: (controller, request, error) {
//               print('   URL: ${request.url}');
//               print('❌ WebView error: $error');
//             },
//           ),
//           if (_progress > 0 && _progress < 1)
//             Align(
//               alignment: Alignment.topCenter,
//               child: LinearProgressIndicator(
//                 value: _progress,
//                 backgroundColor: Colors.grey.shade800,
//                 valueColor:
//                     const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
//                 minHeight: 3,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
