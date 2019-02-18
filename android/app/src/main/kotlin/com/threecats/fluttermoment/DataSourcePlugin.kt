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
                    result.success(DataSource.getPersonItemsOfJson())
                }
                "RemovePersonItem" -> {
                    val id = (methodCall.arguments as String).toLong()
                    DataSource.removePersonItemFor(id)
                    result.success(null)
                }

                "LoadPlaceItems" -> {
                    result.success(DataSource.getPlaceItemsOfJson())
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

                "LoadDailyRecords" -> {
                    result.success(DataSource.getDailyRecordsOfJson())
                }

                "PutDailyRecord" -> {
                    // 获取参数
                    val json = methodCall.arguments as String
                    val dailyRecord = Gson().fromJson(json, DailyRecord::class.java)
                    Log.d("android", "daily reocrd: $dailyRecord")
                    result.success(DataSource.putDailyRecord(dailyRecord))
                }
                "GetDailyRecord" -> {
                    // 获取参数
                    val dayIndex = methodCall.arguments as Int
                    val dailyRecord = DataSource.getDailyRecordFrom(dayIndex)
                    //Log.d("android", p.name)
                    result.success(dailyRecord)
                }
                "RemoveDailyRecord" -> {
                    val id = (methodCall.arguments as String).toLong()
                    DataSource.removeDailyRecordFor(id)
                }
                "PutFocusEvent" -> {
                    val json = methodCall.arguments as String
                    val focusEvent = Gson().fromJson(json, FocusEvent::class.java)
                    result.success(DataSource.putFocusEvent(focusEvent))
                }
                else -> result.notImplemented()
            }
        }
    }
}
