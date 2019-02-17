package com.threecats.fluttermoment.models

import io.objectbox.annotation.Entity
import io.objectbox.annotation.Id

/**
 * 由 zhang 于 2019/1/25 创建
 *
 * 叙事的焦点
 *
 * @param title 焦点的标题
 * @param comment 焦点的说明
 * @param references 该焦点引用的次数
 * @param systemPresets 系统预设焦点
 * @param internal 内部使用标志
 */

@Entity
data class FocusItem (
    var title: String = "",
    var comment: String = "",
    var references: Int = 0,
    var systemPresets: Boolean = false,
    var internal: Boolean = false
) {
    @Id
    var boxId: Long = 0
    var bmobId: String = ""
    var bmobUpdateAt: String = ""
}