import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tenxglobal_pos/core/constants/app_constant.dart';
import 'package:tenxglobal_pos/core/constants/app_url.dart';
import 'package:tenxglobal_pos/core/services/api_services/base_api_services.dart';
import 'package:tenxglobal_pos/core/services/api_services/network_api_services.dart';
import 'package:tenxglobal_pos/core/services/hive_services/business_info_service.dart';
import 'package:tenxglobal_pos/main.dart';

import 'package:tenxglobal_pos/models/business_info_model.dart';

class LoginProvider extends ChangeNotifier {
  BaseApiServices apiServices = NetworkApiServices();
  // ------------------ CONTROLLERS ------------------
  final email = TextEditingController();
  final password = TextEditingController();
  final apiKey = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ------------------ STATES ------------------
  int currentStep = 0;
  bool loading = false;
  bool hidePassword = true;
  bool isAuthenticated = false;
  bool isConnected = false;
  bool isListening = false;
  String? authError;
  String listenStatus = "Ready to start";
  int jobCount = 0;

  // ------------------ AUTHENTICATION ------------------
  Future<void> authenticate() async {
    if (!formKey.currentState!.validate()) return;

    loading = true;
    authError = null;
    notifyListeners();

    try {
      var res = await apiServices.getPostApiResponse(
        url: AppUrl.authUrl,
        body: jsonEncode({
          "email": email.text.trim(),
          "password": password.text.trim(),
          "api_key": "http://${AppConstants.ip}:8085/print",
        }),
      );
      print('11111111111111111111111111');
      final businessInfo = BusinessInfoModel.fromJson(res);
      await BusinessInfoBoxService.saveBusinessInfo(businessInfo);
      print('2222222222222222222222222222222222');

      // Safe snackbar using global key
      POSAgentApp.scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Successfully Authenticated'),
          backgroundColor: Colors.green,
        ),
      );

      loading = false;
      isAuthenticated = true;
      currentStep = 1;
      notifyListeners();
    } catch (e) {
      loading = false;
      isAuthenticated = false;
      currentStep = 0;
      notifyListeners();

      POSAgentApp.scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void togglePassword() {
    hidePassword = !hidePassword;
    notifyListeners();
  }

  // ------------------ LISTENER ------------------
  void startListening() {
    isListening = true;
    listenStatus = "Listening for print jobs...";
    notifyListeners();
    _simulateJobs();
  }

  void stopListening() {
    isListening = false;
    listenStatus = "Listener stopped";
    notifyListeners();
  }

  void _simulateJobs() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!isListening) return;

      jobCount++;
      listenStatus = "Job #$jobCount received and printed";
      notifyListeners();

      _simulateJobs();
    });
  }

  // ------------------ PRINTER ------------------
  void completeConnection() {
    isConnected = true;
    currentStep = 2;
    notifyListeners();
  }

  // ------------------ DISPOSE ------------------
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    apiKey.dispose();
    super.dispose();
  }
}
