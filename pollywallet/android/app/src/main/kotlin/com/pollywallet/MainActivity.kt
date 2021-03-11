package com.pollywallet

import android.app.Application
import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {
   init {
       MainActivity.instance= this
   }
    private var instance: Application? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //Alerts.register(this)
        GeneratedPluginRegistrant.registerWith(this.flutterEngine!!)

    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        flutterEngine.platformViewsController
                .registry
                .registerViewFactory("WalletConnectView", NativeViewFactory())
    }
    companion object {
        var instance: MainActivity? = null
        @JvmStatic
        fun getAcitivtyContext(): Context {
            return instance!!.applicationContext
        }
    }

}