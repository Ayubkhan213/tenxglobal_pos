import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenxglobal_pos/core/constants/utils.dart';
import 'package:tenxglobal_pos/core/services/hive_services/business_info_service.dart';
import 'package:tenxglobal_pos/pdf_slip/pdf_slip_preview.dart';
import 'package:tenxglobal_pos/provider/login_provider.dart';

import 'package:tenxglobal_pos/steper/auth_step.dart';
import 'package:tenxglobal_pos/steper/dorop_down.dart';
import 'package:tenxglobal_pos/steper/step_progress_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    // Make it async-safe

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);

      // Check if business info exists in Hive
      final businessInfo = await BusinessInfoBoxService.getBusinessInfo();

      if (businessInfo != null) {
        loginProvider.currentStep = 1;
        loginProvider.isAuthenticated = true;
      } else {
        loginProvider.currentStep = 0;
      }
      loginProvider.notifyListeners(); // Update the UI
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ---------------- MAIN UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1976D2).withOpacity(0.05),
              const Color(0xFF1565C0).withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: SizedBox(
              width: 600.0,
              child: Column(
                children: [
                  Stack(
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF1976D2),
                            child: const Icon(
                              Icons.print,
                              size: 45,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "10xGlobal Printing Agent",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              Text(
                                "Web POS Printing Service",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Logout Button on top-right
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: () async {
                            // Show confirmation dialog
                            bool? confirmLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Confirm Logout"),
                                  content: const Text(
                                      "Are you sure you want to logout?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text("Logout"),
                                    ),
                                  ],
                                );
                              },
                            );

                            // If user confirmed, call logout
                            if (confirmLogout == true) {
                              final authProvider = Provider.of<LoginProvider>(
                                  context,
                                  listen: false);
                              authProvider.logout();

                              // Optionally navigate to login screen
                              // Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Consumer<LoginProvider>(
                    builder: (context, authProvider, _) {
                      return StepProgressRow(
                        currentStep: authProvider.currentStep,
                        authenticated: authProvider.isAuthenticated,
                        connected: authProvider.isConnected,
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  _contentCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI SECTIONS ----------------

  Widget _contentCard() {
    return Consumer<LoginProvider>(
      builder: (context, authProvider, _) {
        return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(
                      alpha: 0.22), // light shadow for dark backgrounds
                  blurRadius: 40,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: authProvider.currentStep == 0
                ? AuthStep(
                    usernameController: authProvider.email,
                    passwordController: authProvider.password,
                    apiKeyController: authProvider.apiKey,
                    loading: authProvider.loading,
                    authenticated: authProvider.isAuthenticated,
                    authError: authProvider.authError,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Select and connect to a printer",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 30),
                      PrinterSelectionWidget(),
                      // SizedBox(height: 10.0),
                      // InkWell(
                      //   onTap: () async {
                      //     // BusinessInfoBoxService.clearBox();
                      //     // ReceiptDialogPreviewer.showReceiptPreview(
                      //     //   context: context,
                      //     //   orderId: '1',
                      //     // );
                      //     await PdfReceiptPrinter.previewReceiptDialog(
                      //       context: context,
                      //       orderResponse: Utils.resApiResponse!,
                      //     );
                      //   },
                      //   child: Container(child: Text('preview')),
                      // ),
                    ],
                  )
            // : _listenStep(),
            );
      },
    );
  }
}
