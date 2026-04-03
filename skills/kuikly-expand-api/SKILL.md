---
name: kuikly-expand-api
description: "Kuikly 自定义 Module 开发助手。指导如何创建自定义 Module，扩展原声API。覆盖完整开发流程：Kuikly 侧 Module 定义、Pager/ComposeContainer 注册、各平台 Native 侧实现、Module 注册,及使用。当用户需要自定义 Module、扩展原生 API、实现 Kuikly 与 Native 双向通信、在各平台实现 Module 的 Native 侧逻辑时使用。"
---

# Kuikly 自定义 Module 开发

## Contents
- [Core Guidelines](#core-guidelines)
- [Workflow: Creating Custom Module (Kuikly Side)](#workflow-creating-module-kuikly-side)
- [Workflow: Implementing Native Side Module](#workflow-implementing-native-side-module)

## Core Guidelines

- **Module 是平台 API 的统一接口：** Kuikly 本身不具备平台相关能力，通过 Module 机制将 Native API 暴露给 Kuikly 侧调用。
- **自定义 Module 需双端实现：** Kuikly 侧定义 API 接口，Native 侧（Android/iOS/鸿蒙/H5/小程序）实现具体逻辑，通过 `moduleName` 关联。
- **通信方式分同步和异步：** 同步调用（`syncToNativeMethod`）在 Kuikly 线程执行，异步调用（`asyncToNativeMethod`）在主线程执行。同步调用避免耗时操作。
- **Module 名字必须全端一致：** Kuikly 侧 `moduleName()` 返回值必须与 Native 侧注册的名字完全一致。
---

## Workflow: Creating Module (Kuikly Side)

Use this workflow to create a custom Module on the Kuikly (Kotlin) side.

**步骤：**
1. 新建 Module 类继承 `Module`，实现 `moduleName()` 方法。
2. 编写业务 API 方法，通过 `toNative` / `syncToNativeMethod` / `asyncToNativeMethod` 与 Native 通信。
3. 在 Pager 的 `createExternalModules()` 中注册 Module。
4. 在业务代码中通过 `acquireModule` 获取并使用。

### Step 1: 定义 Module 类

```kotlin
import com.tencent.kuikly.core.module.Module
import com.tencent.kuikly.core.module.CallbackFn
import com.tencent.kuikly.core.nvi.serialization.json.JSONObject

class MyLogModule : Module() {

    override fun moduleName(): String = "KRMyLogModule"

    companion object {
        const val MODULE_NAME = "KRMyLogModule"
    }
}
```

### Step 2: 编写 API 方法

Module 提供以下通信方法：

| 方法 | 调用方式 | Native 执行线程 | 参数类型 | 回调类型 |
|------|---------|----------------|---------|---------|
| `syncToNativeMethod(methodName, JSONObject?, CallbackFn?)` | 同步 | Kuikly 线程 | JSONObject（序列化为 JSON 字符串） | `CallbackFn`（JSONObject?） |
| `syncToNativeMethod(methodName, Array<Any>, AnyCallbackFn?)` | 同步 | Kuikly 线程 | 基本类型数组（String/Int/Float/ByteArray） | `AnyCallbackFn`（Any?） |
| `asyncToNativeMethod(methodName, JSONObject?, CallbackFn?)` | 异步 | 主线程 | JSONObject（序列化为 JSON 字符串） | `CallbackFn`（JSONObject?） |
| `asyncToNativeMethod(methodName, Array<Any>, AnyCallbackFn?)` | 异步 | 主线程 | 基本类型数组（String/Int/Float/ByteArray） | `AnyCallbackFn`（Any?） |
| `toNative(keepCallbackAlive, methodName, param, callback, syncCall)` | 通用底层方法 | 取决于 syncCall | Any? | `CallbackFn`（JSONObject?） |

**异步调用（无返回值）：**

```kotlin
fun log(content: String) {
    asyncToNativeMethod(
        "log",
        JSONObject().apply { put("content", content) },
        null
    )
}
```

**异步调用（带回调）：**

```kotlin
fun logWithCallback(content: String, callbackFn: CallbackFn) {
    asyncToNativeMethod(
        "logWithCallback",
        JSONObject().apply { put("content", content) },
        callbackFn
    )
}
```

**同步调用（有返回值）：**

```kotlin
fun syncLog(content: String): String {
    return syncToNativeMethod(
        "syncLog",
        JSONObject().apply { put("content", content) },
        null
    )
}
```

**二进制数据传输（使用 Array<Any> 参数）：**

```kotlin
fun uploadData(bytes: ByteArray): Any? {
    return syncToNativeMethod(
        "uploadData",
        arrayOf<Any>(bytes),
        null
    )
}
```

**常驻回调（keepCallbackAlive = true）：**

```kotlin
fun registerListener(callbackFn: CallbackFn): CallbackRef {
    val result = toNative(
        true,           // keepCallbackAlive: callback 不会被自动销毁
        "registerListener",
        null,
        callbackFn,
        false
    )
    return result.callbackRef!!
}

// 手动移除回调
fun unregisterListener(callbackRef: CallbackRef) {
    removeCallback(callbackRef)
}
```

### Step 3: 注册 Module

自定义 Module 需要在 Pager 或 ComposeContainer 的 `createExternalModules()` 中注册，两种 DSL 的注册方式一致。

**Kuikly DSL 注册：**

```kotlin
import com.tencent.kuikly.core.annotations.Page
import com.tencent.kuikly.core.module.Module

@Page("MyPage")
internal class MyPage : Pager() {

    override fun createExternalModules(): Map<String, Module>? {
        return mapOf(
            MyLogModule.MODULE_NAME to MyLogModule()
        )
    }

    // 如果有基类 BasePager 已注册了其他 Module，需要合并：
    // override fun createExternalModules(): Map<String, Module>? {
    //     val modules = (super.createExternalModules() as? HashMap) ?: hashMapOf()
    //     modules[MyLogModule.MODULE_NAME] = MyLogModule()
    //     return modules
    // }

    override fun body(): ViewBuilder { ... }
}
```

**Compose DSL 注册：**

```kotlin
import com.tencent.kuikly.compose.ComposeContainer
import com.tencent.kuikly.compose.setContent
import com.tencent.kuikly.core.annotations.Page
import com.tencent.kuikly.core.module.Module

@Page("MyComposePage")
class MyComposePage : ComposeContainer() {

    // 注册方式与 Kuikly DSL 完全一致
    override fun createExternalModules(): Map<String, Module>? {
        return mapOf(
            MyLogModule.MODULE_NAME to MyLogModule()
        )
    }

    override fun willInit() {
        super.willInit()
        setContent {
            MyScreen()
        }
    }
}
```

### Step 4: 使用 Module

**Kuikly DSL 中使用：**

```kotlin
override fun created() {
    super.created()

    val myLogModule = acquireModule<MyLogModule>(MyLogModule.MODULE_NAME)

    // 异步调用
    myLogModule.log("test log")

    // 异步调用带回调
    myLogModule.logWithCallback("log with callback") { data ->
        val result = data  // Native 侧返回的 JSONObject
    }

    // 同步调用
    val result = myLogModule.syncLog("sync log")
}
```

**Compose DSL 中使用：**

```kotlin
import androidx.compose.runtime.Composable
import com.tencent.kuikly.compose.ui.platform.LocalActivity
import com.tencent.kuikly.core.pager.Pager

@Composable
fun MyScreen() {
    val pager = LocalActivity.current.getPager() as Pager
    val myLogModule = pager.acquireModule<MyLogModule>(MyLogModule.MODULE_NAME)

    // 异步调用
    myLogModule.log("test log")

    // 异步调用带回调
    myLogModule.logWithCallback("log with callback") { data ->
        val result = data  // Native 侧返回的 JSONObject
    }

    // 同步调用
    val result = myLogModule.syncLog("sync log")
}
```

---

## Workflow: Implementing Native Side Module

Use this workflow to implement the Native side of a custom Module.

**前提：** 只需在业务需要支持的平台上实现 Native 侧 Module，无需实现所有平台。

**步骤：**
1. 确定需要支持的目标平台（Android/iOS/鸿蒙/H5/小程序）。
2. 在目标平台宿主工程中创建对应的 Module 类。
3. 实现 `call` 方法，根据 `method` 分发处理。
4. 将 Module 注册到 Kuikly 框架。

> 💡 **鸿蒙平台备注：** 鸿蒙提供 ArkTS 和 C 两种实现方式，一般情况只需选择 ArkTS 实现即可。

**各平台实现详见** [MODULE_IMPLEMENT.md](references/MODULE_IMPLEMENT.md)

**速查：各平台 Module 基类与注册方式**

| 平台 | 基类 | 注册方式 | 注意事项 |
|------|------|---------|---------|
| Android | `KuiklyRenderBaseModule()` | `registerExternalModule` 中 `moduleExport(name) { Module() }` | 重写 `call(method, params: Any?, callback)` 或 `call(method, params: String?, callback)` |
| iOS | `KRBaseModule` | 类名必须与 Kuikly 侧 moduleName 一致（运行时动态创建） | 方法名与 Kuikly 侧 methodName 一致，参数固定为 `NSDictionary`，Swift 需 `@objc` 注解 |
| 鸿蒙 (ArkTS) | `KuiklyRenderBaseModule` | `getCustomRenderModuleCreatorRegisterMap` 中注册 | 需实现 `syncMode()` 指定同步/异步模式 |
| 鸿蒙 (C) | `KRRenderModuleRegisterV2` | `InitKuikly` 中注册 | 返回值 KRAnyData 由框架释放 |
| H5 | `KuiklyRenderBaseModule()` | `registerExternalModule` 中 `moduleExport(name) { Module() }` | 同 Android |
| 小程序 | `KuiklyRenderBaseModule()` | `registerExternalModule` 中 `moduleExport(name) { Module() }` | 可通过 `NativeApi.plat` 访问 `wx` 对象 |

### Native 侧支持的数据类型

| 平台 | 支持的数据类型 |
|------|-------------|
| **Android** | `String` `Int` `Long` `Float` `Double` `Boolean` `ByteArray` `Map` `List` `JSONObject` |
| **iOS** | `NSString` `NSNumber` `BOOL` `NSData` `NSDictionary` `NSArray` |
| **鸿蒙** | `String` `Int` `Long` `Float` `Double` `Bool` `ByteArray` `Array` `Map/Record` |
| **H5/小程序** | `String` `Int` `Long` `Float` `Double` `Boolean` `Array` `Map` `List` `JSONObject` `JSONArray` |

### 数据序列化规则

| 类目 | 序列化方式 | 涉及类型 |
|------|----------|---------|
| 基础类型 | 直接透传 | `String` `Int` `Float` `Double` `Boolean` `NSNumber` |
| 二进制数据 | 直接透传 | `ByteArray` `NSData` `ArrayBuffer` |
| JSON 数据 | JSON 字符串 | `JSONObject` `JSONArray` |
| 集合类型 | JSON 字符串 | `Map/Record` `List` `NSDictionary` `NSArray` `Array` |
| 特殊规则 | 直接透传 | Array 中包含 `ByteArray`/`NSData` 时 |

> ⚠️ `syncToNativeMethod` 和 `asyncToNativeMethod` 传入 JSONObject 参数时会序列化为 JSON 字符串，不支持 ByteArray 二进制数据。传输二进制请使用 `Array<Any>` 参数的重载方法。

---

## 常见陷阱与正确做法

| ❌ 错误做法 | ✅ 正确做法 |
|------------|-----------|
| Module 名字 Kuikly 侧与 Native 侧不一致 | 确保 `moduleName()` 返回值与 Native 注册名完全一致 |
| 在 `created` 之前获取 Module | 在 `created()` 或之后获取 Module（Kuikly DSL）；在 `willInit` 的 `setContent` 之后获取（Compose DSL） |
| 同步调用中执行耗时操作 | 同步调用在 Kuikly 线程执行，避免耗时操作阻塞渲染 |
| 忘记在 `createExternalModules` 中注册自定义 Module | 自定义 Module 必须在 Pager 的 `createExternalModules()` 中注册 |
| 用 JSONObject 参数传输二进制数据 | 使用 `Array<Any>` 参数的 `syncToNativeMethod`/`asyncToNativeMethod` 传输 ByteArray |
| iOS 侧 Module 类名与 Kuikly 侧不一致 | iOS 通过类名动态创建 Module，类名必须与 `moduleName()` 一致 |
| iOS 侧用 Swift 实现但未加 `@objc` 注解 | Swift 实现的 Module 需要 `@objc` 或 `@objcMembers` 修饰 |
| 常驻回调忘记手动移除 | `keepCallbackAlive=true` 的回调需在页面销毁前调用 `removeCallback` |
| Compose DSL 中直接调用 `acquireModule` | 在 `@Composable` 函数中需通过 `LocalActivity.current.getPager().acquireModule` 获取 |
| Compose DSL 中忘记 import `LocalActivity` | 需 `import com.tencent.kuikly.compose.ui.platform.LocalActivity` |

---
