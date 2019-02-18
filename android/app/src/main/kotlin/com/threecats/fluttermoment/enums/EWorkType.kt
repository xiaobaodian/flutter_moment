package com.threecats.fluttermoment.enums

/**
 * 由 zhang 于 2018/1/6 创建
 */
enum class EWorkType(val type: Int, val chineseName: String, val note: String) {
    Base(0,"静止", "静卧，没有任何运动"),
    Live(1, "安静", "静卧以及少量的室内走动"),
    Normal(2, "日常", "正常的居家生活、工作学习，没有进行运动"),
    Mild(3, "轻运动", "除居家生活外，会有少量的运动，或是需要经常站立的工作"),
    Medium(4, "中运动", "正常的居家和学习外，有一定强度的健身运动，或是一定强度的体力劳作"),
    Sevete(5,"重运动", "专业运动员或高强度体能工作者")
}