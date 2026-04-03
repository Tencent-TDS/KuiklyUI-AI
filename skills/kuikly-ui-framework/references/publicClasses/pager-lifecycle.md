
# 页面与生命周期

## Pager

```kotlin
import com.tencent.kuikly.core.pager.Pager
```

所有 Kuikly 页面必须继承 `Pager`，提供完整的生命周期回调。

**生命周期方法：**

| 方法 | 说明 |
|------|------|
| `created()` | 页面创建完成（此时可初始化数据） |
| `body()` | 构建页面 UI 树 |
| `pageDidAppear()` | 页面可见时回调 |
| `pageDidDisappear()` | 页面不可见时回调 |
| `pageWillDestroy()` | 页面即将销毁 |
| `onFirstFramePaint()` | 首帧渲染完成 |
| `themeDidChanged(data)` | 主题切换时回调 |

**获取模块：**

```kotlin
// 获取内置模块（推荐，模块不存在会抛异常）
val network = acquireModule<NetworkModule>(NetworkModule.MODULE_NAME)

// 获取模块（模块不存在返回 null）
val router = getModule<RouterModule>(RouterModule.MODULE_NAME)
```

**注册自定义模块：**

```kotlin
override fun createExternalModules(): Map<String, Module>? {
    registerModule("MyModule") { MyModule() }
    return null
}
```

**其他常用方法：**

```kotlin
// 监听响应式变量变化
bindValueChange({ this.count }, byOwner = this) { value ->
    // count 变化时执行
}

// 取消监听
unbindAllValueChange(byOwner = this)

// 同步 UI 上屏
syncFlushUI()
```

---

## PageData

```kotlin
import com.tencent.kuikly.core.pager.PageData
```

包含设备信息、平台信息、根视图尺寸、页面传参等。通过 `pagerData` 属性访问。

**常用属性：**

| 属性 | 类型 | 说明 |
|------|------|------|
| `params` | `JSONObject` | 页面传参 |
| `pageViewWidth` | `Float` | 页面根视图宽度（响应式） |
| `pageViewHeight` | `Float` | 页面根视图高度（响应式） |
| `deviceWidth` | `Float` | 设备屏幕宽度（响应式） |
| `deviceHeight` | `Float` | 设备屏幕高度（响应式） |
| `statusBarHeight` | `Float` | 状态栏高度 |
| `navigationBarHeight` | `Float` | 导航栏高度（statusBarHeight + 44） |
| `safeAreaInsets` | `EdgeInsets` | 安全区域（响应式） |
| `platform` | `String` | 平台名称 |
| `isIOS` | `Boolean` | 是否 iOS |
| `isAndroid` | `Boolean` | 是否 Android |
| `isOhOs` | `Boolean` | 是否鸿蒙 |
| `isWeb` | `Boolean` | 是否 Web |
| `isMiniApp` | `Boolean` | 是否小程序 |
| `isMacOS` | `Boolean` | 是否 macOS |
| `isIphoneX` | `Boolean` | 是否刘海屏 iPhone |
| `appVersion` | `String` | 宿主 App 版本号 |
| `density` | `Float` | 屏幕密度 |
| `activityWidth` | `Float` | Activity 宽度（响应式） |
| `activityHeight` | `Float` | Activity 高度（响应式） |
| `osVersion` | `String` | 操作系统版本 |
| `isAccessibilityRunning` | `Boolean` | 是否处于无障碍模式 |
| `androidBottomBavBarHeight` | `Float` | Android 底部导航栏高度 |

```kotlin
// 在 Pager 中使用
val pageWidth = pagerData.pageViewWidth
val isIOS = pagerData.isIOS
val name = pagerData.params.optString("name")
```
