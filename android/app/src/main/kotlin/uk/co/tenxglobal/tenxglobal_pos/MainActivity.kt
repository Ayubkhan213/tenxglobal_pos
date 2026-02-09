package uk.co.tenxglobal.tenxglobal_pos

import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.hardware.display.DisplayManager
import android.content.Context
import android.os.Bundle 

class MainActivity: FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL = "uk.co.tenxglobal.tenxglobal_pos/customer_display"
    }

    private var isSunmiDevice = false
    private var debugMode = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Detect device type
        isSunmiDevice = Build.MANUFACTURER.equals("SUNMI", ignoreCase = true) &&
                (Build.MODEL.contains("D3", ignoreCase = true) || 
                 Build.MODEL.contains("D3 Pro", ignoreCase = true))
        
        Log.d(TAG, "════════════════════════════════════════")
        Log.d(TAG, "Device Info:")
        Log.d(TAG, "  Manufacturer: ${Build.MANUFACTURER}")
        Log.d(TAG, "  Model: ${Build.MODEL}")
        Log.d(TAG, "  Is Sunmi D3 Pro: $isSunmiDevice")
        Log.d(TAG, "════════════════════════════════════════")
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "showCustomerDisplay" -> {
                    val data = call.argument<Map<String, Any>>("data")
                    showCustomerDisplay(data)
                    result.success(true)
                }
                "hideCustomerDisplay" -> {
                    hideCustomerDisplay()
                    result.success(true)
                }
                "updateCustomerDisplay" -> {
                    val data = call.argument<Map<String, Any>>("data")
                    updateCustomerDisplay(data)
                    result.success(true)
                }
                "enableDebugMode" -> {
                    debugMode = call.argument<Boolean>("enabled") ?: false
                    Log.d(TAG, "Debug mode ${if (debugMode) "ENABLED" else "DISABLED"}")
                    result.success(mapOf(
                        "debugMode" to debugMode,
                        "isSunmiDevice" to isSunmiDevice,
                        "manufacturer" to Build.MANUFACTURER,
                        "model" to Build.MODEL
                    ))
                }
                "getDeviceInfo" -> {
                    result.success(mapOf(
                        "isSunmiDevice" to isSunmiDevice,
                        "manufacturer" to Build.MANUFACTURER,
                        "model" to Build.MODEL,
                        "androidVersion" to Build.VERSION.SDK_INT
                    ))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun showCustomerDisplay(data: Map<String, Any>?) {
        Log.d(TAG, "════════════════════════════════════════")
        Log.d(TAG, "showCustomerDisplay called")
        Log.d(TAG, "  Sunmi Device: $isSunmiDevice")
        Log.d(TAG, "  Debug Mode: $debugMode")
        
        if (isSunmiDevice || debugMode) {
            val intent = Intent(this, CustomerDisplayActivity::class.java)
            data?.let {
                intent.putExtra("display_data", HashMap(it))
            }
            
            // ✅ CRITICAL FIX for Sunmi D3 Pro
            if (isSunmiDevice && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                try {
                    val displayManager = getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
                    val displays = displayManager.displays
                    
                    Log.d(TAG, "📺 Total displays found: ${displays.size}")
                    displays.forEachIndexed { index, display ->
                        Log.d(TAG, "  Display $index: ID=${display.displayId}, Name=${display.name}, State=${display.state}")
                    }
                    
                    // Find secondary display (should be display ID 1 for Sunmi D3 Pro)
                    val secondaryDisplay = displays.firstOrNull { it.displayId == 1 }
                    
                    if (secondaryDisplay != null && displays.size > 1) {
                        Log.d(TAG, "✅ Secondary display found: ${secondaryDisplay.name} (ID: ${secondaryDisplay.displayId})")
                        
                        // Launch activity on secondary display
                        val options = android.app.ActivityOptions.makeBasic()
                        options.launchDisplayId = secondaryDisplay.displayId
                        
                        launchCustomerDisplayWithRetry(intent, options.toBundle())
                        
                        Log.d(TAG, "✅ CustomerDisplayActivity launch initiated on SECONDARY display (ID: ${secondaryDisplay.displayId})")
                    } else {
                        // ⚠️ CRITICAL ERROR LOGGING
                        Log.e(TAG, "═══════════════════════════════════════")
                        Log.e(TAG, "❌ CRITICAL: No secondary display found!")
                        Log.e(TAG, "❌ This device may not support dual screens")
                        Log.e(TAG, "❌ Please check:")
                        Log.e(TAG, "   1. Is this actually a Sunmi D3 Pro?")
                        Log.e(TAG, "   2. Is the customer display physically connected?")
                        Log.e(TAG, "   3. Are display settings enabled in device settings?")
                        Log.e(TAG, "   4. Display count: ${displays.size}")
                        Log.e(TAG, "═══════════════════════════════════════")
                        
                        // Fallback: Launch on primary display
                        startActivity(intent)
                        Log.w(TAG, "⚠️ Launched on PRIMARY display as fallback")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Error launching on secondary display: $e")
                    e.printStackTrace()
                    startActivity(intent)
                }
            } else {
                // For non-Sunmi or debug mode on other devices
                startActivity(intent)
                Log.d(TAG, "✅ Customer display launched normally (non-Sunmi or debug mode)")
            }
        } else {
            Log.d(TAG, "⚠️ Customer display not available (not Sunmi & debug mode off)")
        }
        Log.d(TAG, "════════════════════════════════════════")
    }

    private fun hideCustomerDisplay() {
        sendBroadcast(Intent("HIDE_CUSTOMER_DISPLAY"))
        Log.d(TAG, "Hide customer display broadcast sent")
    }

    private fun updateCustomerDisplay(data: Map<String, Any>?) {
        val intent = Intent("UPDATE_CUSTOMER_DISPLAY")
        data?.let {
            intent.putExtra("display_data", HashMap(it))
        }
        sendBroadcast(intent)
        Log.d(TAG, "Update customer display broadcast sent")
    }

    // ✅ NEW: Retry mechanism for launching customer display
    private fun launchCustomerDisplayWithRetry(intent: Intent, options: Bundle?, maxRetries: Int = 3) {
        var retryCount = 0
        
        fun attemptLaunch() {
            try {
                startActivity(intent, options)
                Log.d(TAG, "✅ Customer display launched successfully on attempt ${retryCount + 1}")
            } catch (e: Exception) {
                retryCount++
                if (retryCount < maxRetries) {
                    Log.w(TAG, "⚠️ Launch attempt $retryCount failed, retrying in 500ms...")
                    Handler(Looper.getMainLooper()).postDelayed({
                        attemptLaunch()
                    }, 500)
                } else {
                    Log.e(TAG, "❌ Failed to launch after $maxRetries attempts: $e")
                    e.printStackTrace()
                    // Final fallback: try normal launch
                    try {
                        startActivity(intent)
                        Log.w(TAG, "⚠️ Fallback to normal launch succeeded")
                    } catch (fallbackError: Exception) {
                        Log.e(TAG, "❌ Even fallback launch failed: $fallbackError")
                    }
                }
            }
        }
        
        attemptLaunch()
    }
}