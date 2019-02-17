package com.threecats.ndict.enums

/**
 * 由 zhang 于 2018/5/9 创建
 */
enum class EPregnancy(val stage: Int, val chineseName: String) {
    None(0, "正常"),
    Full(1, "孕全期"),
    Early(2, "孕早期"),
    Middle(3, "孕中期"),
    Late(4, "孕晚期")
}