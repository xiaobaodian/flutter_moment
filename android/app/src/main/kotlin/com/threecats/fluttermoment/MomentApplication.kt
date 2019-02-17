package com.threecats.fluttermoment

import com.threecats.fluttermoment.models.DataSource
import com.threecats.fluttermoment.models.MyObjectBox
import io.flutter.app.FlutterApplication
import io.objectbox.BoxStore
//import io.objectbox.android.AndroidObjectBrowser

/**
 * 由 zhang 于 2019/1/25 创建
 */
class MomentApplication: FlutterApplication() {

    lateinit var boxStore: BoxStore
        private set

    override fun onCreate() {
        super.onCreate()
        boxStore = MyObjectBox.builder().androidContext(this).build()
//        if (BuildConfig.DEBUG) {
//            AndroidObjectBrowser(boxStore).start(this)
//        }
        DataSource.init(this)
    }
}