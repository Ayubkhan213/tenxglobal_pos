import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'config.dart';
import 'printer_service.dart';

class PrintServer {
  HttpServer? _server;

  Future<void> start() async {
    // Bind to localhost only (loopback)
    _server = await HttpServer.bind(
        InternetAddress.loopbackIPv4, AppConfig.printServerPort);
    print(
        '🖨️  Print agent listening on http://localhost:${AppConfig.printServerPort}');

    _server!.listen(_handleRequest, onError: (e, st) {
      print('❌ Server error: $e\n$st');
    });
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      // --- CORS headers (for Web POS in WebView or browser) ---
      request.response.headers
        ..set('Access-Control-Allow-Origin', '*')
        ..set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        ..set('Access-Control-Allow-Headers', 'Content-Type, X-Requested-With')
        ..set('Access-Control-Max-Age', '86400');
      print('---------------------');
      print(request);
      final path = request.uri.path;
      print(
          '📥 ${request.method} $path from ${request.connectionInfo?.remoteAddress.address}');

      // Preflight
      if (request.method == 'OPTIONS') {
        request.response
          ..statusCode = HttpStatus.noContent
          ..close();
        return;
      }

      if (request.method == 'GET' && path == '/health') {
        _handleHealth(request);
        return;
      }

      if (request.method == 'POST' && path == '/print') {
        await _handlePrint(request);
        return;
      }

      // Not found
      request.response
        ..statusCode = HttpStatus.notFound
        ..write(jsonEncode({'success': false, 'error': 'Not found'}))
        ..close();
    } catch (e, st) {
      print('❌ Fatal request error: $e\n$st');

      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write(
            jsonEncode({'success': false, 'error': 'Internal server error'}));

      await request.response.close();
    }
  }

  void _handleHealth(HttpRequest request) {
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.set('Content-Type', 'application/json')
      ..write(jsonEncode({
        'status': 'ok',
        'platform': 'android',
        'message': 'Print agent running',
      }))
      ..close();
  }

  Future<void> _handlePrint(HttpRequest request) async {
    final bodyString = await utf8.decodeStream(request);
    print('   Raw body: $bodyString');

    Map<String, dynamic> data;
    try {
      data = jsonDecode(bodyString) as Map<String, dynamic>;
    } catch (e) {
      print('❌ JSON decode error: $e');
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write(jsonEncode({'success': false, 'error': 'Invalid JSON'}))
        ..close();
      return;
    }

    final order = data['order'];
    final type = (data['type'] ?? 'customer').toString();

    print('   Print type: $type');

    try {
      if (type == 'kitchen') {
        await PrinterService.instance.printKitchenOrder(order);
      } else {
        await PrinterService.instance.printCustomerReceipt(order);
      }

      request.response
        ..statusCode = HttpStatus.ok
        ..headers.set('Content-Type', 'application/json')
        ..write(jsonEncode({'success': true}));
    } catch (e, st) {
      print('❌ Print error: $e\n$st');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write(jsonEncode({'success': false, 'error': e.toString()}));
    }

    await request.response.close();
  }
}
