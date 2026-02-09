import 'dart:io';
import 'package:flutter/services.dart';

class DeviceUtils {
  static const MethodChannel _channel =
      MethodChannel('uk.co.tenxglobal.tenxglobal_pos/customer_display');

  static bool _initialized = false;
  static bool _isSunmiDevice = false;
  static bool _debugMode = false;
  static String _manufacturer = '';
  static String _model = '';

  /// Initialize device detection
  static Future<void> initialize({bool enableDebugMode = false}) async {
    if (_initialized) return;

    try {
      // Get device info from native side
      final Map<dynamic, dynamic>? deviceInfo =
          await _channel.invokeMethod('getDeviceInfo');

      if (deviceInfo != null) {
        _isSunmiDevice = deviceInfo['isSunmiDevice'] ?? false;
        _manufacturer = deviceInfo['manufacturer'] ?? '';
        _model = deviceInfo['model'] ?? '';
      }

      // Enable debug mode if requested
      if (enableDebugMode) {
        await enableDebug(true);
      }

      _initialized = true;

      print('════════════════════════════════════════');
      print('DeviceUtils Initialized');
      print('  Manufacturer: $_manufacturer');
      print('  Model: $_model');
      print('  Is Sunmi: $_isSunmiDevice');
      print('  Debug Mode: $_debugMode');
      print('════════════════════════════════════════');
    } catch (e) {
      print('❌ Error initializing DeviceUtils: $e');
      _initialized = true; // Mark as initialized even on error
    }
  }

  /// Enable or disable debug mode
  static Future<void> enableDebug(bool enabled) async {
    try {
      final result = await _channel.invokeMethod('enableDebugMode', {
        'enabled': enabled,
      });

      if (result != null && result is Map) {
        _debugMode = result['debugMode'] ?? false;
        print('✅ Debug mode ${_debugMode ? 'ENABLED' : 'DISABLED'}');
      }
    } catch (e) {
      print('❌ Error enabling debug mode: $e');
    }
  }

  /// Check if device is Sunmi
  static bool get isSunmiDevice => _isSunmiDevice;

  /// Check if customer display should be used
  /// Returns true if Sunmi OR debug mode is enabled
  static bool get shouldUseCustomerDisplay => _isSunmiDevice || _debugMode;

  /// Check if customer display should auto-show (only for real Sunmi devices)
  static bool get shouldAutoShowCustomerDisplay => _isSunmiDevice;

  /// Get device manufacturer
  static String get manufacturer => _manufacturer;

  /// Get device model
  static String get model => _model;

  /// Check if debug mode is enabled
  static bool get isDebugMode => _debugMode;

  /// Get full device info string
  static String get deviceInfo => '$_manufacturer $_model';
}
