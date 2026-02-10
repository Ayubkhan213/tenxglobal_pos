package uk.co.tenxglobal.tenxglobal_pos

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class CustomerDisplayActivity : FlutterActivity() {
    companion object {
        private const val TAG = "CustomerDisplayActivity"
        private const val CHANNEL = "uk.co.tenxglobal.tenxglobal_pos/customer_display_receiver"
    }

    private var methodChannel: MethodChannel? = null

    private val updateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                "UPDATE_CUSTOMER_DISPLAY" -> {
                    val data = intent.getSerializableExtra("display_data") as? HashMap<*, *>
                    data?.let {
                        Log.d(TAG, "📥 Received UPDATE_CUSTOMER_DISPLAY broadcast")
                        methodChannel?.invokeMethod("updateCustomerDisplay", mapOf("data" to it))
                    }
                }
                "HIDE_CUSTOMER_DISPLAY" -> {
                    Log.d(TAG, "📥 Received HIDE_CUSTOMER_DISPLAY broadcast")
                    finish()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Log display information
        val displayId = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            display?.displayId ?: -1
        } else {
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.displayId
        }
        
        Log.d(TAG, "════════════════════════════════════════")
        Log.d(TAG, "✅ CustomerDisplayActivity CREATED")
        Log.d(TAG, "📺 Running on Display ID: $displayId")
        Log.d(TAG, "🏭 Manufacturer: ${Build.MANUFACTURER}")
        Log.d(TAG, "📱 Model: ${Build.MODEL}")
        
        if (displayId == 0) {
            Log.e(TAG, "❌❌❌ CRITICAL ERROR: Activity is on PRIMARY display (ID: 0)")
            Log.e(TAG, "❌❌❌ This should be on SECONDARY display (ID: 1)")
            Log.e(TAG, "❌❌❌ CLOSING THIS ACTIVITY TO PREVENT CONFLICT")
            
            // ✅ Close this activity immediately if on wrong display
            finish()
            return
        } else if (displayId == 1) {
            Log.d(TAG, "✅✅✅ CORRECT: Activity is on SECONDARY display (ID: 1)")
        }
        Log.d(TAG, "════════════════════════════════════════")
        
        // Keep screen on
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        
        // Register broadcast receiver
        val filter = IntentFilter().apply {
            addAction("UPDATE_CUSTOMER_DISPLAY")
            addAction("HIDE_CUSTOMER_DISPLAY")
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(updateReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(updateReceiver, filter)
        }
        
        // Send health check back to MainActivity
        Handler(Looper.getMainLooper()).postDelayed({
            sendBroadcast(Intent("CUSTOMER_DISPLAY_READY").apply {
                putExtra("displayId", displayId)
            })
            Log.d(TAG, "📡 Health check broadcast sent (Display ID: $displayId)")
        }, 1000)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d(TAG, "⚙️ Configuring Flutter engine for customer display")
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        // Send initial data after short delay to ensure Flutter is ready
        val initialData = intent.getSerializableExtra("display_data") as? HashMap<*, *>
        initialData?.let { data ->
            Log.d(TAG, "📦 Initial data received: ${data.keys}")
            
            Handler(Looper.getMainLooper()).postDelayed({
                try {
                    Log.d(TAG, "📤 Sending initial data to Flutter UI")
                    methodChannel?.invokeMethod("showCustomerDisplay", mapOf("data" to data))
                    Log.d(TAG, "✅ Initial data sent successfully")
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Error sending initial data: $e")
                    e.printStackTrace()
                }
            }, 500)
        } ?: run {
            Log.w(TAG, "⚠️ No initial data found in intent - showing empty display")
        }
    }

    override fun getDartEntrypointFunctionName(): String {
        return "customerDisplayMain"
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(updateReceiver)
            Log.d(TAG, "✅ Broadcast receiver unregistered")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error unregistering receiver: $e")
        }
        Log.d(TAG, "🔴 CustomerDisplayActivity destroyed")
    }

    override fun onResume() {
        super.onResume()
        Log.d(TAG, "▶️ CustomerDisplayActivity resumed")
    }

    override fun onPause() {
        super.onPause()
        Log.d(TAG, "⏸️ CustomerDisplayActivity paused")
    }
}