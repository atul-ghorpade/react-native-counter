package com.reactnativecounter

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter

class CounterView(context: Context) : LinearLayout(context) {
  
  private var counterValue: Int = 0
    set(value) {
      field = value
      updateUI()
      sendCountChangeEvent()
    }

  private val counterLabel: TextView = TextView(context).apply {
    textSize = 72f
    gravity = Gravity.CENTER
    setTextColor(Color.BLACK)
    typeface = Typeface.DEFAULT_BOLD
    layoutParams = LayoutParams(
      LayoutParams.MATCH_PARENT,
      0,
      1f
    )
  }

  private val incrementButton: Button = Button(context).apply {
    text = "Increment"
    textSize = 18f
    setBackgroundColor(Color.parseColor("#007AFF"))
    setTextColor(Color.WHITE)
    layoutParams = LayoutParams(
      0,
      LayoutParams.WRAP_CONTENT,
      1f
    ).apply {
      setMargins(8, 0, 8, 0)
    }
    setPadding(0, 40, 0, 40)
  }

  private val decrementButton: Button = Button(context).apply {
    text = "Decrement"
    textSize = 18f
    setBackgroundColor(Color.parseColor("#FF3B30"))
    setTextColor(Color.WHITE)
    layoutParams = LayoutParams(
      0,
      LayoutParams.WRAP_CONTENT,
      1f
    ).apply {
      setMargins(8, 0, 8, 0)
    }
    setPadding(0, 40, 0, 40)
  }

  private val buttonContainer: LinearLayout = LinearLayout(context).apply {
    orientation = HORIZONTAL
    gravity = Gravity.CENTER
    layoutParams = LayoutParams(
      LayoutParams.MATCH_PARENT,
      LayoutParams.WRAP_CONTENT
    ).apply {
      setMargins(32, 16, 32, 16)
    }
  }

  init {
    orientation = VERTICAL
    gravity = Gravity.CENTER
    setPadding(32, 32, 32, 32)
    setBackgroundColor(Color.WHITE)

    // Add views
    addView(counterLabel)
    
    buttonContainer.addView(decrementButton)
    buttonContainer.addView(incrementButton)
    addView(buttonContainer)

    // Set up click listeners
    incrementButton.setOnClickListener {
      increment()
    }

    decrementButton.setOnClickListener {
      decrement()
    }

    updateUI()
  }

  fun setCount(count: Int) {
    counterValue = count
  }

  fun increment() {
    counterValue++
  }

  fun decrement() {
    counterValue--
  }

  private fun updateUI() {
    counterLabel.text = counterValue.toString()
  }

  private fun sendCountChangeEvent() {
    val event = Arguments.createMap().apply {
      putInt("count", counterValue)
    }
    
    val reactContext = context as ReactContext
    reactContext
      .getJSModule(RCTEventEmitter::class.java)
      .receiveEvent(id, "onCountChange", event)
  }
}

