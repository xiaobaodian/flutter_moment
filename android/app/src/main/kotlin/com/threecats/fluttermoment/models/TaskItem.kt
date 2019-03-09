package com.threecats.fluttermoment.models

import io.objectbox.annotation.Entity
import io.objectbox.annotation.Id

/**
 * 由 zhang 于 2019/3/6 创建
 */

@Entity
data class TaskItem (
        var focusItemId: Long = 0,
        var title: String = "",
        var comment: String = "",
        var placeItemId: Long = 0,
        var references: Int = 0,
        var priority: Int = 0,
        var state: Int = 0,
        var createDate: Int = 0,
        var startDate: Int = 0,
        var dueDate: Int = 0,
        var time: String = "",
        var allDay: Int = 0,
        var subTasks: String = "",
        var context: String = "",
        var tags: String = "",
        var remindPlan: Int = 0,
        var shareTo: String = "",
        var author: Int = 0,
        var delegate: Int = 0
) {
    @Id
    var boxId: Long = 0
    var bmobId: String = ""
    var bmobUpdateAt: String = ""
}