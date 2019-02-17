package com.threecats.fluttermoment.models

import io.objectbox.annotation.Entity
import io.objectbox.annotation.Id


/**
 * 由 zhang 于 2019/1/25 创建
 *
 * 位置信息
 *
 * @param title 位置的标题
 * @param address 地址
 * @param picture 图片
 * @param references 该焦点引用的次数
 */

@Entity
data class PlaceItem (
        var title: String = "",
        var address: String = "",
        var picture: String = "",
        var references: Int = 0
) {
    @Id
    var boxId: Long = 0
    var bmobId: String = ""
    var bmobUpdateAt: String = ""
}