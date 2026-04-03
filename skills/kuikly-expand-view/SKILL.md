---
name: kuikly-expand-view
description: "Kuikly 自定义 View 开发助手。指导如何创建自定义 UI 组件，将原生 View 暴露给 Kuikly 侧使用。覆盖完整开发流程：Kuikly 侧组件定义、各平台 Native 侧实现（Android/iOS/鸿蒙ArkTS/H5/小程序）及使用。当用户需要自定义扩展 UI 组件时使用。"
---

## Contents
- [Core Guidelines](#core-guidelines)
- [Workflow: Creating Expand View (Kuikly Side)](#workflow-creating-expand-view-kuikly-side)
- [Workflow: Implementing Native Side View](#workflow-implementing-native-side-view)

## Core Guidelines

- **View 是跨平台 UI 组件的统一接口：** Kuikly 已封装常用 View（Text、Image、List 等），自定义 View 用于复用已有原生 UI 组件或满足特殊需求。
- **自定义 View 需双端实现：** Kuikly 侧定义组件结构（viewName、Attr、Event），Native 侧（Android/iOS/鸿蒙/H5/小程序）实现具体渲染逻辑，通过 `viewName` 关联。
- **组件名必须全端一致：** Kuikly 侧 `viewName()` 返回值必须与 Native 侧注册的名字完全一致。
- **属性和事件走 setProp 方法：** Native 侧通过 `setProp(propKey, propValue)` 接收 Kuikly 侧设置的属性和事件。
- **方法调用走 call 方法：** Native 侧通过 `call(method, params, callback)` 响应 Kuikly 侧的方法调用。

---

## Workflow: Creating Expand View (Kuikly Side)

Use this workflow to create a expand View on the Kuikly (Kotlin) side.

**Kuikly 组件由四部分组成：**
1. `viewName`: 组件对应到原生组件的名字
2. `Attr`: 组件的属性，用于指定该组件含有哪些属性
3. `Event`: 用于接收来自原生组件发送的事件
4. `方法`: 组件本身支持的方法，最终实现在原生侧

**步骤：**
1. 新建 View 类继承 `DeclarativeBaseView<XxxAttr, XxxEvent>`
2. 实现 `viewName()`、`createAttr()`、`createEvent()` 方法
3. 定义 `Attr` 类继承 `Attr`，添加属性方法
4. 定义 `Event` 类继承 `Event`，添加事件注册方法
5. 编写声明式 API 扩展函数
6. 在业务代码中使用组件

### Step 1: 定义 View 类

```kotlin
import com.tencent.kuikly.core.base.DeclarativeBaseView

class MyImageView : DeclarativeBaseView<MyImageAttr, MyImageEvent>() {

    override fun createAttr(): MyImageAttr {
        return MyImageAttr()
    }

    override fun createEvent(): MyImageEvent {
        return MyImageEvent()
    }

    // 返回 Native 侧注册的组件名
    override fun viewName(): String {
        return "HRImageView"
    }
    
    // 组件方法（可选），实际实现在 Native 侧
    fun test() {
        performTaskWhenRenderViewDidLoad {
            renderView?.callMethod("test", "params")
        }
    }
}
```

### Step 2: 定义 Attr 类

`Attr` 表示组件支持的属性集。

```kotlin
import com.tencent.kuikly.core.base.Attr

class MyImageAttr : Attr() {

    /**
     * 设置图片数据源
     * @param src 图片 URL
     * @return this（支持链式调用）
     */
    fun src(src: String): MyImageAttr {
        "src" with src  // 将属性透传给原生组件
        return this
    }

    /**
     * 设置占位图
     */
    fun placeholder(url: String): MyImageAttr {
        "placeholder" with url
        return this
    }

    /**
     * 设置缩放模式
     */
    fun scaleType(type: String): MyImageAttr {
        "scaleType" with type
        return this
    }
}
```

### Step 3: 定义 Event 类

`Event` 表示组件支持的事件。

```kotlin
import com.tencent.kuikly.core.base.event.Event
import com.tencent.kuikly.core.nvi.serialization.json.JSONObject

class MyImageEvent : Event() {

    /**
     * 图片加载成功回调
     */
    fun loadSuccess(handler: (LoadSuccessParams) -> Unit) {
        register(LOAD_SUCCESS) {
            handler(LoadSuccessParams.decode(it))
        }
    }

    /**
     * 图片加载失败回调
     */
    fun loadError(handler: (LoadErrorParams) -> Unit) {
        register(LOAD_ERROR) {
            handler(LoadErrorParams.decode(it))
        }
    }

    companion object {
        const val LOAD_SUCCESS = "loadSuccess"
        const val LOAD_ERROR = "loadError"
    }
}

// 事件参数解析类
data class LoadSuccessParams(
    val src: String,
    val width: Int,
    val height: Int
) {
    companion object {
        fun decode(params: Any?): LoadSuccessParams {
            val tempParams = params as? JSONObject ?: JSONObject()
            return LoadSuccessParams(
                src = tempParams.optString("src", ""),
                width = tempParams.optInt("width", 0),
                height = tempParams.optInt("height", 0)
            )
        }
    }
}

data class LoadErrorParams(
    val src: String,
    val errorCode: Int
) {
    companion object {
        fun decode(params: Any?): LoadErrorParams {
            val tempParams = params as? JSONObject ?: JSONObject()
            return LoadErrorParams(
                src = tempParams.optString("src", ""),
                errorCode = tempParams.optInt("errorCode", 0)
            )
        }
    }
}
```

### Step 4: 组件方法（可选）

组件方法是 Kuikly 侧暴露的 API，实际实现在 Native 侧。

```kotlin
class MyImageView : DeclarativeBaseView<MyImageAttr, MyImageEvent>() {
    // ...
    
    /**
     * 重新加载图片（无返回值）
     */
    fun reload() {
        performTaskWhenRenderViewDidLoad {
            renderView?.callMethod("reload", null)
        }
    }
    
    /**
     * 获取图片信息（异步回调）
     */
    fun getImageInfo(callback: (width: Int, height: Int) -> Unit) {
        performTaskWhenRenderViewDidLoad {
            renderView?.callMethod("getImageInfo", null) { result ->
                val json = result as? JSONObject
                callback(json?.optInt("width") ?: 0, json?.optInt("height") ?: 0)
            }
        }
    }
}
```

> ⚠️ **注意：**
> - View 的方法支持异步回调结果，即 `renderView?.callMethod("method", "params", callback)`，但**不支持同步返回结果**。
> - View 方法**不支持传递二进制数据**，如需传输图片等二进制内容，请通过 Base64 编码后以 JSON 形式传递，或使用 Module 方法实现。

### Step 5: 编写声明式 API

```kotlin
import com.tencent.kuikly.core.base.ViewContainer

fun ViewContainer<*, *>.MyImage(init: MyImageView.() -> Unit) {
    addChild(MyImageView(), init)
}
```

### Step 6: 业务使用

```kotlin
override fun body(): ViewBuilder {
    val ctx = this
    return {
        MyImage {
            attr {
                size(176f, 132f)
                src("https://example.com/image.png")
                placeholder("https://example.com/placeholder.png")
            }
            event {
                loadSuccess { params ->
                    println("图片加载成功: ${params.src}, 尺寸: ${params.width}x${params.height}")
                }
                loadError { params ->
                    println("图片加载失败: ${params.errorCode}")
                }
            }
        }
    }
}
```

### 使用 ViewRef 获取组件引用

通过 `ViewRef` 可以获取组件实例，在 Pager 其他位置调用组件方法。

```kotlin
@Page("MyPage")
class MyPage : Pager() {
    
    // 声明 ViewRef
    private val imageRef = ViewRef<MyImageView>()
    
    override fun body(): ViewBuilder {
        return {
            MyImage {
                // 绑定 ref
                ref(imageRef)
                attr {
                    src("https://example.com/image.png")
                }
            }
            
            Button {
                attr { title("重新加载") }
                event {
                    click {
                        // 通过 ref 调用方法
                        imageRef.view?.reload()
                    }
                }
            }
        }
    }
}
```

---

## Workflow: Implementing Native Side View

Use this workflow to implement the Native side of a expand View.

**前提：** 只需在业务需要支持的平台上实现 Native 侧 View，无需实现所有平台。

**步骤：**
1. 确定需要支持的目标平台（Android/iOS/鸿蒙/H5/小程序）。
2. 在目标平台宿主工程中创建对应的 View 类。
3. 实现 `setProp` 方法处理属性和事件。
4. 实现 `call` 方法处理方法调用。
5. 将 View 注册到 Kuikly 框架。

**各平台实现详见** [VIEW_IMPLEMENT.md](references/VIEW_IMPLEMENT.md)

**速查：各平台 View 基类与注册方式**

| 平台 | 基类/协议 | 注册方式 | 注意事项 |
|------|----------|---------|---------|
| Android | `IKuiklyRenderViewExport` | `registerExternalRenderView` 中 `renderViewExport(name) { View(ctx) }` | 继承原生 View 并实现接口 |
| iOS | `KuiklyRenderViewExportProtocol` | **类名必须与 viewName 一致**（运行时动态创建） | 属性方法命名 `setCss_xxx`，方法命名 `css_xxx` |
| 鸿蒙 (ArkTS) | `KuiklyRenderBaseView` | `getCustomRenderViewCreatorRegisterMap` 或 `getCustomRenderViewCreatorRegisterMapV2` 中注册 | 需实现 `createArkUIView()` 返回 `ComponentContent` |
| H5 | `IKuiklyRenderViewExport` | `registerExternalRenderView` 中 `renderViewExport(name) { View() }` | 重写 `ele` 属性返回 DOM 元素 |
| 小程序 | `IKuiklyRenderViewExport` | `registerExternalRenderView` + `Transform.addComponentsAlias` + base.wxml 模板 | 需创建 `MiniXxxElement` 并配置模板 |

### Native 侧 setProp 支持的数据类型

| Kuikly 侧类型 | Native 侧接收类型 |
|--------------|-----------------|
| `String` | `String` / `NSString` |
| `Int` / `Float` / `Double` | 对应基础类型 / `NSNumber` |
| `Boolean` | `Boolean` / `BOOL` |
| `Event 回调` | `KuiklyRenderCallback` |

### 事件触发机制

在 Native 侧，事件通过 `KuiklyRenderCallback` 回调给 Kuikly 侧：

```kotlin
// 保存回调
private var loadSuccessCallback: KuiklyRenderCallback? = null

override fun setProp(propKey: String, propValue: Any): Boolean {
    return when (propKey) {
        "loadSuccess" -> {
            loadSuccessCallback = propValue as KuiklyRenderCallback
            true
        }
        else -> super.setProp(propKey, propValue)
    }
}

// 触发回调
private fun onImageLoaded(src: String, width: Int, height: Int) {
    loadSuccessCallback?.invoke(mapOf(
        "src" to src,
        "width" to width,
        "height" to height
    ))
}
```

---

## 常见陷阱与正确做法

| ❌ 错误做法 | ✅ 正确做法 |
|------------|-----------|
| View 名字 Kuikly 侧与 Native 侧不一致 | 确保 `viewName()` 返回值与 Native 注册名完全一致 |
| 自定义 View 未设置宽高导致不显示 | 自定义 View 跨端侧使用时必须显式设置宽高（如 `size(w, h)`），否则可能不会显示 |
| iOS 侧 View 类名与 Kuikly 侧 viewName 不一致 | iOS 通过类名动态创建 View，**类名必须与 `viewName()` 一致** |
| iOS 侧用 Swift 实现但未加 `@objc` 注解 | Swift 实现的 View 需要 `@objc` 或 `@objcMembers` 修饰 |
| 鸿蒙侧忘记实现 `createArkUIView()` | 鸿蒙侧必须实现此方法返回 `ComponentContent` |
| 忘记在 Native 侧注册自定义 View | 自定义 View 必须注册后才能使用 |
| 在 `performTaskWhenRenderViewDidLoad` 之外调用 `renderView` | View 方法必须在 `performTaskWhenRenderViewDidLoad` 回调中调用 |

---