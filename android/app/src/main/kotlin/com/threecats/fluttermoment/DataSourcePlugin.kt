package com.threecats.fluttermoment

import android.content.Context
import io.flutter.plugin.common.*

/**
 * 由 zhang 于 2019/1/23 创建  registrar: PluginRegistry.Registrar
 */
object DataSourcePlugin {

    private const val ChannelName = "DataSource"

    @JvmStatic
    fun registerWith(registry: PluginRegistry, context: Context) {
        val registrar = registry.registrarFor(ChannelName)
        val channel = MethodChannel(registrar.messenger(), ChannelName)
        channel.setMethodCallHandler { methodCall, result ->
            when (methodCall.method) {

            }
        }
    }
}
