package com.threecats.fluttermoment.models

import com.threecats.fluttermoment.helper.DateTime
import io.objectbox.annotation.Backlink
import io.objectbox.annotation.Convert
import io.objectbox.annotation.Entity
import io.objectbox.annotation.Id
import io.objectbox.converter.PropertyConverter
import java.util.*

/**
 * 由 zhang 于 2019/1/24 创建
 *
 * 人物的属性
 *
 * @param name 姓名
 * @param gender 性别（0=女，1=男，2=none）
 * @param birthday 生日
 * @param height 身高
 * @param weight 体重
 * @param master 主账户标记
 * @param bmobId bmob系统的Id
 * @param bmobUpdateAt bmob系统的更新时间
 */

@Entity
data class PersonItem(
    var name: String = "",
    var photo: String = "",
    var gender: Int = 2,
    var birthday: String = "",
    var height: Float = 0.0f,
    var weight: Float = 0.0f,
    var master: Boolean = false,

    var references: Int = 0

) {
    @Id
    var boxId: Long = 0
    var bmobId: String = ""
    var bmobUpdateAt: String = ""
}