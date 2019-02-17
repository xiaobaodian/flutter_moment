package com.threecats.fluttermoment.models

import io.objectbox.annotation.Entity
import io.objectbox.annotation.Id
import io.objectbox.relation.ToOne

/**
 * 由 zhang 于 2019/1/26 创建
 */

@Entity
data class FocusEvent (
        var focusItemBoxId: Long = 0,
        var note: String = ""
) {
    @Id
    var boxId: Long = 0
    lateinit var dailyEvent: ToOne<DailyEvent>
}