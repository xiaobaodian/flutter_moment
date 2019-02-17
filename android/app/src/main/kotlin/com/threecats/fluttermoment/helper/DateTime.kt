package com.threecats.fluttermoment.helper

import java.util.*

/**
 * 由 zhang 于 2019/1/27 创建
 */

class DateTime() {

    var dateTime: Calendar

    var year: Int
        get() = dateTime.get(Calendar.YEAR)
        set(value) = dateTime.set(Calendar.YEAR, value)

    var month: Int
        get() = dateTime.get(Calendar.MONTH)
        set(value) = dateTime.set(Calendar.MONTH, value)

    var day: Int
        get() = dateTime.get(Calendar.DAY_OF_MONTH)
        set(value) = dateTime.set(Calendar.DAY_OF_MONTH, value)

    var hour: Int
        get() = dateTime.get(Calendar.HOUR_OF_DAY)
        set(value) = dateTime.set(Calendar.HOUR_OF_DAY, value)

    var minute: Int
        get() = dateTime.get(Calendar.MINUTE)
        set(value) = dateTime.set(Calendar.MINUTE, value)

    var time: Date
        get() = dateTime.time
        set(value) {dateTime.time = value}

    val months: Int
        get() = year * 12 + month

    init{
        dateTime = Calendar.getInstance()
    }

    constructor(year: Int, month: Int, day: Int): this(){
        dateTime.set(year, month, day)
        hour = 0
        minute = 0
    }
    constructor(hour: Int, minute: Int): this(){
        this.hour = hour
        this.minute = minute
    }
    constructor(year: Int, month: Int, day: Int, hour: Int, minute: Int): this(){
        dateTime.set(year, month, day)
        this.hour = hour
        this.minute = minute
    }
    constructor(date: Date): this(){
        dateTime.time = date
    }
    constructor(calendar: Calendar): this(){
        dateTime = calendar.clone() as Calendar
    }
}