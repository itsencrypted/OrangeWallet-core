package com.pollywallet

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context,
                        id: Int,
                        args: Any?): PlatformView {
        return WalletConnectView(context,
                id,
                args as Map<String?, Any?>)
    }
}