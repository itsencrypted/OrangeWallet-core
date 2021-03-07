package com.pollywallet

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import io.flutter.plugin.platform.PlatformView

internal class WalletConnectView(context: Context, id: Int, creationParams: List<String?>?) : PlatformView {
    private val linearLayout: LinearLayout
    val addressLabel: TextView
    val statusLabel: TextView
    val networkLabel: TextView
    val dappLabel: TextView
    val button: Button
    override fun getView(): LinearLayout {
        return linearLayout
    }

    override fun dispose() {}

    init {
        linearLayout = LinearLayout(context)
        dappLabel = TextView(context)
        statusLabel = TextView(context)
        addressLabel = TextView(context)
        networkLabel = TextView(context)
        button = Button(context)
        initializeView(context, creationParams)
    }
    private fun initializeView(context: Context, creationParams: List<String?>?){
        linearLayout.orientation = LinearLayout.VERTICAL
        linearLayout.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)

        linearLayout.setPadding(50,10,50,10)
        val addressTag = TextView(context)
        addressTag.text = "Address: "
        addressTag.setTypeface(null, Typeface.BOLD);
        addressTag.textSize = 16.0.toFloat()
        addressTag.setTextColor(Color.BLACK)
        val dappTag = TextView(context)
        dappTag.text = "Dapp: "
        dappTag.setTypeface(null, Typeface.BOLD);
        dappTag.textSize = 16.0.toFloat()
        dappTag.setTextColor(Color.BLACK)

        val networkTag = TextView(context)
        networkTag.text = "Network: "
        networkTag.setTypeface(null, Typeface.BOLD);
        networkTag.textSize = 16.0.toFloat()
        networkTag.setTextColor(Color.BLACK)

        val statusTag = TextView(context)
        statusTag.text = "Status:"
        statusTag.setTypeface(null, Typeface.BOLD);
        statusTag.textSize = 16.0.toFloat()
        statusTag.setTextColor(Color.BLACK)

        dappLabel.text = "Unavailable"
        dappLabel.textSize = 16.0.toFloat()
        statusLabel.text = "Not Connected"
        statusLabel.textSize = 16.0.toFloat()
        addressLabel.text = creationParams!![0]
        addressLabel.textSize = 16.0.toFloat()
        if(creationParams[3]!!.toInt() == 80001){
            networkLabel.text = "Matic Mumbai Testnet"
        } else{
            networkLabel.text = "Matic Mainnet"
        }
        networkLabel.textSize = 16.0.toFloat()

        button.text = "Disconnect"
        button.width = ViewGroup.LayoutParams.MATCH_PARENT
        button.height = ViewGroup.LayoutParams.WRAP_CONTENT
        button.setBackgroundColor(0xFF8248E5.toInt());
        button.setOnClickListener {

        }

        button.setTextColor(Color.WHITE)
        linearLayout.addView(addressTag)
        linearLayout.addView(addressLabel)
        linearLayout.addView(TextView(context))
        linearLayout.addView(dappTag)
        linearLayout.addView(dappLabel)
        linearLayout.addView(TextView(context))
        linearLayout.addView(networkTag)
        linearLayout.addView(networkLabel)
        linearLayout.addView(TextView(context))
        linearLayout.addView(statusTag)
        linearLayout.addView(statusLabel)
        linearLayout.addView(TextView(context))
        linearLayout.addView(button)
    }
}