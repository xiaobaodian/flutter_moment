package com.threecats.ndict.enums

/**
 * 由 zhang 于 2018/6/23 创建
 */
enum class ECandidateType(val index: Int, val ChineseName: String){
    Search(0,"检索"),
    History(1,"历史"),
    Collect(2,"收藏"),
    Custom(3,"自定义")
}