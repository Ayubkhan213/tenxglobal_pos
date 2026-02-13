package uk.co.tenxglobal.tenxglobal_pos

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity: FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL = "uk.co.tenxglobal.tenxglobal_pos/customer_display"
    }

    private var isSunmiDevice = false
    private var customerDisplayActivityStarted = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        Log.d(TAG, "🚀 MainActivity onCreate()")
        
        isSunmiDevice = Build.MANUFACTURER.equals("SUNMI", ignoreCase = true)
        
        Log.d(TAG, "📱 Manufacturer: ${Build.MANUFACTURER}")
        Log.d(TAG, "📱 Model: ${Build.MODEL}")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateCustomerDisplay" -> {
                    val data = call.argument<Map<String, Any>>("data")
                    updateCustomerDisplay(data)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun updateCustomerDisplay(data: Map<String, Any>?) {
        data?.let {
            try {
                Log.d(TAG, "📤 Updating customer display")
                
                val jsonData = JSONObject(it).toString()
                
                val intent = Intent("SUNMI_CUSTOMER_DISPLAY_UPDATE")
                intent.putExtra("data", jsonData)
                intent.setPackage(packageName)
                sendBroadcast(intent)
                
                Log.d(TAG, "✅ Update broadcast sent")
                
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error updating: ${e.message}")
            }
        }
    }
}