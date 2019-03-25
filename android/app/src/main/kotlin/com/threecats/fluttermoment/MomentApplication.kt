package com.threecats.fluttermoment

import com.threecats.fluttermoment.models.DataSource
import io.flutter.app.FlutterApplication


/**
 * 由 zhang 于 2019/1/25 创建
 */
class MomentApplication: FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        DataSource.init(this)
    }
}