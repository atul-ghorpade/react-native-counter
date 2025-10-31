# React Native Counter with Fabric (New Architecture)

A complete guide to building a React Native native module with Swift UI components and Fabric (New Architecture) support.

## 📚 Table of Contents

- [Quick Reference](#quick-reference)
- [Overview](#overview)
- [What is React Native Fabric?](#what-is-react-native-fabric)
- [Project Structure](#project-structure)
- [How to Create a Native Module with Fabric](#how-to-create-a-native-module-with-fabric)
- [Execution Flow](#execution-flow)
- [Key Architectural Patterns](#key-architectural-patterns)
- [Common Issues & Solutions](#common-issues--solutions)
- [Installation & Usage](#installation--usage)
- [Development](#development)

---

## ⚡ Quick Reference

**For experienced developers**: Here's the essential file checklist and commands. Scroll down for detailed explanations.

### Files You Must Create

**Shared (Both Platforms):**

| # | File | Purpose |
|---|------|---------|
| 1 | `src/NativeCounterView.ts` | Codegen spec (TypeScript) |
| 2 | `src/CounterView.tsx` | React wrapper component |
| 3 | `src/index.tsx` | Public API exports |
| 4 | `package.json` | With `codegenConfig` section |
| 5 | `tsconfig.json` | TypeScript configuration |

**iOS Only:**

| # | File | Purpose |
|---|------|---------|
| 6 | `ios/CounterView.swift` | Swift UI component with `@objc(CounterView)` |
| 7 | `ios/CounterViewManager.swift` | Old arch manager |
| 8 | `ios/CounterViewManager.m` | RCT_EXTERN_MODULE declarations |
| 9 | `ios/CounterViewBridge.h` | Objective-C bridge interface |
| 10 | `ios/CounterViewBridge.m` | Objective-C runtime bridge implementation |
| 11 | `ios/CounterViewComponentView.h` | Fabric component header |
| 12 | `ios/CounterViewComponentView.mm` | Fabric component implementation (C++) |
| 13 | `ios/CounterViewFabric.h` | Component registration function |
| 14 | `react-native-counter.podspec` | CocoaPods spec |

**Android Only:**

| # | File | Purpose |
|---|------|---------|
| 15 | `android/build.gradle` | Gradle build configuration |
| 16 | `android/src/main/AndroidManifest.xml` | Android manifest |
| 17 | `android/src/main/java/com/.../CounterView.kt` | Kotlin UI component |
| 18 | `android/src/main/java/com/.../CounterViewManager.kt` | Manager (both architectures) |
| 19 | `android/src/main/java/com/.../CounterPackage.kt` | Package registration |

### Critical Commands

```bash
# Setup
npm init -y && npm install
cd example && npm install && cd ios && pod install

# Development
npx react-native start --reset-cache
npx react-native run-ios

# Debugging
rm -rf example/ios/{Pods,Podfile.lock,build}
pod install
ls example/ios/build/generated/ios/RNCounterSpec/  # Verify codegen
```

### Must-Have Patterns

**iOS:**
1. **Swift class**: `@objc(CounterView)` - exposes to Objective-C
2. **Swift props**: `@objc var count: NSNumber` - React Native properties
3. **Bridge pattern**: Use `NSClassFromString`, `setValue:forKey:`, `performSelector:` to avoid C++/Swift conflicts
4. **Fabric guard**: `#ifdef RCT_NEW_ARCH_ENABLED` around Fabric files
5. **CocoaPods**: `install_modules_dependencies(s)` in podspec

**Android:**
1. **Manager interface**: Implement `CounterViewManagerInterface<T>` for Fabric
2. **Delegate**: Use codegen's `CounterViewManagerDelegate`
3. **React plugin**: `apply plugin: 'com.facebook.react'` enables codegen
4. **JVM target**: Match app's JVM version (usually 17)
5. **No manual C++**: Let autolinking handle C++ compilation

**Both:**
1. **Codegen config**: `"name": "RNCounterSpec"` in package.json
2. **Metro config**: `watchFolders: [path.resolve(__dirname, '..')]` for local dev

---

## 🎯 Overview

This project demonstrates how to build a React Native native module that:
- ✅ Uses **Swift** for native iOS UI components
- ✅ Supports React Native's **New Architecture (Fabric)**
- ✅ Implements **bidirectional communication** (JS ↔️ Native)
- ✅ Uses **Codegen** for type-safe interfaces
- ✅ Supports **imperative commands** from JavaScript

The example creates a beautiful native counter component with increment/decrement buttons, showcasing how to bridge modern Swift UI with React Native's Fabric renderer.

---

## 🏗️ What is React Native Fabric?

### The Evolution: Old vs New Architecture

**Old Architecture (Pre-0.68):**
```
JavaScript ──→ Bridge ──→ Native
            (JSON serialization)
```
- Asynchronous bridge communication
- JSON serialization overhead
- Performance bottlenecks with frequent updates

**New Architecture (Fabric):**
```
JavaScript ←→ JSI ←→ C++ ←→ Native
         (Direct memory access)
```
- **JSI (JavaScript Interface)**: Direct JavaScript ↔️ C++ communication
- **Fabric Renderer**: Synchronous, type-safe UI updates
- **TurboModules**: Lazy-loaded native modules
- **Codegen**: Auto-generates C++ scaffolding from TypeScript specs

### Key Benefits

1. **Type Safety**: Codegen creates C++ interfaces from TypeScript definitions
2. **Performance**: Direct memory access, no JSON serialization
3. **Synchronous Operations**: Measure, layout, and render synchronously
4. **Smaller Bundle Size**: Lazy-load native modules

---

## 📁 Project Structure

```
react-native-counter/
├── src/                                    # JavaScript/TypeScript layer
│   ├── index.tsx                          # Public API exports
│   ├── CounterView.tsx                    # React component wrapper
│   └── NativeCounterView.ts               # Codegen spec (TypeScript)
│
├── ios/                                    # Native iOS implementation
│   ├── CounterView.swift                  # Swift UI component
│   ├── CounterViewManager.swift           # Old arch manager (RCTViewManager)
│   ├── CounterViewManager.m               # Objective-C bridge
│   │
│   ├── CounterViewBridge.h/.m             # Objective-C bridge for Swift
│   ├── CounterViewComponentView.h/.mm     # Fabric component (C++)
│   └── CounterViewFabric.h                # Fabric registration
│
├── android/                                # Native Android implementation
│   ├── build.gradle                       # Gradle build config with React plugin
│   ├── src/main/AndroidManifest.xml       # Android manifest
│   └── src/main/java/com/reactnativecounter/
│       ├── CounterView.kt                 # Kotlin UI component
│       ├── CounterViewManager.kt          # Manager (both architectures)
│       └── CounterPackage.kt              # Package registration
│
├── react-native-counter.podspec           # CocoaPods specification
└── package.json                           # NPM package config
```

### File Responsibilities

**Shared:**

| File | Purpose | Language | Architecture |
|------|---------|----------|--------------|
| `NativeCounterView.ts` | Codegen spec - defines props, events, commands | TypeScript | Both |
| `CounterView.tsx` | React wrapper component | TypeScript/React | Both |

**iOS:**

| File | Purpose | Language | Architecture |
|------|---------|----------|--------------|
| `CounterView.swift` | Native UI implementation | Swift | Both |
| `CounterViewManager.swift` | Old architecture manager | Swift | Old |
| `CounterViewBridge.m` | Swift ↔️ Objective-C++ bridge | Objective-C | Both |
| `CounterViewComponentView.mm` | Fabric component integration | Objective-C++ | Fabric |
| `CounterViewFabric.h` | Fabric component registration | Objective-C/C | Fabric |

**Android:**

| File | Purpose | Language | Architecture |
|------|---------|----------|--------------|
| `CounterView.kt` | Native UI implementation | Kotlin | Both |
| `CounterViewManager.kt` | Manager with Fabric delegate | Kotlin | Both |
| `CounterPackage.kt` | Package registration | Kotlin | Both |
| `build.gradle` | Build config + codegen setup | Gradle | Both |

---

## 🚀 How to Create a Native Module with Fabric

### Prerequisites Checklist

Before starting, ensure you have:
- ✅ Node.js ≥ 18
- ✅ Xcode ≥ 15.0 with Command Line Tools
- ✅ CocoaPods ≥ 1.15 (`sudo gem install cocoapods`)
- ✅ React Native ≥ 0.76 project (or will create one)

### Step 0: Initialize the Project

#### Create the Library Package

```bash
# Create project directory
mkdir react-native-counter
cd react-native-counter

# Initialize npm package
npm init -y

# Create folder structure
mkdir -p src ios example
```

#### Configure package.json

Edit `package.json`:

```json
{
  "name": "react-native-counter",
  "version": "0.1.0",
  "description": "A React Native counter with native implementation using Fabric",
  "main": "lib/commonjs/index.js",
  "module": "lib/module/index.js",
  "types": "lib/typescript/index.d.ts",
  "react-native": "src/index.tsx",
  "source": "src/index.tsx",
  "scripts": {
    "typescript": "tsc --noEmit",
    "prepare": "echo 'Skipping build - using source directly'"
  },
  "keywords": ["react-native", "counter", "fabric", "new-architecture"],
  "license": "MIT",
  "peerDependencies": {
    "react": "*",
    "react-native": "*"
  },
  "devDependencies": {
    "@react-native/eslint-config": "^0.73.0",
    "@types/react": "^18.2.0",
    "@types/react-native": "^0.72.0",
    "react": "18.2.0",
    "react-native": "0.76.0",
    "typescript": "^5.0.0"
  },
  "codegenConfig": {
    "name": "RNCounterSpec",
    "type": "all",
    "jsSrcsDir": "src",
    "android": {
      "javaPackageName": "com.reactnativecounter"
    }
  }
}
```

**Key Fields Explained:**
- `"react-native": "src/index.tsx"`: Metro bundler uses source files directly
- `codegenConfig`: Tells React Native where to find specs and generate code
- `name` in codegenConfig: Used for generated C++ namespace (`RNCounterSpec`)

#### Install Dependencies

```bash
npm install
```

#### Create TypeScript Config

Create `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "esnext",
    "module": "commonjs",
    "lib": ["es2017"],
    "allowSyntheticDefaultImports": true,
    "jsx": "react-native",
    "moduleResolution": "node",
    "skipLibCheck": true,
    "strict": true
  },
  "exclude": ["node_modules", "lib", "example"]
}
```

### Step 1: Define the Codegen Specification

Create `src/NativeCounterView.ts`:

```typescript
import type { ViewProps, HostComponent } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { Int32, DirectEventHandler } from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';

// Define event payload
export type OnCountChangeEvent = Readonly<{
  count: Int32;
}>;

// Define component props
export interface NativeCounterViewProps extends ViewProps {
  count?: Int32;
  onCountChange?: DirectEventHandler<OnCountChangeEvent>;
}

// Define imperative commands
export interface NativeCommands {
  increment: (viewRef: React.ElementRef<HostComponent<NativeCounterViewProps>>) => void;
  decrement: (viewRef: React.ElementRef<HostComponent<NativeCounterViewProps>>) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['increment', 'decrement'],
});

export default codegenNativeComponent<NativeCounterViewProps>('CounterView');
```

**Key Points:**
- Use `Int32`, `DirectEventHandler` from CodegenTypes
- `codegenNativeComponent` auto-generates C++ component descriptor
- `codegenNativeCommands` enables JS → Native method calls

### Step 2: Configure Codegen in package.json

```json
{
  "codegenConfig": {
    "name": "RNCounterSpec",
    "type": "all",
    "jsSrcsDir": "src",
    "android": {
      "javaPackageName": "com.reactnativecounter"
    }
  }
}
```

This tells React Native to generate:
- **iOS**: C++ component descriptors in `build/generated/ios/`
- **Android**: Java/C++ interfaces

### Step 3: Create the Swift UI Component

Create `ios/CounterView.swift`:

```swift
import Foundation
import UIKit
import React

@objc(CounterView)  // ⚠️ Critical: Exposes class to Objective-C
class CounterView: UIView {
    
    // React Native props
    @objc var count: NSNumber = 0 {
        didSet {
            counterValue = count.intValue
        }
    }
    
    @objc var onCountChange: RCTBubblingEventBlock?
    
    // Internal state
    private var counterValue: Int = 0 {
        didSet {
            updateUI()
            sendCountChangeEvent()
        }
    }
    
    // UI components
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 72, weight: .bold)
        return label
    }()
    
    // Methods
    @objc func increment() {
        counterValue += 1
    }
    
    @objc func decrement() {
        counterValue -= 1
    }
    
    private func sendCountChangeEvent() {
        onCountChange?(["count": counterValue])
    }
}
```

**Key Points:**
- `@objc(CounterView)`: Makes Swift class visible to Objective-C runtime
- `@objc` properties/methods: Exposed to React Native
- `RCTBubblingEventBlock`: Event callback from native → JS

### Step 4: Create Old Architecture Manager

Create `ios/CounterViewManager.m`:

```objective-c
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(CounterViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(count, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(onCountChange, RCTBubblingEventBlock)

RCT_EXTERN_METHOD(increment:(nonnull NSNumber *)reactTag)
RCT_EXTERN_METHOD(decrement:(nonnull NSNumber *)reactTag)

@end
```

Create `ios/CounterViewManager.swift`:

```swift
@objc(CounterViewManager)
class CounterViewManager: RCTViewManager {
    
    override func view() -> UIView! {
        return CounterView()
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc func increment(_ reactTag: NSNumber) {
        DispatchQueue.main.async {
            self.bridge.uiManager.addUIBlock { (uiManager, viewRegistry) in
                guard let view = viewRegistry?[reactTag] as? CounterView else { return }
                view.increment()
            }
        }
    }
}
```

### Step 5: Create the Objective-C Bridge (Critical for Fabric + Swift)

**Why?** Fabric's C++ component descriptors cannot directly import Swift headers. We need an Objective-C intermediary.

Create `ios/CounterViewBridge.h`:

```objective-c
#import <UIKit/UIKit.h>

@interface CounterViewBridge : NSObject

+ (UIView *)createCounterView;
+ (void)setCount:(NSNumber *)count forView:(UIView *)view;
+ (void)incrementView:(UIView *)view;
+ (void)decrementView:(UIView *)view;

@end
```

Create `ios/CounterViewBridge.m`:

```objective-c
#import "CounterViewBridge.h"
#import <objc/runtime.h>

@implementation CounterViewBridge

+ (UIView *)createCounterView {
    // Dynamically load Swift class at runtime
    Class counterViewClass = NSClassFromString(@"CounterView");
    if (counterViewClass) {
        return [[counterViewClass alloc] init];
    }
    return [[UIView alloc] init]; // Fallback
}

+ (void)setCount:(NSNumber *)count forView:(UIView *)view {
    // Use Key-Value Coding (KVC) to set property
    @try {
        [view setValue:count forKey:@"count"];
    } @catch (NSException *exception) {
        NSLog(@"Failed to set count: %@", exception);
    }
}

+ (void)incrementView:(UIView *)view {
    // Use performSelector to call method dynamically
    SEL incrementSelector = NSSelectorFromString(@"increment");
    if ([view respondsToSelector:incrementSelector]) {
        [view performSelector:incrementSelector];
    }
}

@end
```

**Key Techniques:**
- **`NSClassFromString`**: Load Swift class dynamically (no header import needed)
- **KVC (`setValue:forKey:`)**: Set properties by string name
- **`performSelector`**: Call methods by string name
- This avoids C++ compilation errors when mixing Swift + C++

### Step 6: Create the Fabric Component View

Create `ios/CounterViewComponentView.h`:

```objective-c
#ifdef RCT_NEW_ARCH_ENABLED

#import <React/RCTViewComponentView.h>

@interface CounterViewComponentView : RCTViewComponentView
@end

#endif
```

Create `ios/CounterViewComponentView.mm`:

```objective-c
#ifdef RCT_NEW_ARCH_ENABLED
#import "CounterViewComponentView.h"
#import "CounterViewBridge.h"
#import "CounterViewFabric.h"

// Import generated Fabric headers
#import <react/renderer/components/RNCounterSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNCounterSpec/Props.h>
#import <react/renderer/components/RNCounterSpec/RCTComponentViewHelpers.h>

using namespace facebook::react;

@interface CounterViewComponentView () <RCTCounterViewViewProtocol>
@end

@implementation CounterViewComponentView {
    UIView *_view;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider {
    return concreteComponentDescriptorProvider<CounterViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const CounterViewProps>();
        _props = defaultProps;

        // Create Swift view via bridge
        _view = [CounterViewBridge createCounterView];
        self.contentView = _view;
    }
    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps {
    const auto &oldViewProps = *std::static_pointer_cast<CounterViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<CounterViewProps const>(props);

    if (oldViewProps.count != newViewProps.count) {
        [CounterViewBridge setCount:@(newViewProps.count) forView:_view];
    }

    [super updateProps:props oldProps:oldProps];
}

- (void)increment {
    [CounterViewBridge incrementView:_view];
}

- (void)decrement {
    [CounterViewBridge decrementView:_view];
}

@end
#endif
```

**Key Points:**
- Inherits from `RCTViewComponentView` (Fabric's base class)
- `ComponentDescriptorProvider`: Registers component with Fabric
- `updateProps`: Handles prop changes from JavaScript
- Uses `CounterViewBridge` to interact with Swift view

### Step 7: Register Component with Fabric

Create `ios/CounterViewFabric.h`:

```objective-c
#ifdef RCT_NEW_ARCH_ENABLED

#import <React/RCTComponentViewProtocol.h>

#ifdef __cplusplus
extern "C" {
#endif

Class<RCTComponentViewProtocol> _Nullable CounterViewCls(void);

#ifdef __cplusplus
}
#endif

#endif
```

In `ios/CounterViewComponentView.mm`, add:

```objective-c
Class<RCTComponentViewProtocol> CounterViewCls(void) {
    return CounterViewComponentView.class;
}
```

**Why?** React Native's Fabric renderer calls `CounterViewCls()` to instantiate your component.

**✅ Checkpoint**: Verify Codegen spec is valid:
```bash
npm run typescript  # Should have no errors
```

---

## 🤖 Android Implementation (Fabric)

Now let's implement the Android side with Fabric support. Good news: Android is simpler because codegen + autolinking handles C++ automatically!

### Step 8: Create Android Project Structure

```bash
# From the root directory
mkdir -p android/src/main/java/com/reactnativecounter
touch android/src/main/AndroidManifest.xml
touch android/build.gradle
```

### Step 9: Configure Android build.gradle

Create `android/build.gradle`:

```gradle
buildscript {
  ext.kotlin_version = '1.9.22'
  repositories {
    google()
    mavenCentral()
  }
  dependencies {
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
  }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'
apply plugin: 'com.facebook.react'  // ⚠️ Critical: Enables codegen

def safeExtGet(prop, fallback) {
  rootProject.ext.has(prop) ? rootProject.ext.get(prop) : fallback
}

def isNewArchitectureEnabled() {
  return project.hasProperty("newArchEnabled") && project.newArchEnabled == "true"
}

def reactNativeArchitectures() {
  def value = project.getProperties().get("reactNativeArchitectures")
  return value ? value.split(",") : ["armeabi-v7a", "x86", "x86_64", "arm64-v8a"]
}

android {
  compileSdkVersion safeExtGet('compileSdkVersion', 34)
  namespace "com.reactnativecounter"

  defaultConfig {
    minSdkVersion safeExtGet('minSdkVersion', 23)
    targetSdkVersion safeExtGet('targetSdkVersion', 34)
  }

  buildFeatures {
    buildConfig false
    prefab true  // Enables React Native's prefab packages
  }

  buildTypes {
    release {
      minifyEnabled false
    }
  }

  compileOptions {
    sourceCompatibility JavaVersion.VERSION_17
    targetCompatibility JavaVersion.VERSION_17
  }

  kotlinOptions {
    jvmTarget = '17'  // ⚠️ Must match app's JVM version
  }
  
  sourceSets {
    main {
      if (isNewArchitectureEnabled()) {
        java.srcDirs += [
          "build/generated/source/codegen/java"
        ]
      }
    }
  }

  packagingOptions {
    excludes = [
      "META-INF",
      "META-INF/**",
      "**/libc++_shared.so",
      "**/libfbjni.so",
      "**/libreact_nativemodule_core.so",
    ]
  }
}

repositories {
  mavenCentral()
  google()
}

// Configure React Native codegen
react {
  jsRootDir = file("../../")
  codegenDir = file("../../node_modules/@react-native/codegen")
  
  libraryName = "RNCounterSpec"  // Must match package.json codegenConfig
  codegenJavaPackageName = "com.reactnativecounter"
}

dependencies {
  //noinspection GradleDynamicVersion
  implementation 'com.facebook.react:react-android'
  implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
}
```

**Key Points:**
- `apply plugin: 'com.facebook.react'` - Automatically runs codegen
- `libraryName` must match `codegenConfig.name` in package.json
- JVM target 17 matches React Native 0.76+ requirements
- `prefab true` enables prebuilt C++ libraries
- NO manual CMake configuration needed!

### Step 10: Create Android Manifest

Create `android/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
</manifest>
```

### Step 11: Create Kotlin UI Component

Create `android/src/main/java/com/reactnativecounter/CounterView.kt`:

```kotlin
package com.reactnativecounter

import android.content.Context
import android.graphics.Color
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
```

**Key Differences from iOS:**
- No `@objc` attributes needed (Kotlin/Java already interop with JNI)
- Direct event emission via `RCTEventEmitter`
- Android View system (LinearLayout, Button, TextView)

### Step 12: Create ViewManager with Fabric Support

Create `android/src/main/java/com/reactnativecounter/CounterViewManager.kt`:

```kotlin
package com.reactnativecounter

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.CounterViewManagerDelegate
import com.facebook.react.viewmanagers.CounterViewManagerInterface

@ReactModule(name = CounterViewManager.REACT_CLASS)
class CounterViewManager : SimpleViewManager<CounterView>(),
    CounterViewManagerInterface<CounterView> {
  
  companion object {
    const val REACT_CLASS = "CounterView"
  }

  // Codegen-generated delegate for Fabric
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
```

**Critical for Fabric:**
- Implement `CounterViewManagerInterface<T>` (generated by codegen)
- Use `CounterViewManagerDelegate` (generated by codegen)
- `getDelegate()` returns the codegen delegate
- Both old and new architectures work with this single manager!

**How it works:**
1. When `newArchEnabled=false`: Uses old `SimpleViewManager` path
2. When `newArchEnabled=true`: Delegate handles Fabric communication
3. No C++ files needed - autolinking generates and compiles them!

### Step 13: Create Package Registration

Create `android/src/main/java/com/reactnativecounter/CounterPackage.kt`:

```kotlin
package com.reactnativecounter

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager

class CounterPackage : ReactPackage {
  
  override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
    return emptyList()
  }

  override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
    return listOf(CounterViewManager())
  }
}
```

**✅ Checkpoint**: Verify files are created:
```bash
ls -la android/src/main/java/com/reactnativecounter/
# Should show: CounterView.kt, CounterViewManager.kt, CounterPackage.kt
```

---

## 🎨 iOS CocoaPods Configuration

### Step 14: Configure CocoaPods

Create `react-native-counter.podspec` in the root directory:

```ruby
Pod::Spec.new do |s|
  s.name         = "react-native-counter"
  s.version      = "0.1.0"
  s.summary      = "React Native Counter with Fabric support"
  s.homepage     = "https://github.com/yourusername/react-native-counter"
  s.license      = "MIT"
  s.author       = { "Your Name" => "your.email@example.com" }
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/yourusername/react-native-counter.git", :tag => "#{s.version}" }
  
  s.source_files = "ios/**/*.{h,m,mm,swift}"
  
  install_modules_dependencies(s)
end
```

**Important**: The `install_modules_dependencies(s)` function is provided by React Native and automatically adds the correct dependencies for Fabric support.

### Step 9: Create Public API

Create `src/index.tsx`:

```typescript
export { CounterView, useCounter } from './CounterView';
export type { CounterViewProps } from './CounterView';
```

### Step 10: Create React Component Wrapper

Create `src/CounterView.tsx`:

```typescript
import React, { useRef, useCallback, useState } from 'react';
import NativeCounterView, { Commands } from './NativeCounterView';

export const CounterView: React.FC = ({ onCountChange, style }) => {
  const ref = useRef(null);
  const [count, setCount] = useState(0);

  const handleCountChange = useCallback((event) => {
    const newCount = event.nativeEvent.count;
    setCount(newCount);
    onCountChange?.(newCount);
  }, [onCountChange]);

  return (
    <NativeCounterView
      ref={ref}
      style={style}
      count={count}
      onCountChange={handleCountChange}
    />
  );
};

export const useCounter = () => {
  const ref = useRef(null);

  const increment = useCallback(() => {
    if (ref.current) {
      Commands.increment(ref.current);
    }
  }, []);

  const decrement = useCallback(() => {
    if (ref.current) {
      Commands.decrement(ref.current);
    }
  }, []);

  return { ref, increment, decrement };
};
```

### Step 11: Create Example App for Testing

Your library is now complete! Let's create an example app to test it.

#### Initialize React Native App

```bash
# From the root directory (react-native-counter/)
npx @react-native-community/cli init CounterExample --directory example --skip-install
cd example
```

#### Configure Example App

Edit `example/package.json` and add your library:

```json
{
  "dependencies": {
    "react-native-counter": "file:.."
  }
}
```

#### Install Dependencies

```bash
npm install
cd ios
pod install
cd ..
```

#### Configure Metro for Local Development

Create `example/metro.config.js`:

```javascript
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');
const path = require('path');

const config = {
  watchFolders: [path.resolve(__dirname, '..')],
  resolver: {
    nodeModulesPaths: [
      path.resolve(__dirname, 'node_modules'),
      path.resolve(__dirname, '..', 'node_modules'),
    ],
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
```

**Why?** This tells Metro to:
- Watch the parent directory (your library source)
- Resolve modules from both the example app and library

#### Update Example App Code

Edit `example/App.tsx`:

```typescript
import React from 'react';
import {
  SafeAreaView,
  StyleSheet,
  View,
  Text,
  Button,
  StatusBar,
  useColorScheme,
} from 'react-native';
import { CounterView, useCounter } from 'react-native-counter';

function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  const { ref, increment, decrement } = useCounter();
  const [count, setCount] = React.useState(0);

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      
      <View style={styles.header}>
        <Text style={styles.title}>React Native Counter</Text>
        <Text style={styles.subtitle}>Native Fabric Component</Text>
      </View>

      <CounterView
        ref={ref}
        style={styles.counter}
        onCountChange={(newCount) => {
          console.log('Count changed:', newCount);
          setCount(newCount);
        }}
      />

      <View style={styles.controls}>
        <Text style={styles.countText}>Current Count: {count}</Text>
        <View style={styles.buttons}>
          <Button title="Decrement (JS)" onPress={decrement} />
          <Button title="Increment (JS)" onPress={increment} />
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    padding: 20,
    alignItems: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    marginTop: 4,
  },
  counter: {
    flex: 1,
  },
  controls: {
    padding: 20,
    alignItems: 'center',
  },
  countText: {
    fontSize: 18,
    marginBottom: 16,
  },
  buttons: {
    flexDirection: 'row',
    gap: 12,
  },
});

export default App;
```

### Step 12: Build and Run

#### Option 1: Using React Native CLI

```bash
# Terminal 1: Start Metro bundler
cd example
npx react-native start --reset-cache

# Terminal 2: Run iOS
cd example
npx react-native run-ios
```

#### Option 2: Using Xcode (Recommended for debugging)

```bash
# Open workspace
cd example/ios
open CounterExample.xcworkspace
```

In Xcode:
1. Select a simulator (iPhone 15, iOS 17+)
2. Press **Cmd+R** to build and run
3. Check build logs for any errors

**⚠️ Important**: Always open `.xcworkspace`, NOT `.xcodeproj` (CocoaPods requirement)

### Step 13: Verify Codegen Output

After the first build, verify Codegen generated the necessary files:

```bash
cd example/ios
ls -la build/generated/ios/RNCounterSpec/

# You should see:
# - RNCounterSpec.h
# - RNCounterSpec-generated.mm
# - ComponentDescriptors.h
# - EventEmitters.h
# - Props.h
```

**View generated code**:
```bash
cat build/generated/ios/RNCounterSpec/Props.h
```

You'll see C++ structs matching your TypeScript interface!

### Step 14: Test the Component

When the app launches, you should see:
1. **Native UI** with large counter display
2. **Native buttons** (Increment/Decrement) that work when tapped
3. **JavaScript buttons** at bottom that trigger commands
4. **Count updates** displayed in both native UI and JS text

**Test scenarios**:
- ✅ Tap native increment button → count increases
- ✅ Tap native decrement button → count decreases  
- ✅ Tap JS increment button → count increases via command
- ✅ Check console → `Count changed: X` logs appear
- ✅ Verify both native and JS displays show same count

### Troubleshooting Build Issues

#### Clean Build

If you encounter build errors:

```bash
# Clean everything
cd example/ios
rm -rf Pods Podfile.lock build
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Reinstall
pod install

# Clean Metro cache
cd ..
rm -rf node_modules/.cache
npx react-native start --reset-cache
```

#### Check CocoaPods Integration

```bash
cd example/ios
pod install --verbose

# Look for:
# "Installing react-native-counter"
# "Using source files from ..."
```

#### Verify Build Settings (Xcode)

1. Open `CounterExample.xcworkspace`
2. Select project → Build Settings
3. Search for "RCT_NEW_ARCH_ENABLED"
4. Should be set to "1" or "YES"

---

## 🔄 Execution Flow

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     JavaScript Layer                         │
├─────────────────────────────────────────────────────────────┤
│  CounterView.tsx (React Component)                          │
│           ↓                                                  │
│  NativeCounterView.ts (Codegen Spec)                        │
│           ↓                                                  │
│  ┌────────────────────────────────────────────────┐         │
│  │        Codegen (Auto-generated)                │         │
│  │  - CounterViewProps.h/.cpp                     │         │
│  │  - CounterViewEventEmitter.h/.cpp              │         │
│  │  - CounterViewComponentDescriptor.h            │         │
│  └────────────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────────┘
                           ↓ JSI
┌─────────────────────────────────────────────────────────────┐
│                       C++ Layer (Fabric)                     │
├─────────────────────────────────────────────────────────────┤
│  CounterViewComponentView.mm                                │
│           ↓                                                  │
│  CounterViewBridge.m (Objective-C Runtime)                  │
│           ↓                                                  │
│  CounterView.swift (Swift UI)                               │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow Examples

#### 1. Rendering Flow (JS → Native)

```
1. JavaScript calls:
   <CounterView count={5} />

2. Fabric updates props via JSI:
   updateProps(newProps)

3. C++ component receives:
   CounterViewProps { count: 5 }

4. CounterViewComponentView.mm:
   [CounterViewBridge setCount:@5 forView:_view]

5. CounterViewBridge.m:
   [view setValue:@5 forKey:@"count"]

6. CounterView.swift:
   count property updates → UI refreshes
```

#### 2. Event Flow (Native → JS)

```
1. User taps increment button

2. CounterView.swift:
   @objc func increment() { counterValue += 1 }

3. didSet triggers:
   onCountChange?(["count": counterValue])

4. Event bubbles through Fabric:
   EventEmitter.dispatchEvent("onCountChange", {count: 6})

5. JavaScript receives:
   <CounterView onCountChange={(e) => console.log(e.nativeEvent.count)} />
```

#### 3. Command Flow (JS → Native)

```
1. JavaScript calls:
   Commands.increment(viewRef)

2. JSI invokes native command

3. CounterViewComponentView.mm:
   - (void)increment {
     [CounterViewBridge incrementView:_view];
   }

4. CounterViewBridge.m:
   [view performSelector:@selector(increment)]

5. CounterView.swift:
   @objc func increment() { counterValue += 1 }
```

---

## 🎨 Key Architectural Patterns

### Pattern 1: Objective-C Runtime Bridge

**Problem**: C++ (Fabric) cannot directly call Swift code.

**Solution**: Use Objective-C runtime features to dynamically invoke Swift:

```objective-c
// Instead of importing Swift headers (causes C++ errors)
#import "CounterView-Swift.h"  // ❌ Breaks C++ compilation

// Use runtime reflection
Class counterViewClass = NSClassFromString(@"CounterView");  // ✅
UIView *view = [[counterViewClass alloc] init];

[view setValue:@5 forKey:@"count"];  // KVC
[view performSelector:@selector(increment)];  // Dynamic invocation
```

### Pattern 2: Dual Architecture Support

**Goal**: Support both old and new architectures in the same codebase.

**Implementation**:
- Use `#ifdef RCT_NEW_ARCH_ENABLED` guards
- Old arch: `CounterViewManager.swift` (RCTViewManager)
- New arch: `CounterViewComponentView.mm` (RCTViewComponentView)
- Shared: `CounterView.swift` (UI component)

### Pattern 3: Codegen Type Safety

**Benefit**: TypeScript types automatically generate C++ interfaces.

```typescript
// Define in TypeScript
export interface NativeCounterViewProps extends ViewProps {
  count?: Int32;
}

// Codegen generates C++ struct
struct CounterViewProps {
  int count;
};
```

No manual C++ header writing needed!

---

## 🐛 Common Issues & Solutions

### Issue 1: `Undefined symbols: _CounterViewCls`

**Error**:
```
Undefined symbols for architecture arm64:
  "_CounterViewCls", referenced from:
  _RCTThirdPartyFabricComponentsProvider
```

**Cause**: Fabric renderer can't find your component registration function.

**Solution**: Create `CounterViewFabric.h` and implement:

```objective-c
Class<RCTComponentViewProtocol> CounterViewCls(void) {
    return CounterViewComponentView.class;
}
```

Ensure this is **outside** any `@implementation` block and **inside** `#ifdef RCT_NEW_ARCH_ENABLED`.

---

### Issue 2: C++ Compilation Errors with Swift Headers

**Error**:
```
error: 'cassert' file not found
error: unknown type name 'namespace'
```

**Cause**: Trying to import Swift bridging header in `.mm` (Objective-C++) file:

```objective-c
#import "react_native_counter-Swift.h"  // ❌ Causes C++ errors
```

**Solution**: Use `CounterViewBridge` with Objective-C runtime:

```objective-c
// CounterViewBridge.m (pure Objective-C, no Swift imports)
+ (UIView *)createCounterView {
    Class counterViewClass = NSClassFromString(@"CounterView");
    return [[counterViewClass alloc] init];
}
```

---

### Issue 3: Swift Class Not Found at Runtime

**Error**:
```
NSClassFromString(@"CounterView") returns nil
```

**Cause**: Swift class not exposed to Objective-C runtime.

**Solution**: Add `@objc` attribute:

```swift
@objc(CounterView)  // ✅ Explicit Objective-C name
class CounterView: UIView {
    // ...
}
```

---

### Issue 4: Metro Bundler Can't Resolve Local Package

**Error**:
```
Unable to resolve module react-native-counter from App.tsx
```

**Cause**: Metro doesn't know about the parent directory.

**Solution**: Update `example/metro.config.js`:

```javascript
const path = require('path');

module.exports = {
  watchFolders: [path.resolve(__dirname, '..')],
  resolver: {
    nodeModulesPaths: [
      path.resolve(__dirname, 'node_modules'),
      path.resolve(__dirname, '..', 'node_modules'),
    ],
  },
};
```

---

### Issue 5: Conflicting Fabric Component Registration

**Error**:
```
Undefined symbols:
  _RCTScrollViewCls
  _RCTActivityIndicatorViewCls
```

**Cause**: Custom `RCTFabricComponentsPlugins.h` overrides React Native's built-in components.

**Solution**:
1. Delete custom `RCTFabricComponentsPlugins.h`
2. Create `CounterViewFabric.h` for your component only
3. Import React Native's official header:
```objective-c
#import <React/RCTFabricComponentsPlugins.h>
```

---

### Issue 6: CocoaPods UTF-8 Encoding Error

**Error**:
```
Unicode Normalization not appropriate for ASCII-8BIT (Encoding::CompatibilityError)
```

**Solution**:
```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
cd example/ios
pod install
```

---

## 🤖 Android-Specific Issues

### Issue 7: JVM Version Mismatch

**Error**:
```
Inconsistent JVM-target compatibility detected for tasks 'compileDebugJavaWithJavac' (17) and 'compileDebugKotlin' (11).
```

**Cause**: Library uses different JVM target than the app.

**Solution**: Match JVM versions in `android/build.gradle`:
```gradle
compileOptions {
  sourceCompatibility JavaVersion.VERSION_17
  targetCompatibility JavaVersion.VERSION_17
}

kotlinOptions {
  jvmTarget = '17'
}
```

### Issue 8: Codegen Not Running

**Error**:
```
error: package com.facebook.react.viewmanagers does not exist
```

**Cause**: React Native plugin not applied or codegen not configured.

**Solution**: Ensure these are in `android/build.gradle`:
```gradle
apply plugin: 'com.facebook.react'

react {
  jsRootDir = file("../../")
  libraryName = "RNCounterSpec"  // Must match package.json
  codegenJavaPackageName = "com.reactnativecounter"
}
```

### Issue 9: Missing Prefab Packages

**Error**:
```
Could not find com.facebook.react:react-android
```

**Cause**: Prefab not enabled or React Native dependency incorrect.

**Solution**:
```gradle
buildFeatures {
  prefab true
}

dependencies {
  implementation 'com.facebook.react:react-android'  // NOT react-native
}
```

### Issue 10: Autolinking C++ Errors

**Error**:
```
CMake Error: Target links to ReactAndroid::fabricjni but target not found
```

**Cause**: Trying to manually configure CMake for library instead of letting app handle it.

**Solution**: 
- **DO NOT** add `externalNativeBuild` to library's build.gradle
- **DO NOT** create custom CMakeLists.txt in library
- Let the example app's autolinking system compile C++ automatically
- Only the app needs CMake configuration, not the library!

---

## 📦 Installation & Usage

### Prerequisites

- **React Native** ≥ 0.76 (Fabric enabled by default)
- **Xcode** ≥ 15.0
- **Node.js** ≥ 18
- **CocoaPods** ≥ 1.15

### Install in Existing Project

```bash
npm install react-native-counter
cd ios && pod install
```

### Usage Example

```typescript
import React from 'react';
import { View, Button } from 'react-native';
import { CounterView, useCounter } from 'react-native-counter';

export default function App() {
  const { ref, increment, decrement } = useCounter();
  
  return (
    <View style={{ flex: 1 }}>
      <CounterView
        ref={ref}
        style={{ flex: 1 }}
        onCountChange={(count) => console.log('Count:', count)}
      />
      
      <Button title="Increment" onPress={increment} />
      <Button title="Decrement" onPress={decrement} />
    </View>
  );
}
```

---

## 🛠️ Development

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/yourusername/react-native-counter.git
cd react-native-counter

# Install dependencies
npm install

# Link example app to local package
cd example
npm install
npx pod-install
```

### Run the Example App

```bash
# Terminal 1: Start Metro bundler
cd example
npx react-native start --reset-cache

# Terminal 2: Run iOS app
cd example
npx react-native run-ios
# OR open in Xcode:
open ios/CounterExample.xcworkspace
# Press Cmd+R
```

### Debugging Tips

#### View Codegen Output

```bash
cd example/ios
cat build/generated/ios/RNCounterSpec/RNCounterSpec-generated.h
```

#### Enable Xcode Logging

In Xcode, go to **Edit Scheme → Run → Arguments → Environment Variables**:
- `OS_ACTIVITY_MODE` = `disable` (reduces noise)

#### Check Native Logs

```bash
# iOS
tail -f example/ios/build/Logs/Build/*.xcactivitylog

# React Native logs
npx react-native log-ios
```

### Project Commands

```bash
# Type check
npm run typescript

# Clean and rebuild
cd example/ios
rm -rf Pods Podfile.lock build
pod install
```

---

## 🎓 Learning Resources

### Official Documentation

- [React Native New Architecture](https://reactnative.dev/docs/the-new-architecture/landing-page)
- [Fabric Renderer](https://reactnative.dev/architecture/fabric-renderer)
- [Codegen](https://reactnative.dev/docs/next/the-new-architecture/pillars-codegen)
- [Swift/Objective-C Interop](https://developer.apple.com/documentation/swift/importing-objective-c-into-swift)

### Key Concepts to Master

1. **JSI (JavaScript Interface)**: C++ layer for JS ↔️ Native communication
2. **Fabric**: New synchronous rendering system
3. **TurboModules**: Lazy-loaded native modules
4. **Codegen**: Auto-generate C++ from TypeScript
5. **Objective-C Runtime**: Dynamic method invocation

---

## 📝 Summary & Checklist

### What We Built

✅ A React Native native module with:
- Swift UI component (`CounterView.swift`)
- Fabric support via C++ ComponentView
- Objective-C bridge for Swift/C++ interop
- Bidirectional communication (props, events, commands)
- Type-safe Codegen interfaces

### Pre-Launch Checklist

Before considering your library complete, verify:

#### TypeScript/JavaScript Layer
- [ ] Codegen spec (`NativeCounterView.ts`) uses correct types (`Int32`, `DirectEventHandler`)
- [ ] Commands are defined with `codegenNativeCommands`
- [ ] React wrapper component (`CounterView.tsx`) handles events properly
- [ ] Public API exports are in `index.tsx`
- [ ] `npm run typescript` passes without errors

#### iOS Native Layer
- [ ] Swift class has `@objc(YourViewName)` annotation
- [ ] All React Native props/methods are marked `@objc`
- [ ] Bridge files (`.h`, `.m`) use pure Objective-C (no Swift imports)
- [ ] ComponentView (`.mm`) is guarded with `#ifdef RCT_NEW_ARCH_ENABLED`
- [ ] Fabric registration function (`YourViewCls()`) is implemented
- [ ] Old architecture manager (RCTViewManager) is implemented for backwards compatibility

#### Android Native Layer
- [ ] ViewManager implements `CounterViewManagerInterface<T>`
- [ ] Manager uses codegen's `CounterViewManagerDelegate`
- [ ] `build.gradle` applies `'com.facebook.react'` plugin
- [ ] JVM target matches (usually 17)
- [ ] `react` block in build.gradle has correct `libraryName`
- [ ] No manual CMake configuration in library
- [ ] Package class registered in `CounterPackage.kt`

#### Configuration Files
- [ ] `package.json` has `codegenConfig` section with correct `name`
- [ ] `package.json` has `"react-native": "src/index.tsx"` entry
- [ ] `.podspec` includes `ios/**/*.{h,m,mm,swift}` in `source_files`
- [ ] `.podspec` calls `install_modules_dependencies(s)`
- [ ] `android/build.gradle` configured with React plugin
- [ ] Example app's `metro.config.js` has `watchFolders` configured

#### Build & Testing (iOS)
- [ ] `pod install` succeeds without errors
- [ ] Xcode builds successfully (Cmd+R)
- [ ] Codegen files appear in `build/generated/ios/YourSpec/`
- [ ] Example app launches in iOS simulator
- [ ] Props update correctly (JS → Native)
- [ ] Events fire correctly (Native → JS)
- [ ] Commands work correctly (JS → Native imperative calls)
- [ ] Console logs show event data

#### Build & Testing (Android)
- [ ] `./gradlew clean` succeeds
- [ ] `npx react-native run-android` builds successfully
- [ ] Codegen files appear in `build/generated/source/codegen/`
- [ ] Example app launches in Android emulator
- [ ] Props update correctly (JS → Native)
- [ ] Events fire correctly (Native → JS)
- [ ] Commands work correctly (JS → Native imperative calls)
- [ ] Console logs show event data

### Common Pitfalls to Avoid

**iOS:**

| ❌ Mistake | ✅ Solution |
|-----------|-----------|
| Importing Swift in `.mm` files | Use Objective-C bridge with `NSClassFromString` |
| Missing `@objc` on Swift class | Add `@objc(ClassName)` before class declaration |
| Wrong Codegen spec name | Must match import path in `.mm` file |
| Forgetting RCT_NEW_ARCH_ENABLED | Guard all Fabric files with `#ifdef` |
| Opening `.xcodeproj` instead of `.xcworkspace` | Always use workspace when CocoaPods is present |
| Creating custom RCTFabricComponentsPlugins.h | Only create your own registration header (e.g., `CounterViewFabric.h`) |
| Missing `install_modules_dependencies` in podspec | Fabric dependencies won't be linked |

**Android:**

| ❌ Mistake | ✅ Solution |
|-----------|-----------|
| Mismatched JVM versions | Ensure library and app use same JVM target (17) |
| Not implementing `CounterViewManagerInterface` | Manager won't work with Fabric |
| Forgetting `apply plugin: 'com.facebook.react'` | Codegen won't run |
| Wrong `libraryName` in react block | Must match `codegenConfig.name` in package.json |
| Manually configuring CMake in library | Let app's autolinking handle C++ compilation |
| Using `react-native` dependency | Use `react-android` instead |
| Creating custom ViewManagerDelegate | Use codegen's generated delegate |

**Both Platforms:**

| ❌ Mistake | ✅ Solution |
|-----------|-----------|
| Not configuring Metro watchFolders | Local package won't be found |
| Wrong Codegen types (e.g., `number` instead of `Int32`) | Use proper CodegenTypes |

### Key Takeaways

**General:**
1. **Use Codegen**: Define specs in TypeScript once, get C++ for both platforms automatically
2. **Test thoroughly**: Fabric is stricter about type safety than old architecture
3. **Follow patterns**: React Native has established patterns - don't deviate
4. **Debug incrementally**: Test after each major step

**iOS-Specific:**
1. **Bridge Swift carefully**: Use Objective-C runtime (`NSClassFromString`, KVC, `performSelector`) to avoid C++ compilation issues
2. **Guard Fabric code**: Use `#ifdef RCT_NEW_ARCH_ENABLED` around Fabric-specific files
3. **Manual C++ needed**: Create ComponentView, Bridge, and registration files explicitly
4. **CocoaPods is key**: Use `install_modules_dependencies(s)` for Fabric libraries

**Android-Specific:**
1. **Delegate pattern**: Implement `Interface`, use codegen's `Delegate` - don't create custom delegates
2. **Let autolinking work**: Don't manually configure CMake in library - app handles C++ compilation
3. **React plugin is magic**: `apply plugin: 'com.facebook.react'` does most of the heavy lifting
4. **Single Manager works**: One ViewManager supports both old and new architecture automatically

**Key Difference:**
- **iOS**: Explicit C++ bridging required (more code, more control)
- **Android**: Codegen + autolinking handles C++ automatically (simpler, less error-prone)

### Debugging Workflow

When something goes wrong, follow this order:

1. **Check TypeScript**: `npm run typescript` - fix any type errors first
2. **Check Metro**: Look for module resolution errors in Metro terminal
3. **Check CocoaPods**: `pod install --verbose` - verify library is found
4. **Check Xcode Build**: Read full build log for linker/compiler errors
5. **Check Codegen**: Verify files in `build/generated/ios/`
6. **Check Runtime**: Look for Swift class loading errors in Xcode console
7. **Clean & Rebuild**: `rm -rf` all build artifacts and try again

### Performance Tips

1. **Use `React.memo`** for React wrapper if props change frequently
2. **Debounce event handlers** if native fires many events
3. **Use `useCallback`** for command functions to avoid recreating them
4. **Consider direct manipulation** for high-frequency updates (bypassing React)

### Next Steps

#### Extend Your Library
- Add more complex UI (animations, gestures, custom layouts)
- Implement TurboModules for non-UI native functionality
- Add Android support (Kotlin + C++ using similar patterns)
- Add TypeScript type tests with `tsd`

#### Publish Your Library
```bash
# Prepare for publishing
npm run build  # If using react-native-builder-bob
npm run typescript

# Test locally first
npm pack
# Install in test app: npm install ../react-native-counter/react-native-counter-0.1.0.tgz

# Publish to npm
npm login
npm publish
```

#### Documentation
- Add API documentation (props, methods, events)
- Create GIFs/videos showing component in action
- Document platform-specific behavior
- Add troubleshooting section for users

### Real-World Applications

This pattern works for:
- **Custom UI components**: Video players, maps, charts, camera views
- **Native animations**: Complex animations that React Native Animated can't handle
- **Platform-specific UI**: Native iOS/Android design patterns
- **Performance-critical views**: High-frequency updates (games, visualizations)

### Congratulations! 🎉

You now understand:
- How Fabric's architecture differs from the old bridge **on both platforms**
- How to create Codegen specs that generate **cross-platform** C++ interfaces
- **iOS**: How to bridge Swift and C++ using Objective-C runtime
- **Android**: How to leverage codegen delegates and autolinking
- How to support both old and new architectures **simultaneously**
- How to debug complex native module issues **on iOS and Android**

**You're ready to build production-grade React Native native modules for iOS AND Android!**

### What We Accomplished

✅ **Single TypeScript Codegen Spec** → Works on both platforms  
✅ **iOS Fabric** → Swift UI + Objective-C Bridge + C++ ComponentView  
✅ **Android Fabric** → Kotlin UI + Manager Interface + Auto-generated C++  
✅ **Dual Architecture Support** → Old & New work simultaneously  
✅ **Type Safety** → Codegen ensures compile-time correctness  
✅ **Bidirectional Communication** → Props, Events, and Commands  

This is the **complete modern React Native native module pattern** for 2024+!

---

## 📄 License

MIT

---

## 🙏 Acknowledgments

This project demonstrates patterns learned from:
- React Native core team's Fabric documentation
- Community native module examples
- Real-world debugging experience with Swift/C++ interop

**Happy coding!** 🚀

If you found this guide helpful, please ⭐ star the repository!
