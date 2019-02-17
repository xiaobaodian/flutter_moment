package com.threecats.fluttermoment.models

import android.content.Context
import android.util.Log
import com.google.gson.Gson
import com.threecats.fluttermoment.MomentApplication
import io.objectbox.Box
import io.objectbox.kotlin.boxFor

/**
 * 由 zhang 于 2019/1/25 创建
 */
object DataSource {

    lateinit var app: MomentApplication

    val context: Context
        get() = app.applicationContext

    lateinit var focusItemBox:  Box<FocusItem>
    lateinit var personItemBox: Box<PersonItem>
    lateinit var placeItemBox:  Box<PlaceItem>
    lateinit var dailyEventBox: Box<DailyEvent>
    lateinit var focusEventBox: Box<FocusEvent>

    fun init(app: MomentApplication) {
        this.app = app

        focusItemBox = app.boxStore.boxFor()
        personItemBox = app.boxStore.boxFor()
        placeItemBox = app.boxStore.boxFor()
        dailyEventBox = app.boxStore.boxFor()
        focusEventBox = app.boxStore.boxFor()
    }

    // FocusItem

    fun getFocusItemsFromJson(): String {
        if (focusItemBox.count() == 0L) initFocusList()
        return Gson().toJson(focusItemBox.query().build().find())
    }
    fun putFocusItem(item: FocusItem): Long = focusItemBox.put(item)
    fun removeFocusItemFor(id: Long) = focusItemBox.remove(id)

    // PersonItem

    fun getPersonItemsFromJson(): String = Gson().toJson(personItemBox.query().build().find())
    fun putPersonItem(item: PersonItem): Long = personItemBox.put(item)
    fun removePersonItemFor(id: Long) = personItemBox.remove(id)

    // PlaceItem

    fun getPlaceItemsFromJson(): String = Gson().toJson(placeItemBox.query().build().find())
    fun putPlaceItem(item: PlaceItem): Long = placeItemBox.put(item)
    fun removePlaceItemFor(id: Long) = placeItemBox.remove(id)

    // DailyEvent

    fun getDailyEventsFromJson(): String = Gson().toJson(dailyEventBox.query().build().find())
    fun getDailyEventFromJson(dayIndex: Long): DailyEvent? {
        val dailyEventQuery = dailyEventBox.query()
        return dailyEventQuery.equal(DailyEvent_.dayIndex, dayIndex).build().findFirst()
    }
    fun putDailyEvent(dailyEvent: DailyEvent): Long = dailyEventBox.put(dailyEvent)
    fun removeDailyEventFor(id: Long) = dailyEventBox.remove(id)

    // FocusEvent


    private fun initFocusList() {
        focusItemBox.put(FocusItem("天气与心情", "今天的天气状况与我的心情。", systemPresets = true))
        focusItemBox.put(FocusItem("随笔", "", systemPresets = true))
        focusItemBox.put(FocusItem("我的工作", "记下工作中遇到的问题，形成原因，以及采取的处置办法。多进行此类总结有利于工作能力的提升。"))
        focusItemBox.put(FocusItem("家庭圈", "今天你的家庭有哪些活动值得记录？记下这美好时刻。"))
        focusItemBox.put(FocusItem("朋友圈", "朋友间的趣闻和聚会也是有很多值得品味的，记下来，分享给大家。"))
        focusItemBox.put(FocusItem("购物", "血拼的战报，提醒自己要多挣钱。"))
        focusItemBox.put(FocusItem("读书与知识", "提升自己的知识和见识，需要大量的阅读，多花些时间看看书, 多花些时间思考。"))
        focusItemBox.put(FocusItem("健身项目", "身体是革命的本钱，锻炼身体，保卫祖国。好身体也是快乐的源泉..."))
        focusItemBox.put(FocusItem("宠物星球", "小宠物们的日常点滴。"))
        focusItemBox.put(FocusItem("熊孩子成长记", "家里熊孩子的日常点滴。"))
        focusItemBox.put(FocusItem("饮食及身体反应", "每天的饮食状况与身体的反应。"))
    }

}