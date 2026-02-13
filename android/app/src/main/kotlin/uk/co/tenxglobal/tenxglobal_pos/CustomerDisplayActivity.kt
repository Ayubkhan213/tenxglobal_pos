package uk.co.tenxglobal.tenxglobal_pos

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import org.json.JSONArray
import org.json.JSONObject

class CustomerDisplayActivity : AppCompatActivity() {
    companion object {
        private const val TAG = "CustomerDisplayActivity"
    }

    // UI Elements
    private lateinit var tvOrderType: TextView
    private lateinit var tvCustomer: TextView
    private lateinit var llItemsContainer: LinearLayout
    private lateinit var tvEmptyMessage: TextView
    private lateinit var tvSubtotal: TextView
    private lateinit var tvTax: TextView
    private lateinit var tvService: TextView
    private lateinit var tvDiscount: TextView
    private lateinit var tvTotal: TextView

    // Debug UI Elements
    private lateinit var tvDebugOrders: TextView
    private lateinit var tvDebugItems: TextView
    private lateinit var tvDebugStatus: TextView
    private lateinit var tvDebugCustomer: TextView
    private lateinit var tvDebugTotal: TextView

    private val updateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                "SUNMI_CUSTOMER_DISPLAY_UPDATE" -> {
                    val jsonData = intent.getStringExtra("data")
                    jsonData?.let {
                        try {
                            Log.d(TAG, "📥 Received update via Sunmi broadcast")
                            Log.d(TAG, "Raw JSON: $it")
                            val jsonObject = JSONObject(it)
                            updateUI(jsonObject)
                            Log.d(TAG, "✅ UI updated successfully")
                        } catch (e: Exception) {
                            Log.e(TAG, "❌ Error parsing update: ${e.message}")
                            e.printStackTrace()
                        }
                    }
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        Log.d(TAG, "════════════════════════════════════════")
        Log.d(TAG, "✅ CustomerDisplayActivity CREATED (Native XML)")
        Log.d(TAG, "════════════════════════════════════════")
        
        setContentView(R.layout.customer_display)
        
        // Keep screen on
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        
        // Initialize views
        tvOrderType = findViewById(R.id.tvOrderType)
        tvCustomer = findViewById(R.id.tvCustomer)
        llItemsContainer = findViewById(R.id.llItemsContainer)
        tvEmptyMessage = findViewById(R.id.tvEmptyMessage)
        tvSubtotal = findViewById(R.id.tvSubtotal)
        tvTax = findViewById(R.id.tvTax)
        tvService = findViewById(R.id.tvService)
        tvDiscount = findViewById(R.id.tvDiscount)
        tvTotal = findViewById(R.id.tvTotal)
        
        // Debug views
        tvDebugOrders = findViewById(R.id.tvDebugOrders)
        tvDebugItems = findViewById(R.id.tvDebugItems)
        tvDebugStatus = findViewById(R.id.tvDebugStatus)
        tvDebugCustomer = findViewById(R.id.tvDebugCustomer)
        tvDebugTotal = findViewById(R.id.tvDebugTotal)
        
        // Register broadcast receiver
        val filter = IntentFilter().apply {
            addAction("SUNMI_CUSTOMER_DISPLAY_UPDATE")
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(updateReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(updateReceiver, filter)
        }
        
        // Handle initial data
        val initialData = intent.getSerializableExtra("display_data") as? HashMap<*, *>
        initialData?.let {
            Log.d(TAG, "📦 Processing initial data")
            try {
                val jsonObject = JSONObject(it as Map<*, *>)
                updateUI(jsonObject)
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error processing initial data: $e")
            }
        }
        
        Log.d(TAG, "✅ CustomerDisplayActivity initialized")
    }

    private fun updateUI(data: JSONObject) {
        runOnUiThread {
            try {
                Log.d(TAG, "═══════════════════════════════════════")
                Log.d(TAG, "🎨 UPDATING UI")
                
                // Extract order object
                val orderObj = if (data.has("order")) {
                    data.getJSONObject("order")
                } else {
                    data
                }
                
                // Update customer info
                val customer = orderObj.optString("customer", "Walk-in Customer")
                val orderType = orderObj.optString("orderType", "Takeaway")
                
                tvCustomer.text = customer
                tvOrderType.text = orderType
                
                Log.d(TAG, "👤 Customer: $customer")
                Log.d(TAG, "📦 Order Type: $orderType")
                
                // Update items
                val itemsArray = orderObj.optJSONArray("items")
                if (itemsArray != null && itemsArray.length() > 0) {
                    tvEmptyMessage.visibility = android.view.View.GONE
                    llItemsContainer.removeAllViews()
                    
                    Log.d(TAG, "🛒 Items count: ${itemsArray.length()}")
                    
                    for (i in 0 until itemsArray.length()) {
                        val item = itemsArray.getJSONObject(i)
                        addItemView(item)
                    }
                    
                    // Update debug info
                    tvDebugItems.text = "Items: ${itemsArray.length()}"
                    tvDebugStatus.text = "✅ HAS DATA"
                    tvDebugStatus.setTextColor(android.graphics.Color.parseColor("#00FF88"))
                } else {
                    tvEmptyMessage.visibility = android.view.View.VISIBLE
                    llItemsContainer.removeAllViews()
                    
                    tvDebugItems.text = "Items: 0"
                    tvDebugStatus.text = "❌ NO DATA"
                    tvDebugStatus.setTextColor(android.graphics.Color.parseColor("#FF5555"))
                }
                
                // Update totals
                val subtotal = orderObj.optDouble("subtotal", 0.0)
                val tax = orderObj.optDouble("tax", 0.0)
                val service = orderObj.optDouble("serviceCharges", 0.0)
                val discount = orderObj.optDouble("saleDiscount", 0.0)
                val total = orderObj.optDouble("total", 0.0)
                
                tvSubtotal.text = "£%.2f".format(subtotal)
                tvTax.text = "£%.2f".format(tax)
                tvService.text = "£%.2f".format(service)
                tvDiscount.text = "- £%.2f".format(discount)
                tvTotal.text = "£%.2f".format(total)
                
                // Update debug info
                tvDebugOrders.text = "Orders: 1"
                tvDebugCustomer.text = customer
                tvDebugTotal.text = "£%.2f".format(total)
                
                Log.d(TAG, "💰 Total: £%.2f".format(total))
                Log.d(TAG, "✅ UI update complete")
                Log.d(TAG, "═══════════════════════════════════════")
                
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error updating UI: ${e.message}")
                e.printStackTrace()
            }
        }
    }

    private fun addItemView(item: JSONObject) {
        val itemView = LayoutInflater.from(this).inflate(
            android.R.layout.simple_list_item_2, 
            llItemsContainer, 
            false
        ) as LinearLayout
        
        val text1 = itemView.findViewById<TextView>(android.R.id.text1)
        val text2 = itemView.findViewById<TextView>(android.R.id.text2)
        
        val title = item.optString("title", "Unknown Item")
        val price = item.optDouble("price", 0.0)
        val qty = item.optInt("qty", 1)
        val variantName = item.optString("variantName", "")
        
        text1.text = "$title x$qty"
        text1.textSize = 16f
        text1.setTextColor(android.graphics.Color.BLACK)
        
        var subtitle = "£%.2f".format(price)
        if (variantName.isNotEmpty()) {
            subtitle = "$variantName - $subtitle"
        }
        text2.text = subtitle
        text2.textSize = 14f
        text2.setTextColor(android.graphics.Color.GRAY)
        
        llItemsContainer.addView(itemView)
        
        // Add divider
        val divider = android.view.View(this)
        divider.layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            2
        )
        divider.setBackgroundColor(android.graphics.Color.parseColor("#EEEEEE"))
        llItemsContainer.addView(divider)
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(updateReceiver)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error unregistering receiver: $e")
        }
        Log.d(TAG, "🔴 CustomerDisplayActivity destroyed")
    }
}