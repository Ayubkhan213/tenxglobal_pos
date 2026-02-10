package uk.co.tenxglobal.tenxglobal_pos

import android.content.Context
import android.content.Intent
import android.hardware.display.DisplayManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL = "uk.co.tenxglobal.tenxglobal_pos/customer_display"
    }

    private var isSunmiDevice = false
    private var debugMode = false
    private var customerDisplayActivityStarted = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        Log.d(TAG, "════════════════════════════════════════")
        Log.d(TAG, "🚀 MainActivity onCreate()")
        
        // Check which display this is running on
        val displayId = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            display?.displayId ?: 0
        } else {
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.displayId
        }
        
        Log.d(TAG, "📺 MainActivity running on Display ID: $displayId")
        
        // If somehow MainActivity launched on secondary display, close it
        if (displayId != 0) {
            Log.e(TAG, "❌ MainActivity on wrong display ($displayId), closing...")
            finish()
            return
        }
        
        Log.d(TAG, "✅ MainActivity correctly on PRIMARY display")
        Log.d(TAG, "════════════════════════════════════════")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Detect device type
        isSunmiDevice = Build.MANUFACTURER.equals("SUNMI", ignoreCase = true) &&
                (Build.MODEL.contains("D3", ignoreCase = true) || 
                 Build.MODEL.contains("D3 Pro", ignoreCase = true))
        
        Log.d(TAG, "════════════════════════════════════════")
        Log.d(TAG, "⚙️ Configuring Flutter Engine")
        Log.d(TAG, "📱 Manufacturer: ${Build.MANUFACTURER}")
        Log.d(TAG, "📱 Model: ${Build.MODEL}")
        Log.d(TAG, "🔍 Is Sunmi D3 Pro: $isSunmiDevice")
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
                    Log.d(TAG, "🔧 Debug mode ${if (debugMode) "ENABLED" else "DISABLED"}")
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
        
        // ✅ AUTO-LAUNCH CUSTOMER DISPLAY FROM NATIVE (not from Dart)
        if (isSunmiDevice && !customerDisplayActivityStarted) {
            Log.d(TAG, "🎯 Auto-launching customer display from native...")
            Handler(Looper.getMainLooper()).postDelayed({
                autoLaunchCustomerDisplay()
            }, 2000) // Wait 2 seconds for everything to initialize
        }
    }

    private fun autoLaunchCustomerDisplay() {
        Log.d(TAG, "════════════════════════════════════════")
        Log.d(TAG, "🚀 AUTO-LAUNCH Customer Display")
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val displayManager = getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
                val displays = displayManager.displays
                
                Log.d(TAG, "📺 Scanning displays...")
                Log.d(TAG, "📺 Total displays found: ${displays.size}")
                
                displays.forEachIndexed { index, display ->
                    Log.d(TAG, "  Display $index:")
                    Log.d(TAG, "    - ID: ${display.displayId}")
                    Log.d(TAG, "    - Name: ${display.name}")
                    Log.d(TAG, "    - State: ${display.state}")
                }
                
                // Find display ID 1 (customer display)
                val customerDisplay = displays.firstOrNull { it.displayId == 1 }
                
                if (customerDisplay != null) {
                    Log.d(TAG, "✅ FOUND Customer Display (ID: 1)")
                    Log.d(TAG, "📱 Display Name: ${customerDisplay.name}")
                    
                    // Create intent for CustomerDisplayActivity
                    val intent = Intent(this, CustomerDisplayActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK
                        putExtra("display_data", HashMap<String, Any>(mapOf(
                            "order" to mapOf(
                                "customer" to "Welcome",
                                "phoneNumber" to "",
                                "orderType" to "Takeaway",
                                "total" to 0.0,
                                "subtotal" to 0.0,
                                "tax" to 0.0,
                                "serviceCharges" to 0.0,
                                "deliveryCharges" to 0.0,
                                "saleDiscount" to 0.0,
                                "items" to emptyList<Any>()
                            )
                        )))
                    }
                    
                    // Launch on customer display (ID: 1)
                    val options = android.app.ActivityOptions.makeBasic()
                    options.launchDisplayId = 1
                    
                    startActivity(intent, options.toBundle())
                    customerDisplayActivityStarted = true
                    
                    Log.d(TAG, "✅ Customer display LAUNCHED on Display ID: 1")
                } else {
                    Log.e(TAG, "❌ Customer Display NOT FOUND!")
                    Log.e(TAG, "❌ Only ${displays.size} display(s) detected")
                    Log.e(TAG, "❌ Expected 2 displays for Sunmi D3 Pro")
                }
                
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error auto-launching customer display: ${e.message}")
                e.printStackTrace()
            }
        } else {
            Log.e(TAG, "❌ Android version too old for multi-display (API ${Build.VERSION.SDK_INT})")
        }
        
        Log.d(TAG, "════════════════════════════════════════")
    }

    private fun showCustomerDisplay(data: Map<String, Any>?) {
        if (customerDisplayActivityStarted) {
            // Already running, just update it
            updateCustomerDisplay(data)
            return
        }
        
        Log.d(TAG, "📤 Manual showCustomerDisplay called")
        
        if (isSunmiDevice || debugMode) {
            val intent = Intent(this, CustomerDisplayActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_MULTIPLE_TASK
            data?.let {
                intent.putExtra("display_data", HashMap(it))
            }
            
            if (isSunmiDevice && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                try {
                    val displayManager = getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
                    val displays = displayManager.displays
                    val secondaryDisplay = displays.firstOrNull { it.displayId == 1 }
                    
                    if (secondaryDisplay != null) {
                        val options = android.app.ActivityOptions.makeBasic()
                        options.launchDisplayId = 1
                        startActivity(intent, options.toBundle())
                        customerDisplayActivityStarted = true
                        Log.d(TAG, "✅ Customer display launched manually")
                    } else {
                        Log.e(TAG, "❌ No secondary display found")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Error: ${e.message}")
                }
            } else if (debugMode) {
                startActivity(intent)
                customerDisplayActivityStarted = true
                Log.d(TAG, "✅ Customer display launched (debug mode)")
            }
        }
    }

    private fun hideCustomerDisplay() {
        sendBroadcast(Intent("HIDE_CUSTOMER_DISPLAY"))
        customerDisplayActivityStarted = false
        Log.d(TAG, "📢 Hide broadcast sent")
    }

    private fun updateCustomerDisplay(data: Map<String, Any>?) {
        val intent = Intent("UPDATE_CUSTOMER_DISPLAY")
        data?.let {
            intent.putExtra("display_data", HashMap(it))
        }
        sendBroadcast(intent)
        Log.d(TAG, "📢 Update broadcast sent")
    }
}