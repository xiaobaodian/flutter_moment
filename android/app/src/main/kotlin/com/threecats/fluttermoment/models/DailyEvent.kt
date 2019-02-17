package com.threecats.fluttermoment.models

import io.objectbox.annotation.Backlink
import io.objectbox.annotation.Entity
import io.objectbox.annotation.Id

/**
 * 由 zhang 于 2019/1/27 创建
 *
 * 某天的事件。便于按天显示详情时检索
 * @param dayIndex 当天的序列索引号
 * @param focusEvents 当天的焦点事件列表
 * @param weather 当前的天气描述
 */

@Entity
data class DailyEvent(
        var dayIndex: Int = 0,
        var weather: String = ""
) {
    @Id
    var boxId: Long = 0

    @Backlink(to = "dailyEvent")
    lateinit var focusEvents: List<FocusEvent>
}