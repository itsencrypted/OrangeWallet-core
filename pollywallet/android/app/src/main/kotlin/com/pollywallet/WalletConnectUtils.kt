package com.pollywallet

import android.content.Context
import android.util.Log
import androidx.multidex.MultiDexApplication
import com.squareup.moshi.Moshi
import okhttp3.OkHttpClient
import okhttp3.internal.wait
import org.walletconnect.Session
import org.walletconnect.impls.*
import org.walletconnect.nullOnThrow
import java.io.File

class WalletConnectUtils(address: String, uri:String, chainId: String, context: Context) : MultiDexApplication() {
    private lateinit var client: OkHttpClient
    private lateinit var moshi: Moshi
    private lateinit var bridge: BridgeServer
    private lateinit var storage: WCSessionStore
    lateinit var config: Session.Config
    lateinit var session: Session
    val address: String = address
    val uri: String = uri
    val chainId: String = chainId
    var bool: Boolean = false;
    var context = context
    override fun onCreate() {

        initMoshi()
        initClient()
        initBridge()
        initSessionStorage()
        super.onCreate()
    }

    private fun initClient() {
        client = OkHttpClient.Builder().build()
    }

    private fun initMoshi() {
        moshi = Moshi.Builder().build()
    }


    private fun initBridge() {
        bridge = BridgeServer(moshi)
        bridge.start()
    }

    private fun initSessionStorage() {
        storage = FileWCSessionStore(File(cacheDir, "session_store.json").apply { createNewFile() }, moshi)
    }
    fun approveSession() {
        client = OkHttpClient.Builder().build()
        moshi = Moshi.Builder().build()
        bridge = BridgeServer(moshi)
        storage = FileWCSessionStore(File(context.cacheDir, "session_store.json").apply { createNewFile() }, moshi)

        bridge.start()
        bool = true;
        nullOnThrow { session }?.clearCallbacks()
        config = Session.Config.fromWCUri(uri)
        session = WCSession(config,
                MoshiPayloadAdapter(moshi),
                storage,
                OkHttpTransport.Builder(client, moshi),
                Session.PeerMeta(name = "PollyWallet")

        )
        session.init()
        Log.e("Address", address)
        session.offer()
        //Thread.sleep(50000)
        //session.approve(listOf(address), 42.toLong())

    }
    fun disconnectSession() {
        bool = false;
        session.kill()

    }

}

