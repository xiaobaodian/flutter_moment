package com.threecats.ndict.enums

/**
 * 由 zhang 于 2018/8/18 创建
 */
enum class EProposedDosageType(val code: Int, val chinaName: String) {
    RNI(0,"推荐摄入量"),
    AI(1,"适宜摄入量"),
    UL(2,"可耐受最高摄入量")
}