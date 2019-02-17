package com.threecats.ndict.enums

/**
 * 由 zhang 于 2018/1/8 创建
 */
enum class EWeightMeasure(val code: Int, val chineseName: String) {
    Mcg(0,"微克"),
    Mg(1,"毫克"),
    Gram(2,"克"),
    Kilogram(3,"千克"),
    Milliliter(4,"毫升"),
    Litre(5,"升")
}