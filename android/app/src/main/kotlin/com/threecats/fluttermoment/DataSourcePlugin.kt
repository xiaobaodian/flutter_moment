package com.threecats.fluttermoment

import android.content.Context
import android.util.Log
import com.google.gson.Gson
import com.threecats.fluttermoment.models.*
//import com.threecats.fluttermoment.models.DataSource.getDailyEvent
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
                "LoadFocusItems" -> {
                    result.success(DataSource.getFocusItemsFromJson())
                }
                "PutFocusItem" -> {
                    val json = methodCall.arguments as String
                    val focusItem = Gson().fromJson(json, FocusItem::class.java)
                    // put到数据库，并返回boxId
                    result.success(DataSource.putFocusItem(focusItem))
                }
                "RemoveFocusItem" -> {
                    val id = (methodCall.arguments as String).toLong()
                    DataSource.removeFocusItemFor(id)
                    result.success(null)
                }
                "PutPersonItem" -> {
                    val json = methodCall.arguments as String
                    val personItem = Gson().fromJson(json, PersonItem::class.java)
                    result.success(DataSource.putPersonItem(personItem))
                }

                "LoadPersonItems" -> {
                    result.success(DataSource.getPersonItemsFromJson())
                }
                "RemovePersonItem" -> {
                    val id = (methodCall.arguments as String).toLong()
                    DataSource.removePersonItemFor(id)
                    result.success(null)
                }

                "LoadPlaceItems" -> {
                    result.success(DataSource.getPlaceItemsFromJson())
                }
                "PutPlaceItem" -> {
                    val json = methodCall.arguments as String
                    val placeItem = Gson().fromJson(json, PlaceItem::class.java)
                    result.success(DataSource.putPlaceItem(placeItem))
                }
                "RemovePlaceItem" -> {
                    val id = (methodCall.arguments as String).toLong()
                    DataSource.removePlaceItemFor(id)
                    result.success(null)
                }

                "LoadDailyEvents" -> {
                    result.success(DataSource.getDailyEventsFromJson())
                }

                "PutDailyEvent" -> {
                    // 获取参数
                    val json = methodCall.arguments as String
                    val dailyEvent = Gson().fromJson(json, DailyEvent::class.java)
                    //Log.d("android", p.name)
                    result.success(DataSource.putDailyEvent(dailyEvent))
                }
                "GetDailyEvent" -> {
                    // 获取参数
                    //val dayIndex = methodCall.arguments as Long
                    //val dailyEvent = getDailyEvent(dayIndex)
                    //Log.d("android", p.name)
                    //result.success(dailyEvent)
                }
                else -> result.notImplemented()
            }
        }
    }
}
