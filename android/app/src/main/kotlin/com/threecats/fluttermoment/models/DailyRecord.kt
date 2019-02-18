package com.threecats.fluttermoment.models

import io.objectbox.annotation.Backlink
import io.objectbox.annotation.Entity
import io.objectbox.annotation.Id
import java.util.Collections.list

/**
 * 由 zhang 于 2019/1/27 创建
 *
 * 某天的事件。便于按天显示详情时检索
 * @param dayIndex 当天的序列索引号
 * @param focusEvents 当天的焦点事件列表
 * @param weather 当前的天气描述
 */

@Entity
data class DailyRecord(
        var dayIndex: Int = 0,
        var weather: String = ""
) {
    @Id
    var boxId: Long = 0
    // 这是一个虚属性，只为了方便向flutter端返回数据，从flutter端不传数据过来，因此存在数据库
    // 中的就是一个空字段，不能用@Transient标注排除，那样就不能生成json了
    var focusEvents: List<FocusEvent> = listOf()
}