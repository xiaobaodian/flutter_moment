package com.threecats.fluttermoment.models

import io.objectbox.annotation.Entity
import io.objectbox.annotation.Id

/**
 * 由 zhang 于 2019/3/15 创建
 */
@Entity
data class ImageLib (
        var type: Int = -1,
        var image: String = "",
        var references: Int = 0
) {
    @Id
    var boxId: Long = 0
    var bmobId: String = ""
    var bmobUpdateAt: String = ""
}