package com.orange.wallet

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Looper
import android.view.Gravity
import android.view.ViewGroup
import android.widget.*
import androidx.cardview.widget.CardView
import com.google.android.flexbox.*
import io.flutter.Log
import io.flutter.plugin.platform.PlatformView
import java.math.BigInteger
import kotlin.random.Random
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Dispatchers.Main
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import org.komputing.khex.extensions.toHexString
import org.walletconnect.Session
import org.walletconnect.nullOnThrow
import org.web3j.crypto.Credentials
import org.web3j.crypto.RawTransaction
import org.web3j.crypto.Sign
import org.web3j.protocol.Web3j
import org.web3j.protocol.core.DefaultBlockParameterName
import org.web3j.protocol.core.methods.response.EthGetTransactionCount
import org.web3j.protocol.core.methods.response.EthSendTransaction
import org.web3j.protocol.http.HttpService
import org.web3j.tx.RawTransactionManager
import org.web3j.tx.gas.DefaultGasProvider

internal class WalletConnectView(context: Context, id: Int, creationParams: List<String?>) :
        PlatformView, Session.Callback {
    private val address: String? = creationParams[0]
    private val uri: String? = creationParams[2]
    private val privateKey: String? = creationParams[1]
    private val chainId: String? = creationParams[3]
    private val linearLayout = LinearLayout(context)
    private val dappLabel = TextView(context)
    private val statusLabel = TextView(context)
    private val addressLabel = TextView(context)
    private val networkLabel = TextView(context)
    private val tg = TextView(context)
    private val button = Button(context)
    private var connectionState = 0 // 0 = connecting 1 = connected 2 = disconnected
    private val requestsTag = TextView(context)
    private val scrollView = ScrollView(context)
    private val requestsLinearLayout = LinearLayout(context)
    private val walletConnectUtils = WalletConnectUtils(address!!, uri!!, "42", context)
    private var context = context
    var rpc: String? = null

    private var txRequest: Long? = null
    override fun getView(): LinearLayout {
        return linearLayout
    }

    override fun dispose() {
        walletConnectUtils.disconnectSession()
        Thread.sleep(500)
    }

    init {

        walletConnectUtils.approveSession()
        initialSetup(context)
        initializeView(context, creationParams)
    }

    override fun onMethodCall(call: Session.MethodCall) {
        Log.e("Sign", call.toString())

        when (call) {
            is Session.MethodCall.SendTransaction -> {
                Log.e("Thread", (Looper.myLooper() == Looper.getMainLooper()).toString())
                GlobalScope.launch(Main) {
                    try {
                        sendTransactionConfirm(call, context)
                    } catch (t: Throwable) {
                        // fail?.invoke(t)
                    }
                }
            }
            is Session.MethodCall.SignMessage -> {

                GlobalScope.launch(Main) {
                    try {
                        signMessage(call, context)
                    } catch (t: Throwable) {
                        // fail?.invoke(t)
                    }
                }
            }
            is Session.MethodCall.Custom -> {
                if (call.method == "personal_sign") {
                    GlobalScope.launch(Main) {
                        try {
                            personalSign(call, context)
                        } catch (t: Throwable) {
                            // fail?.invoke(t)
                        }
                    }
                } else {
                    walletConnectUtils!!.session.rejectRequest(
                            call.id(), 1, "Method not Implemented")
                }
            }
            is Session.MethodCall.SessionRequest -> {
                walletConnectUtils.session.approve(listOf(address!!), 42.toLong())
            }
            else -> {
                walletConnectUtils!!.session.rejectRequest(call.id(), 1, "Method not Implemented")
            }
        }
    }

    override fun onStatus(status: Session.Status) {
        when (status) {
            Session.Status.Approved -> sessionApproved()
            Session.Status.Closed -> sessionClosed()
            Session.Status.Connected, Session.Status.Disconnected, is Session.Status.Error -> {
                Log.e("error", status.toString())
            }
        }
    }
    private fun sessionApproved() {
        dappLabel.text = walletConnectUtils.session.peerMeta()!!.name
        statusLabel.text = "Connected"
        connectionState = 1
    }
    private fun sessionClosed() {}
    private fun initialSetup(context: Context) {
        rpc =
                if (chainId == "137") {
                    "https://rpc-mainnet.matic.network"
                } else {
                    "https://rpc-mumbai.matic.today"
                }
        rpc = "https://kovan.infura.io/v3/0e4ce57afbd04131b6842f08265b4d4b"
        this.context = context
        val session = nullOnThrow { walletConnectUtils!!.session } ?: return
        session.addCallback(this)
    }
    private fun handleResponse(resp: Session.MethodCall.Response) {}

    @SuppressLint("SetTextI18n")
    private fun initializeView(context: Context, creationParams: List<String?>?) {
        linearLayout.orientation = LinearLayout.VERTICAL
        linearLayout.layoutParams =
                ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        requestsLinearLayout.orientation = LinearLayout.VERTICAL
        requestsLinearLayout.layoutParams =
                ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        requestsLinearLayout.setPadding(25, 50, 25, 50)
        scrollView.layoutParams =
                ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        linearLayout.setPadding(50, 10, 50, 10)
        val addressTag = TextView(context)
        addressTag.text = "Address: "
        addressTag.setTypeface(null, Typeface.BOLD)
        addressTag.textSize = 16.0.toFloat()
        addressTag.setTextColor(Color.BLACK)
        val dappTag = TextView(context)
        dappTag.text = "Dapp: "
        dappTag.setTypeface(null, Typeface.BOLD)
        dappTag.textSize = 16.0.toFloat()
        dappTag.setTextColor(Color.BLACK)

        val networkTag = TextView(context)
        networkTag.text = "Network: "
        networkTag.setTypeface(null, Typeface.BOLD)
        networkTag.textSize = 16.0.toFloat()
        networkTag.setTextColor(Color.BLACK)

        val statusTag = TextView(context)
        statusTag.text = "Status:"
        statusTag.setTypeface(null, Typeface.BOLD)
        statusTag.textSize = 16.0.toFloat()
        statusTag.setTextColor(Color.BLACK)

        requestsTag.text = "Your Requests will appear here"
        requestsTag.setTypeface(null, Typeface.BOLD)
        requestsTag.textSize = 16.0.toFloat()
        requestsTag.setTextColor(Color.BLACK)
        requestsTag.gravity = Gravity.CENTER_HORIZONTAL

        dappLabel.text = "Connecting, please wait...."
        dappLabel.textSize = 16.0.toFloat()
        statusLabel.text = "Not Connected"
        statusLabel.textSize = 16.0.toFloat()
        addressLabel.text = creationParams!![0]
        addressLabel.textSize = 16.0.toFloat()
        if (creationParams[3]!!.toInt() == 80001) {
            networkLabel.text = "Matic Mumbai Testnet"
        } else {
            networkLabel.text = "Matic Mainnet"
        }
        networkLabel.textSize = 16.0.toFloat()
        val shape = GradientDrawable()
        shape.cornerRadius = 25.toFloat()
        shape.setColor(Color.parseColor("#FF8248E5"))
        button.text = "Disconnect"
        button.width = ViewGroup.LayoutParams.MATCH_PARENT
        button.height = ViewGroup.LayoutParams.WRAP_CONTENT
        button.background = shape
        // button.setBackgroundColor(0xFF8248E5.toInt());
        button.setOnClickListener {
            when (connectionState) {
                1 -> {
                    button.text = "Connect"
                    walletConnectUtils!!.disconnectSession()
                    statusLabel.text = "Disconnected"
                    connectionState = 2
                }
                2 -> {
                    button.text = "Disconnect"
                    walletConnectUtils!!.session.approve(listOf(creationParams[0]!!), 42.toLong())
                    connectionState = 1
                }
                else -> {
                    Toast.makeText(this.context, "Please Wait", Toast.LENGTH_SHORT).show()
                }
            }
        }
        statusLabel.text = "Connecting........"
        button.text = "Disconnect"
        requestsLinearLayout.orientation = LinearLayout.VERTICAL
        scrollView.isFillViewport = true
        scrollView.isScrollContainer = true
        scrollView.addView(requestsLinearLayout)
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
        linearLayout.addView(TextView(context))
        linearLayout.addView(requestsTag)
        linearLayout.addView(scrollView)
    }
    @SuppressLint("SetTextI18n")
    private fun sendTransactionConfirm(call: Session.MethodCall, context: Context) {
        call as Session.MethodCall.SendTransaction
        var i = Random(123).nextInt()
        var j = Random(133).nextInt()
        Log.e("Transaction", "In SendTransaction")
        requestsTag.text = "Requests"
        val card = CardView(context)
        card.elevation = 0.toFloat()
        card.setCardBackgroundColor(Color.parseColor("#E8E6E1"))
        card.radius = 50.toFloat()
        val request = LinearLayout(context)
        request.gravity = Gravity.CENTER
        request.orientation = LinearLayout.VERTICAL
        request.layoutParams =
                ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        val tag = TextView(context)
        tag.setTypeface(null, Typeface.BOLD)
        tag.text = "Transaction Request "

        tag.gravity = Gravity.CENTER_HORIZONTAL
        tag.setTypeface(null, Typeface.BOLD)
        tag.textSize = 16.0.toFloat()
        tag.setTextColor(Color.BLACK)
        request.addView(tag)
        val data = TextView(context)

        data.gravity = Gravity.CENTER_HORIZONTAL
        data.text =
                "\"From: ${call.from}\n" +
                        "                \"To: ${call.to}\n" +
                        "                \"Value: ${call.value}\n" +
                        "                \"Data: ${call.data}"
        data.textSize = 16.0.toFloat()
        request.addView(TextView(context))
        request.addView(data)
        val shape1 = GradientDrawable()
        shape1.cornerRadius = 25.toFloat()
        shape1.setColor(Color.parseColor("#FFD287FD"))
        val shape2 = GradientDrawable()
        shape2.cornerRadius = 25.toFloat()
        shape2.setColor(Color.parseColor("#FFEABC78"))
        val params: LinearLayout.LayoutParams =
                LinearLayout.LayoutParams(
                        ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT)
        params.weight = 1.0f
        val approve = Button(context)
        approve.layoutParams = params
        approve.text = "Approve"
        approve.width = ViewGroup.LayoutParams.WRAP_CONTENT
        approve.height = ViewGroup.LayoutParams.WRAP_CONTENT
        approve.background = shape1
        val reject = Button(context)
        reject.layoutParams = params
        reject.text = "Reject"
        reject.width = ViewGroup.LayoutParams.WRAP_CONTENT
        reject.height = ViewGroup.LayoutParams.WRAP_CONTENT
        reject.background = shape2
        val flexBox = FlexboxLayout(context)
        val flexboxLp: FlexboxLayout.LayoutParams =
                FlexboxLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        flexboxLp.flexGrow = 1.0f
        flexboxLp.alignSelf = AlignItems.CENTER
        flexBox.layoutParams = flexboxLp
        flexBox.flexDirection = FlexDirection.ROW
        flexBox.justifyContent = JustifyContent.SPACE_EVENLY
        flexBox.alignContent = AlignContent.CENTER
        flexBox.addView(reject)
        flexBox.addView(approve)
        request.addView(TextView(context))
        request.addView(flexBox)
        request.setPadding(10, 50, 10, 50)
        card.addView(request)
        requestsLinearLayout.addView(card)

        card.tag = i
        val pad = TextView(context)
        pad.tag = j
        requestsLinearLayout.addView(pad)
        requestsTag.text = "Requests"
        approve.setOnClickListener {
            val web3 = Web3j.build(HttpService(rpc))
            var credentials = Credentials.create(privateKey)
            val transactionManager = RawTransactionManager(web3, credentials, 42.toLong())
            val ethGetTransactionCount: EthGetTransactionCount =
                    web3.ethGetTransactionCount(address, DefaultBlockParameterName.LATEST)
                            .sendAsync()
                            .get()
            val nonce: BigInteger = ethGetTransactionCount.transactionCount
            var rawTransaction =
                    RawTransaction.createTransaction(
                            nonce,
                            DefaultGasProvider.GAS_PRICE,
                            DefaultGasProvider.GAS_LIMIT,
                            call.to,
                            BigInteger.valueOf(call.value.substring(2).toLong(16)),
                            call.data)
            CoroutineScope(Dispatchers.IO).launch {
                var resp: EthSendTransaction = transactionManager.signAndSend(rawTransaction)
                walletConnectUtils!!.session.approveRequest(call.id, resp.transactionHash)
            }

            var v1 = requestsLinearLayout.findViewWithTag<CardView>(i)
            var v2 = requestsLinearLayout.findViewWithTag<TextView>(j)
            requestsLinearLayout.removeView(v1)
            requestsLinearLayout.removeView(v2)
        }
        reject.setOnClickListener {
            walletConnectUtils!!.session.rejectRequest(call.id, 1, "Transaction Rejected")
            var v1 = requestsLinearLayout.findViewWithTag<CardView>(i)
            var v2 = requestsLinearLayout.findViewWithTag<TextView>(j)
            requestsLinearLayout.removeView(v1)
            requestsLinearLayout.removeView(v2)
        }
    }
    private fun signMessage(call: Session.MethodCall, context: Context) {

        call as Session.MethodCall.SignMessage
        var i = Random(123).nextInt()
        var j = Random(133).nextInt()
        Log.e("Transaction", "In SendTransaction")
        requestsTag.text = "Requests"
        val card = CardView(context)
        card.elevation = 0.toFloat()
        card.setCardBackgroundColor(Color.parseColor("#E8E6E1"))
        card.radius = 50.toFloat()
        val request = LinearLayout(context)
        request.gravity = Gravity.CENTER
        request.orientation = LinearLayout.VERTICAL
        request.layoutParams =
                ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        val tag = TextView(context)
        tag.setTypeface(null, Typeface.BOLD)
        tag.text = "Transaction Request "

        tag.gravity = Gravity.CENTER_HORIZONTAL
        tag.setTypeface(null, Typeface.BOLD)
        tag.textSize = 16.0.toFloat()
        tag.setTextColor(Color.BLACK)
        request.addView(tag)
        val data = TextView(context)

        data.gravity = Gravity.CENTER_HORIZONTAL
        data.text = "${walletConnectUtils!!.session.peerMeta()!!.name} has Requested your signature"
        data.textSize = 16.0.toFloat()
        request.addView(TextView(context))
        request.addView(data)
        val shape1 = GradientDrawable()
        shape1.cornerRadius = 25.toFloat()
        shape1.setColor(Color.parseColor("#FFD287FD"))
        val shape2 = GradientDrawable()
        shape2.cornerRadius = 25.toFloat()
        shape2.setColor(Color.parseColor("#FFEABC78"))
        val params: LinearLayout.LayoutParams =
                LinearLayout.LayoutParams(
                        ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT)
        params.weight = 1.0f
        val approve = Button(context)
        approve.layoutParams = params
        approve.text = "Approve"
        approve.width = ViewGroup.LayoutParams.WRAP_CONTENT
        approve.height = ViewGroup.LayoutParams.WRAP_CONTENT
        approve.background = shape1
        val reject = Button(context)
        reject.layoutParams = params
        reject.text = "Reject"
        reject.width = ViewGroup.LayoutParams.WRAP_CONTENT
        reject.height = ViewGroup.LayoutParams.WRAP_CONTENT
        reject.background = shape2
        val flexBox = FlexboxLayout(context)
        val flexboxLp: FlexboxLayout.LayoutParams =
                FlexboxLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        flexboxLp.flexGrow = 1.0f
        flexboxLp.alignSelf = AlignItems.CENTER
        flexBox.layoutParams = flexboxLp
        flexBox.flexDirection = FlexDirection.ROW
        flexBox.justifyContent = JustifyContent.SPACE_EVENLY
        flexBox.alignContent = AlignContent.CENTER
        flexBox.addView(reject)
        flexBox.addView(approve)
        request.addView(TextView(context))
        request.addView(flexBox)
        request.setPadding(10, 50, 10, 50)
        card.addView(request)
        requestsLinearLayout.addView(card)

        card.tag = i
        val pad = TextView(context)
        pad.tag = j
        requestsLinearLayout.addView(pad)
        requestsTag.text = "Requests"
        approve.setOnClickListener {
            call as Session.MethodCall.SignMessage
            var credentials = Credentials.create(privateKey)
            val payload = (call.message as String).toByteArray()
            val sign = Sign.signMessage(payload, credentials.ecKeyPair)
            val result =
                    "0x" +
                            sign.r.toHexString("") +
                            sign.s.toHexString("") +
                            Integer.toHexString(byteToInt(sign.v))
            walletConnectUtils!!.session.approveRequest(call.id, result)
            var v1 = requestsLinearLayout.findViewWithTag<CardView>(i)
            var v2 = requestsLinearLayout.findViewWithTag<TextView>(j)
            requestsLinearLayout.removeView(v1)
            requestsLinearLayout.removeView(v2)
        }
        reject.setOnClickListener {
            walletConnectUtils!!.session.rejectRequest(call.id, 1, "Message Not Signed")
            var v1 = requestsLinearLayout.findViewWithTag<CardView>(i)
            var v2 = requestsLinearLayout.findViewWithTag<TextView>(j)
            requestsLinearLayout.removeView(v1)
            requestsLinearLayout.removeView(v2)
        }
    }

    @SuppressLint("SetTextI18n")
    private fun personalSign(call: Session.MethodCall, context: Context) {

        call as Session.MethodCall.Custom
        var i = Random(123).nextInt()
        var j = Random(133).nextInt()
        Log.e("Transaction", "In SendTransaction")
        requestsTag.text = "Requests"
        val card = CardView(context)
        card.elevation = 0.toFloat()
        card.setCardBackgroundColor(Color.parseColor("#E8E6E1"))
        card.radius = 50.toFloat()
        val request = LinearLayout(context)
        request.gravity = Gravity.CENTER
        request.orientation = LinearLayout.VERTICAL
        request.layoutParams =
                ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        val tag = TextView(context)
        tag.setTypeface(null, Typeface.BOLD)
        tag.text = "Sign "

        tag.gravity = Gravity.CENTER_HORIZONTAL
        tag.setTypeface(null, Typeface.BOLD)
        tag.textSize = 16.0.toFloat()
        tag.setTextColor(Color.BLACK)
        request.addView(tag)
        val data = TextView(context)
        data.text = "Personal sign requested"
        data.gravity = Gravity.CENTER_HORIZONTAL
        // data.text = "${walletConnectUtils!!.session.peerMeta()!!.name} has Requested your
        // signature"
        data.textSize = 16.0.toFloat()
        request.addView(TextView(context))
        request.addView(data)
        val shape1 = GradientDrawable()
        shape1.cornerRadius = 25.toFloat()
        shape1.setColor(Color.parseColor("#FFD287FD"))
        val shape2 = GradientDrawable()
        shape2.cornerRadius = 25.toFloat()
        shape2.setColor(Color.parseColor("#FFEABC78"))
        val params: LinearLayout.LayoutParams =
                LinearLayout.LayoutParams(
                        ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT)
        params.weight = 1.0f
        val approve = Button(context)
        approve.layoutParams = params
        approve.text = "Approve"
        approve.width = ViewGroup.LayoutParams.WRAP_CONTENT
        approve.height = ViewGroup.LayoutParams.WRAP_CONTENT
        approve.background = shape1
        val reject = Button(context)
        reject.layoutParams = params
        reject.text = "Reject"
        reject.width = ViewGroup.LayoutParams.WRAP_CONTENT
        reject.height = ViewGroup.LayoutParams.WRAP_CONTENT
        reject.background = shape2
        val flexBox = FlexboxLayout(context)
        val flexboxLp: FlexboxLayout.LayoutParams =
                FlexboxLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        flexboxLp.flexGrow = 1.0f
        flexboxLp.alignSelf = AlignItems.CENTER
        flexBox.layoutParams = flexboxLp
        flexBox.flexDirection = FlexDirection.ROW
        flexBox.justifyContent = JustifyContent.SPACE_EVENLY
        flexBox.alignContent = AlignContent.CENTER
        flexBox.addView(reject)
        flexBox.addView(approve)
        request.addView(TextView(context))
        request.addView(flexBox)
        request.setPadding(10, 50, 10, 50)
        card.addView(request)
        requestsLinearLayout.addView(card)

        card.tag = i
        val pad = TextView(context)
        pad.tag = j
        requestsLinearLayout.addView(pad)
        requestsTag.text = "Requests"
        approve.setOnClickListener {
            var credentials = Credentials.create(privateKey)
            val payload = (call.params!![0] as String).toByteArray()
            val sign =
                    Sign.signMessage(
                            0x19.toByte().toByteArray() +
                                    ("Ethereum Signed Message:\n" + payload.size).toByteArray() +
                                    payload,
                            credentials.ecKeyPair)
            val result =
                    "0x" +
                            sign.r.toHexString("") +
                            sign.s.toHexString("") +
                            Integer.toHexString(byteToInt(sign.v))
            walletConnectUtils!!.session.approveRequest(call.id, result)

            var v1 = requestsLinearLayout.findViewWithTag<CardView>(i)
            var v2 = requestsLinearLayout.findViewWithTag<TextView>(j)
            requestsLinearLayout.removeView(v1)
            requestsLinearLayout.removeView(v2)
        }
        reject.setOnClickListener {
            walletConnectUtils!!.session.rejectRequest(call.id, 1, "Message Not Signed")
            var v1 = requestsLinearLayout.findViewWithTag<CardView>(i)
            var v2 = requestsLinearLayout.findViewWithTag<TextView>(j)
            requestsLinearLayout.removeView(v1)
            requestsLinearLayout.removeView(v2)
        }
    }

    private fun byteToInt(bytes: ByteArray): Int {
        var result = 0
        var shift = 0
        for (byte in bytes) {
            result = result or (byte.toInt() shl shift)
            shift += 8
        }
        return result
    }

    private fun Byte.toByteArray() = ByteArray(1) { this }
}
