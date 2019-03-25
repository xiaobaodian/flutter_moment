package com.threecats.fluttermoment.models

import com.google.gson.Gson
import com.threecats.flutter_moment.BuildConfig
import com.threecats.fluttermoment.MomentApplication
import io.objectbox.Box
import io.objectbox.BoxStore
import io.objectbox.android.AndroidObjectBrowser
import io.objectbox.kotlin.boxFor

/**
 * 由 zhang 于 2019/1/25 创建
 */
object DataSource {
    lateinit var boxStore: BoxStore
        private set

    private lateinit var taskItemBox: Box<TaskItem>
    private lateinit var focusItemBox:  Box<FocusItem>
    private lateinit var personItemBox: Box<PersonItem>
    private lateinit var placeItemBox:  Box<PlaceItem>
    private lateinit var tagItemBox:  Box<TagItem>
    private lateinit var dailyRecordBox: Box<DailyRecord>
    private lateinit var focusEventBox: Box<FocusEvent>

    fun init(context: MomentApplication) {
        boxStore = MyObjectBox.builder().androidContext(context).build()
        if (BuildConfig.DEBUG) {
            AndroidObjectBrowser(boxStore).start(context)
        }

        taskItemBox = boxStore.boxFor()
        focusItemBox = boxStore.boxFor()
        personItemBox = boxStore.boxFor()
        placeItemBox = boxStore.boxFor()
        tagItemBox = boxStore.boxFor()
        dailyRecordBox = boxStore.boxFor()
        focusEventBox = boxStore.boxFor()
    }

    // TaskItem

    fun getTaskItemsFromJson(): String = Gson().toJson(taskItemBox.query().build().find())
    fun putTaskItem(item: TaskItem): Long = taskItemBox.put(item)
    fun removeTaskItemBy(id: Long) = taskItemBox.remove(id)

    // FocusItem

    fun getFocusItemsFromJson(): String {
        if (focusItemBox.count() == 0L) initFocusList()
        return Gson().toJson(focusItemBox.query().build().find())
    }
    fun putFocusItem(item: FocusItem): Long = focusItemBox.put(item)
    fun removeFocusItemBy(id: Long) = focusItemBox.remove(id)

    // PersonItem

    fun getPersonItemsOfJson(): String = Gson().toJson(personItemBox.query().build().find())
    fun putPersonItem(item: PersonItem): Long = personItemBox.put(item)
    fun removePersonItemBy(id: Long) = personItemBox.remove(id)

    // PlaceItem

    fun getPlaceItemsOfJson(): String = Gson().toJson(placeItemBox.query().build().find())
    fun putPlaceItem(item: PlaceItem): Long = placeItemBox.put(item)
    fun removePlaceItemBy(id: Long) = placeItemBox.remove(id)

    // TagItem

    fun getTagItemsOfJson(): String = Gson().toJson(tagItemBox.query().build().find())
    fun putTagItem(item: TagItem): Long = tagItemBox.put(item)
    fun removeTagItemBy(id: Long) = tagItemBox.remove(id)


    // DailyRecord

    //fun getDailyRecordsOfJson(): String = Gson().toJson(dailyRecordBox.query().build().find())
    fun getDailyRecordsOfJson(): String {
        val recordList = dailyRecordBox.query().build().find()
        recordList.forEach { record ->
            record.focusEvents = getFocusEventsBy(record.dayIndex)
        }

        return Gson().toJson(recordList)
    }
    fun getDailyRecordBy(dayIndex: Int): DailyRecord? {
        val dailyRecord = dailyRecordBox.query().equal(DailyRecord_.dayIndex, dayIndex.toLong()).build().findFirst()
        dailyRecord?.focusEvents = getFocusEventsBy(dayIndex)
        return dailyRecord
    }
    fun putDailyRecord(dailyRecord: DailyRecord): Long = dailyRecordBox.put(dailyRecord)
    fun removeDailyRecordBy(id: Long) = dailyRecordBox.remove(id)

    // FocusEvent

    private fun getFocusEventsBy(dayIndex: Int): List<FocusEvent> {
        val focusEventQuery = focusEventBox.query()
        return focusEventQuery.equal(FocusEvent_.dayIndex, dayIndex.toLong()).build().find()
    }

    fun putFocusEvent(focusEvent: FocusEvent): Long = focusEventBox.put(focusEvent)
    fun removeFocusEventBy(id: Long) = focusEventBox.remove(id)

    private fun initFocusList() {
        focusItemBox.put(FocusItem("天气与心情", "今天的天气状况与我的心情。", systemPresets = true))
        focusItemBox.put(FocusItem("随笔", "", systemPresets = true))
        focusItemBox.put(FocusItem("我的工作", "记下工作中遇到的问题，形成原因，以及采取的处置办法。多进行此类总结有利于工作能力的提升。"))
        focusItemBox.put(FocusItem("家庭圈", "今天你的家庭有哪些活动值得记录？记下这美好时刻。"))
        focusItemBox.put(FocusItem("朋友圈", "朋友间的趣闻和聚会也是有很多值得品味的，记下来，分享给大家。"))
        focusItemBox.put(FocusItem("购物", "血拼的战报，提醒自己要多挣钱。"))
        focusItemBox.put(FocusItem("读书与知识", "提升自己的知识和见识，需要大量的阅读，多花些时间看看书, 多花些时间思考。"))
        focusItemBox.put(FocusItem("健身", "身体是革命的本钱，锻炼身体，保卫祖国。好身体也是快乐的源泉..."))
        focusItemBox.put(FocusItem("宠物星球", "小宠物们的日常点滴。"))
        focusItemBox.put(FocusItem("流浪喵星", "帮助流浪的小动物。"))
        focusItemBox.put(FocusItem("饮食", "每天的饮食状况。"))
        focusItemBox.put(FocusItem("健康", "身体的健康状况。"))
    }

}