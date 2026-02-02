// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:tenxglobal_pos/provider/connection_provider.dart';

// class ConnectionScreen extends StatefulWidget {
//   const ConnectionScreen({super.key});

//   @override
//   State<ConnectionScreen> createState() => _ConnectionScreenState();
// }

// class _ConnectionScreenState extends State<ConnectionScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkInitialConnectivity();
//   }

//   Future<void> _checkInitialConnectivity() async {
//     final connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult != ConnectivityResult.none) {
//       // Auto-connect if WiFi/mobile data is available
//       if (mounted) {
//         // Provider.of<ConnectionProvider>(context, listen: false).connect();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         // child: Consumer(
//         //   builder: (context, provider, _) {
//             // Navigate on success
//             // if (provider.status == ConnectionStatus.success) {
//             //   WidgetsBinding.instance.addPostFrameCallback((_) {
//             //     provider.reset();
//             //     Navigator.pushReplacement(
//             //       context,
//             //       MaterialPageRoute(builder: (_) => const CustomerScreen()),
//             //     );
//             //   });
//             // }

//             // return
//           ch  Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     Colors.blue.shade50,
//                     Colors.white,
//                     Colors.blue.shade50,
//                   ],
//                 ),
//               ),
//               child: Center(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(32.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Logo or Icon
//                       Container(
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.blue.withOpacity(0.1),
//                               blurRadius: 20,
//                               spreadRadius: 5,
//                             ),
//                           ],
//                         ),
//                         child: Icon(
//                           provider.status == ConnectionStatus.error
//                               ? Icons.cloud_off_rounded
//                               : Icons.cloud_rounded,
//                           size: 80,
//                           color: provider.status == ConnectionStatus.error
//                               ? Colors.red.shade400
//                               : Colors.blueAccent,
//                         ),
//                       ),

//                       const SizedBox(height: 40),

//                       // Heading
//                       Text(
//                         provider.status == ConnectionStatus.error
//                             ? 'Connection Failed'
//                             : 'Welcome to TenX Global',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey.shade800,
//                           letterSpacing: 0.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),

//                       const SizedBox(height: 16),

//                       // Subtitle
//                       StreamBuilder<List<ConnectivityResult>>(
//                         stream: Connectivity().onConnectivityChanged,
//                         builder: (context, snapshot) {
//                           final isConnected = snapshot.hasData &&
//                               snapshot.data!.isNotEmpty &&
//                               snapshot.data!.first != ConnectivityResult.none;

//                           return Column(
//                             children: [
//                               Text(
//                                 provider.status == ConnectionStatus.error
//                                     ? 'We couldn\'t establish a connection'
//                                     : 'Tap below to connect to your account',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey.shade600,
//                                   height: 1.5,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                               const SizedBox(height: 12),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                     width: 8,
//                                     height: 8,
//                                     decoration: BoxDecoration(
//                                       color: isConnected
//                                           ? Colors.green
//                                           : Colors.red,
//                                       shape: BoxShape.circle,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     isConnected
//                                         ? 'Internet Connected'
//                                         : 'No Internet Connection',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: isConnected
//                                           ? Colors.green
//                                           : Colors.red,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           );
//                         },
//                       ),

//                       const SizedBox(height: 40),

//                       // // Error Message Card
//                       // if (provider.status == ConnectionStatus.error) ...[
//                       //   Container(
//                       //     width: 500.0,
//                       //     padding: const EdgeInsets.all(20),
//                       //     margin: const EdgeInsets.only(bottom: 32),
//                       //     decoration: BoxDecoration(
//                       //       color: Colors.red.shade50,
//                       //       borderRadius: BorderRadius.circular(16),
//                       //       border: Border.all(
//                       //         color: Colors.red.shade200,
//                       //         width: 1,
//                       //       ),
//                       //     ),
//                       //     child: Row(
//                       //       children: [
//                       //         Icon(
//                       //           Icons.info_outline_rounded,
//                       //           color: Colors.red.shade700,
//                       //           size: 24,
//                       //         ),
//                       //         const SizedBox(width: 12),
//                       //         Text(
//                       //           provider.errorMessage,
//                       //           style: TextStyle(
//                       //             fontSize: 14,
//                       //             color: Colors.red.shade700,
//                       //             height: 1.4,
//                       //           ),
//                       //         ),
//                       //       ],
//                       //     ),
//                       //   ),
//                       // ],

//                       // Connect Button
//                       Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           onTap: provider.isLoading ? null : provider.connect,
//                           borderRadius: BorderRadius.circular(16),
//                           child: Container(
//                             width: double.infinity,
//                             constraints: const BoxConstraints(maxWidth: 400),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 48,
//                               vertical: 18,
//                             ),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: provider.isLoading
//                                     ? [
//                                         Colors.grey.shade400,
//                                         Colors.grey.shade400,
//                                       ]
//                                     : [Colors.blueAccent, Colors.blue.shade700],
//                               ),
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: provider.isLoading
//                                   ? []
//                                   : [
//                                       BoxShadow(
//                                         color: Colors.blue.withOpacity(0.3),
//                                         blurRadius: 12,
//                                         offset: const Offset(0, 6),
//                                       ),
//                                     ],
//                             ),
//                             child: provider.isLoading
//                                 ? const Center(
//                                     child: SizedBox(
//                                       height: 24,
//                                       width: 24,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2.5,
//                                       ),
//                                     ),
//                                   )
//                                 : Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         provider.status ==
//                                                 ConnectionStatus.error
//                                             ? Icons.refresh_rounded
//                                             : Icons.link_rounded,
//                                         color: Colors.white,
//                                         size: 22,
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Text(
//                                         provider.status ==
//                                                 ConnectionStatus.error
//                                             ? 'Retry Connection'
//                                             : 'Connect Now',
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 17,
//                                           fontWeight: FontWeight.w600,
//                                           letterSpacing: 0.5,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Help text
//                       if (provider.status != ConnectionStatus.loading)
//                         Text(
//                           'Secure connection powered by TenX',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
