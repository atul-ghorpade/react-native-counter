package com.reactnativecounter

import android.graphics.Color
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.facebook.react.viewmanagers.CounterViewManagerDelegate
import com.facebook.react.viewmanagers.CounterViewManagerInterface

@ReactModule(name = CounterViewManager.REACT_CLASS)
class CounterViewManager : SimpleViewManager<CounterView>(),
    CounterViewManagerInterface<CounterView> {
  
  companion object {
    const val REACT_CLASS = "CounterView"
  }

  private val mDelegate: ViewManagerDelegate<CounterView> by lazy {
    CounterViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<CounterView> = mDelegate

  override fun getName(): String = REACT_CLASS

  override fun createViewInstance(reactContext: ThemedReactContext): CounterView {
    return CounterView(reactContext)
  }

  @ReactProp(name = "count")
  override fun setCount(view: CounterView, count: Int) {
    view.setCount(count)
  }

  override fun increment(view: CounterView) {
    view.increment()
  }

  override fun decrement(view: CounterView) {
    view.decrement()
  }

  override fun getExportedCustomDirectEventTypeConstants(): MutableMap<String, Any> {
    return mutableMapOf(
      "onCountChange" to mapOf("registrationName" to "onCountChange")
    )
  }
}

