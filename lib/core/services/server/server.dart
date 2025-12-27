import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenxglobal_pos/core/services/dreawer_services/drawer_services.dart';
import 'package:tenxglobal_pos/models/order_response_model.dart';
import 'package:tenxglobal_pos/provider/printing_agant_provider.dart';
import 'package:tenxglobal_pos/recept_printing.dart';

class ServerServices {
  static void startLocalServer(BuildContext context) async {
    try {
      final server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        8085,
        shared: true,
      );

      server.autoCompress = true;

      await for (HttpRequest request in server) {
        print('--------------------');
        print('${request.method} ${request.uri}');

        // =========================
        // CORS HEADERS (MUST BE FIRST)
        // =========================
        final origin = request.headers.value('origin');

        if (origin != null) {
          request.response.headers
            ..set('Access-Control-Allow-Origin', origin)
            ..set('Access-Control-Allow-Credentials', 'true');
        }

        request.response.headers
          ..set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
          ..set(
            'Access-Control-Allow-Headers',
            'Origin, Content-Type, Accept, Authorization, X-Requested-With, X-CSRF-Token',
          )
          ..set('Content-Type', 'application/json');
        //      ..set('Access-Control-Max-Age', '86400');

        // =========================
        // OPTIONS (CRITICAL)
        // =========================
        if (request.method == 'OPTIONS') {
          request.response.statusCode = HttpStatus.noContent; // 204
          await request.response.close();
          continue;
        }

        final provider = Provider.of<PrintingAgentProviderMobile>(
          context,
          listen: false,
        );

        // =========================
        // PRINT ENDPOINT
        // =========================
        if (request.method == 'POST' && request.uri.path == '/print') {
          try {
            final body = await utf8.decoder.bind(request).join();
            final data = jsonDecode(body);
            final res = OrderResponse.fromJson(data);
            print(
                ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   its full response  >>>>>>>>>>>>>>>>> ${data}");
            print(
                ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   its full orders  >>>>>>>>>>>>>>>>> ${res.order}");
            if (res.order == null) {
              _jsonResponse(request, {
                'status': 'ERROR',
                'error_code': 'VALIDATION_ERROR',
                'message': 'Missing required field: order_id',
              });
              continue;
            }

            List<String> successMessages = [];
            List<String> errorMessages = [];
            bool anyPrintSuccess = false;

            print('-----------Print------------ ');
            print(res.print);
            // =========================
            // CASH DRAWER (UNCHANGED)
            // =========================
            print("res.order?.paymentType  ${res.order?.paymentMethod}");
            print("customerPrinter!.url ${provider.customerPrinter!.url}");
            print("res.type ${res.type}");
            // if (res.type == 'customer') {
            //   final ip = provider.customerPrinter!.url.split(':').first;

            //   print("the ip is >>>>>>>>>>>>>>>>>>>>>  ${ip}");
            //   await CashDrawerService.open(ip: ip);
            // }
            if (res.type == 'customer') {
              final printerUrl = provider.customerPrinter!.url;

              // Check if it's a LAN printer (has IP:port format)
              if (printerUrl.startsWith('usb')) {
                print("Opening drawer via USB: $printerUrl");
                await CashDrawerService.open(
                  ip: null,
                  usbPrinterName: printerUrl,
                );
              }
              // USB printer (just printer name)
              else {
                final ip = printerUrl.split(':').first;
                print("Opening drawer via LAN IP: $ip");
                await CashDrawerService.open(ip: ip);
              }
            }
            // =========================
            // CUSTOMER RECEIPT
            // =========================
            if (res.type == 'customer' && res.print == 'yes') {
              try {
                await ReceiptPrinterMobile.printReceipt(
                  context: context,
                  orderResponse: res,
                );
                successMessages.add('Customer receipt printed successfully');
                anyPrintSuccess = true;
              } catch (e) {
                errorMessages.add(e.toString());
              }
            }

            // =========================
            // KOT RECEIPT
            // =========================
            if (res.type == 'KOT') {
              print("Kot priting Yes>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
              try {
                await ReceiptPrinterMobile.printKOT(
                  context: context,
                  orderResponse: res,
                );
                successMessages.add('KOT printed successfully');
                anyPrintSuccess = true;
              } catch (e) {
                errorMessages.add(e.toString());
              }
            }

            // =========================
            // RESPONSE (ORB SAFE)
            // =========================
            _jsonResponse(request, {
              'status': anyPrintSuccess ? 'SUCCESS' : 'ERROR',
              'message': anyPrintSuccess ? 'Print completed' : 'Print failed',
              'success': successMessages,
              'errors': errorMessages,
              'timestamp': DateTime.now().toIso8601String(),
            });
          } catch (e, stack) {
            print('❌ Server error: $e');
            print(stack);

            _jsonResponse(request, {
              'status': 'ERROR',
              'error_code': 'SERVER_ERROR',
              'message': e.toString(),
            });
          }

          continue;
        }

        // =========================
        // STATUS ENDPOINT
        // =========================
        if (request.method == 'GET' && request.uri.path == '/status') {
          _jsonResponse(request, {
            'status': 'online',
            'timestamp': DateTime.now().toIso8601String(),
            'printers': {
              'customer': provider.customerPrinter != null
                  ? {
                      'name': provider.customerPrinter!.name,
                      'connected': provider.availablePrinters.any(
                        (p) => p.url == provider.customerPrinter!.url,
                      ),
                    }
                  : null,
              'kot': provider.kotPrinter != null
                  ? {
                      'name': provider.kotPrinter!.name,
                      'connected': provider.availablePrinters.any(
                        (p) => p.url == provider.kotPrinter!.url,
                      ),
                    }
                  : null,
            },
            'available_printers_count': provider.availablePrinters.length,
          });
          continue;
        }

        // =========================
        // NOT FOUND
        // =========================
        _jsonResponse(request, {
          'status': 'ERROR',
          'error_code': 'NOT_FOUND',
          'message': 'Endpoint not found',
        });
      }
    } catch (e, stackTrace) {
      print('❌ Failed to start server: $e');
      print(stackTrace);
    }
  }

  static void _jsonResponse(
    HttpRequest request,
    Map<String, dynamic> body,
  ) {
    request.response.headers.set(
      HttpHeaders.contentTypeHeader,
      ContentType.json.mimeType,
    );
    request.response.statusCode = HttpStatus.ok; // ORB SAFE
    request.response.write(jsonEncode(body));
    request.response.close();
  }

// ========================================
// RESPONSE HELPER FUNCTIONS
// ========================================

  static void _sendSuccessResponse(
    HttpRequest request,
    int statusCode,
    String status,
    String message, {
    List<String>? successMessages,
  }) {
    request.response
      ..statusCode = statusCode
      ..write(
        jsonEncode({
          'status': status,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
          if (successMessages != null && successMessages.isNotEmpty)
            'details': successMessages,
        }),
      )
      ..close();
  }

  static void _sendPartialSuccessResponse(
    HttpRequest request,
    int statusCode,
    String status,
    String message, {
    List<String>? successMessages,
    List<String>? errorMessages,
  }) {
    request.response
      ..statusCode = statusCode
      ..write(
        jsonEncode({
          'status': status,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
          if (successMessages != null && successMessages.isNotEmpty)
            'successful': successMessages,
          if (errorMessages != null && errorMessages.isNotEmpty)
            'errors': errorMessages,
        }),
      )
      ..close();
  }

  static void _sendErrorResponse(
    HttpRequest request,
    int statusCode,
    String errorCode,
    String message, {
    List<String>? errors,
  }) {
    request.response
      ..statusCode = statusCode
      ..write(
        jsonEncode({
          'status': 'ERROR',
          'error_code': errorCode,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
          if (errors != null && errors.isNotEmpty) 'errors': errors,
        }),
      )
      ..close();
  }
}
