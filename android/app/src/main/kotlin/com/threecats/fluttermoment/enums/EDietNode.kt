package com.threecats.ndict.enums

/**
 * 由 zhang 于 2018/6/13 创建
 */
enum class EDietNode(val index: Int, val chineseName: String) {
    Breakfast(0, "早餐"),
    Lunch(1, "午餐"),
    Dinner(2,"晚餐"),
    AfternoonTea(3,"下午茶"),
    Snacks(4,"零食"),
    Other(5,"补餐")
}