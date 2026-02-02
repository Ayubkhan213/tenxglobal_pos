// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:tenxglobal_pos/core/services/api_services/base_api_services.dart';

// enum ConnectionStatus { idle, loading, success, error }

// class ConnectionProvider extends ChangeNotifier {
//   final BaseApiServices apiServices;

//   ConnectionStatus _status = ConnectionStatus.idle;
//   String _errorMessage = '';
//   bool _isAuthenticated = false;

//   ConnectionStatus get status => _status;
//   String get errorMessage => _errorMessage;
//   bool get isLoading => _status == ConnectionStatus.loading;
//   bool get isAuthenticated => _isAuthenticated;

//   ConnectionProvider({required this.apiServices});

//   Future<void> connect() async {
//     // Check connectivity first
//     final connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult.isEmpty ||
//         connectivityResult.first == ConnectivityResult.none) {
//       _handleError(
//         'No Internet Connection. Please check your WiFi or mobile data.',
//       );
//       return;
//     }

//     _status = ConnectionStatus.loading;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       var ip = await _getLocalIpAddress();
//       String url = 'http://$ip:51234/data';
//       final body = jsonEncode({"url": url});
//       final response = await apiServices.getPostApiResponse(
//         url: AppUrl.configUrl,
//         body: body,
//       );

//       print("Response: $response");
//       _status = ConnectionStatus.success;
//       _isAuthenticated = true;
//       print("User authenticated: $_isAuthenticated"); // Debug log
//       notifyListeners();
//     } on SocketException {
//       _handleError('No Internet Connection');
//     } on FetchDataException catch (e) {
//       _handleError(e.message);
//     } catch (e) {
//       _handleError('Something went wrong. Please try again.');
//     }
//   }
//   /* -------------------- NETWORK HELPERS -------------------- */

//   //===========================================================
//   // GET LOCAL IP - ENSURES CURRENT ACTIVE WIFI ONLY
//   //===========================================================
//   Future<String> _getLocalIpAddress() async {
//     // Method 1: Try network_info_plus (BEST - Gets CURRENT WiFi)
//     try {
//       final info = NetworkInfo();
//       final wifiIP = await info.getWifiIP();
//       if (wifiIP != null && wifiIP.isNotEmpty && wifiIP != "0.0.0.0") {
//         debugPrint("✅ Got current WiFi IP: $wifiIP");
//         return wifiIP;
//       }
//     } catch (e) {
//       debugPrint("⚠️ network_info_plus failed: $e");
//     }

//     // Method 2: Fallback - ONLY if Method 1 fails
//     try {
//       String? fallbackIP;
//       for (var interface in await NetworkInterface.list(
//         type: InternetAddressType.IPv4,
//         includeLinkLocal: false,
//       )) {
//         if (!interface.addresses.isNotEmpty) continue;

//         final interfaceName = interface.name.toLowerCase();
//         final isWifiOrEthernet = interfaceName.contains('wlan') ||
//             interfaceName.contains('en') ||
//             interfaceName.contains('eth') ||
//             interfaceName.contains('wi');

//         if (isWifiOrEthernet) {
//           for (var addr in interface.addresses) {
//             if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
//               final ip = addr.address;
//               // Only accept private network IPs
//               if (ip.startsWith('192.168.') ||
//                   ip.startsWith('10.') ||
//                   (ip.startsWith('172.') &&
//                       int.parse(ip.split('.')[1]) >= 16 &&
//                       int.parse(ip.split('.')[1]) <= 31)) {
//                 // VERIFY this IP is actually reachable
//                 if (await _verifyIpIsActive(ip)) {
//                   debugPrint(
//                     "✅ Verified active WiFi IP from ${interface.name}: $ip",
//                   );
//                   return ip;
//                 } else {
//                   fallbackIP ??= ip;
//                   debugPrint("⚠️ Found IP but not verified: $ip");
//                 }
//               }
//             }
//           }
//         }
//       }

//       if (fallbackIP != null) {
//         debugPrint("⚠️ Using unverified fallback IP: $fallbackIP");
//         return fallbackIP;
//       }
//     } catch (e) {
//       debugPrint("⚠️ NetworkInterface fallback failed: $e");
//     }

//     debugPrint("❌ No active WiFi IP found");
//     return "0.0.0.0";
//   }

//   //===========================================================
//   // VERIFY IP IS ACTIVE (Quick connectivity check)
//   //===========================================================
//   Future<bool> _verifyIpIsActive(String ip) async {
//     try {
//       final parts = ip.split(".");
//       final gateway = "${parts[0]}.${parts[1]}.${parts[2]}.1";

//       final socket = await Socket.connect(
//         gateway,
//         80,
//         timeout: const Duration(milliseconds: 300),
//       );
//       socket.destroy();
//       return true;
//     } catch (_) {
//       try {
//         final socket = await Socket.connect(
//           ip,
//           0,
//           timeout: const Duration(milliseconds: 200),
//         );
//         socket.destroy();
//         return true;
//       } catch (_) {
//         return false;
//       }
//     }
//   }

//   /* -------------------- HTTP SERVER -------------------- */

//   void _handleError(String message) {
//     _status = ConnectionStatus.error;
//     _errorMessage = message;
//     _isAuthenticated = false;
//     notifyListeners();
//   }

//   void reset() {
//     _status = ConnectionStatus.idle;
//     _errorMessage = '';
//     notifyListeners();
//   }

//   void logout() {
//     _isAuthenticated = false;
//     _status = ConnectionStatus.idle;
//     _errorMessage = '';
//     notifyListeners();
//   }
// }
