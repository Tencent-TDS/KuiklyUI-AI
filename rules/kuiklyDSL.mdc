---
description: Kuikly 跨端开发规范，涵盖架构、编码、UI、性能、状态管理等最佳实践
alwaysApply: true
enabled: true
updatedAt: 2026-03-06T01:45:46.504Z
provider: 
---

# Kuikly 开发规范

你是 Kuikly、Kotlin、移动应用及跨平台开发方面的专家。目标是构建遵循现代最佳实践、高性能且易于维护的跨平台应用程序（涵盖 Android、iOS、鸿蒙、H5 及小程序等多种平台）。

## Kuikly 跨平台注意事项

- **在 commonMain 中编写**：尽量把所有业务逻辑集中在 `commonMain` 中，优先使用 Kuikly 本身和 Module 提供的能力，尽量减少 KMP `expect/actual` 模式
- **依赖使用**：业务模块可以添加 KMP 库依赖，尽可能使用多架构的 KMP 库，非必要不要分平台依赖
- **多平台兼容**：禁止直接在 `commonMain` 写平台相关的代码，验证代码能在所配置的目标平台上正确编译

## UI 构建规范

- **使用 Flexbox 布局**：考虑不同屏幕尺寸和方向，确保响应式设计，注意 Kuikly API 使用上的一些差异
- **组件使用**：优先选择使用 Kuikly 内置组件，复杂组件可以在跨平台层组合实现
- **组件属性**：使用 `attr {}` 块设置样式，使用 `event {}` 块设置事件，使用 `ref {}` 块设置组件引用
- **组合优先原则**：优先在跨平台层采用组合小型组件的方式实现 ComposeView，而不是扩展现有组件
- **返回ViewBuilder的函数需显式调用**：将 UI 构建逻辑抽取为返回 `ViewBuilder`的函数时，调用需通过`.invoke(this)`或`apply()`显式执行

## 布局设计

- **FlexBox 布局**：Kuikly 使用 FlexBox 布局系统，通过 `pagerData` 动态获取页面和设备尺寸。为了充分利用屏幕空间，根容器一般禁止使用固定宽高值。
- **安全区域适配**：如果设置了沉浸式，页面需要使用 `pagerData.safeAreaInsets`（top/bottom/left/right）或 `SafeArea` 组件处理系统占位，避免内容被遮挡。
- **滚动容器必须有确定尺寸**：`List`、`Scroller`、`WaterfallList`、`PageList` 等滚动容器必须拥有确定的宽高约束（通过 `flex(1f)`、`height()` 或 `size()` 设置）。
- **叶子组件不支持 padding**:如 `Text`、`Input` 等无子节点的组件不支持 `padding`，应使用 `margin` 替代

## 性能优化

- **生命周期优化**：避免阻塞 Pager 或 ComposeView 生命周期，在生命周期启动过程中应避免耗时任务直接阻塞页面渲染
- **最小化数据和资源加载**：首屏仅加载必须数据，必要数据可以缓存处理，减少首屏加载耗时
- **attr 块规范**：`attr {}` 块中不要放置过多逻辑，响应式变量更新会导致这些逻辑同样被执行，影响性能
- **最小化 observable 使用**：避免单一 observable 影响过多逻辑，避免使用过多的 observable，减少不必要的 UI 重建
- **耗时任务异步化**：Kuikly Module 同步调用会等待返回，耗时较大的可以使用内建协程或采用异步方式

## 扩展原生平台能力

由于 Kuikly 是跨平台框架，无法直接调用各平台（Android/iOS/鸿蒙等）的原生 API 或使用原生 UI 组件。若需使用平台特定能力，请遵循以下规范：

- **扩展原生 API**：通过 Module 机制进行访问。开发时，请先检查所需能力的对应 Module 是否已存在。若不存在，则需自行实现该 Module 以封装原生功能，供跨平台层调用
- **扩展原生 View**：尝试通过组合现有的 Kuikly 内置组件来构建所需 UI，优先选择组合组件。当组合方式无法满足需求时，可以通过扩展原生 View 机制封装平台特定的原生 UI 组件

## 状态管理

### 使用原则

- **响应式字段和容器**：使用 `observable` 和 `observableList<T>` 管理响应式字段和列表，并触发 UI 重建
- **搭配 attr 块及语句指令使用**：可以在 `attr {}` 块内使用触发属性更新， `vfor`/`vforIndex`/`vforLazy`，条件语句指令 `vif`/`velseif`/`velse`，绑定语句指令 `vbind`
- **最小化粒度使用**：避免单一 observable 影响过多逻辑，避免使用过多的 observable，影响性能
- **Item 内部字段响应式**：`observableList<T>` 仅监听增删事件，Item 内部字段需单独使用 `observable` 绑定
- **作用域限制**：响应式字段和容器与创建它的 PageScope（即 Pager 实例）绑定，其状态变更仅能驱动当前 Pager 的 UI 更新。若需跨页面共享状态，请通过其他机制（如页面事件通知）实现。

### 相关导入和用法

| 字段 |  import |
|------|-----------|
| `observable`, `observableList` | `com.tencent.kuikly.core.reactive.handler.*` |
| `vfor`, `vforIndex`, `vforLazy`, `vif`, `velseif`, `velse`, `vbind` | `com.tencent.kuikly.core.directives.*` |

```kotlin
var title by observable("")                    // 响应式变量
var itemList by observableList<ItemData>()     // 响应式列表(需声明类型<T>，无初始值)

// vfor：遍历列表
vfor({ ctx.itemList }) { item ->
    YourItemView {}
}
// vforIndex：遍历列表并获取索引
vforIndex({ ctx.itemList }) { item, index, conut ->
    YourItemView {
        attr {
            item(item)
            isHighlight = index < 3
        }
    }
}
// vforLazy：懒加载遍历（适用于大列表场景）
vforLazy({ ctx.listedModels }) { item, index, count ->
    YourItemView {}
}
```

### 条件指令示例

```kotlin
vif({ ctx.itemList.isEmpty() }) {
    EmptyView { }
}
velse {
    vfor({ ctx.itemList }) { item ->
        ItemView { }
    }
}
```

### vfor/vforLazy/vforIndex 注意事项
- 必须搭配 observableList<T>：vfor/vforLazy/vforIndex 的数据源必须是 observableList<T>，初始化时需声明泛型类型且无需设置初始值
- 闭包内有且仅有一个普通子节点：creator 闭包必须返回唯一一个普通节点作为根节点，禁止空闭包、多子节点、或以 vif/velse/vfor/if-else 等指令作为根级节点
- 分支逻辑需节点包裹：如需条件判断或复杂结构，先用 View {} 包裹作为唯一根节点，再在其内部使用分支指令

```kotlin
// ❌ 错误：空闭包 / 多子节点 / 根级 if-else / 根级 vif
// ✅ 正确：
vforLazy({ ctx.list }) { item, index, count ->
    View { /* 唯一根节点 */ }
}
```

## 其他规范

### 页面定义

必须使用 `@Page` 注解标记页面类：

```kotlin
import com.tencent.kuikly.core.annotations.Page
import com.tencent.kuikly.core.base.ViewBuilder
// 如果有 BasePager 类，可以导入并使用BasePager

@Page("YourPageName")
internal class YourPage : Page() {
    // 页面实现
}
```

**生命周期方法**：

| 方法 | 调用时机 | 用途 |
|------|----------|------|
| `onCreatePager(pagerId, pageData)` | 页面创建时 | 初始化页面参数、实例化 ViewModel |
| `pageDidAppear()` | 页面显示时 | 恢复数据、开始轮询、上报曝光、恢复状态 |
| `pageDidDisappear()` | 页面隐藏时 | 暂停轮询、保存状态 |
| `pageWillDestroy()` | 页面销毁前 | 清理资源、取消定时器、解绑监听 |


### 组件使用

内置组件：

- `View`（容器）、`Text`（文本）、`RichText`（富文本）、`Image`（图片）
- `Input`（单行输入框）、`TextArea`（多行输入框）、`Canvas`（自绘画布）、`Button`（按钮）
- `Scroller`（滚动容器）、`List`（列表）、`WaterFallList`（瀑布流）
- `SliderPage`（轮播图）、`PageList`（分页列表）、`Modal`（模态）
- `Refresh`（下拉刷新组件）、`FooterRefresh`（列表尾部刷新）
- `DatePicker`（日期选择器）、`ScrollPicker`（滚动选择器）、`Slider`（滑动器）
- `Switch`（开关）、`Blur`（高斯模糊）、`ActivityIndicator`（活动指示器）
- `Hover`（悬停置顶）、`Mask`（遮罩）、`CheckBox`（复选框）
- `PAG`（动画播放）、`APNG`（动画播放）、`Tabs`（标签栏）
- `AlertDialog`（提示对话框）、`ActionSheet`（操作表）、`Video`（播放器）

同时注意正确的 import：

```kotlin
import com.tencent.kuikly.core.views.View
import com.tencent.kuikly.core.views.Text
import com.tencent.kuikly.core.views.Image
import com.tencent.kuikly.core.views.compose.Button
```

## 路由

使用 `RouterModule` 模块打开或关闭 Kuikly 页面：

```kotlin
// 打开页面
getPager().acquireModule<RouterModule>(RouterModule.MODULE_NAME).openPage(pageName, pageData)

// 关闭页面
getPager().acquireModule<RouterModule>(RouterModule.MODULE_NAME).closePage(pageName)
```

## 数据处理与序列化

使用 Kuikly 封装的 `JSONObject` 和 `JSONArray` 进行数据处理与序列化：

```kotlin
import com.tencent.kuikly.core.nvi.serialization.json.JSONObject
import com.tencent.kuikly.core.nvi.serialization.json.JSONArray

// 解析 JSON
val json = JSONObject(jsonString)
val name = json.optString("name", "")
val age = json.optInt("age", 0)
val isActive = json.optBoolean("isActive", false)

// 构建 JSON
val params = JSONObject().apply {
    put("name", "John")
    put("age", 30)
    put("tags", JSONArray().apply {
        put("kotlin")
        put("kuikly")
    })
}
```

## 资源和图片

assets 资源存放在业务的 Kuikly 模块（`$moduleName`）下的 `commonMain/assets` 目录（如没有该目录，请新建）：

- **公共资源**：存放在 `$moduleName/src/commonMain/assets/common` 目录
- **页面资源**：存放在 `$moduleName/src/commonMain/assets/$pageName` 目录

本地图片使用示例：

```kotlin
import com.tencent.kuikly.core.base.attr.ImageUri

// common 目录资源
src(ImageUri.commonAssets("$assetsName"))

// $pageName 目录资源
src(ImageUri.pageAssets("$assetsName"))
```

## Color 颜色

Kuikly 使用自己的 `Color` 类创建颜色：

```kotlin
import com.tencent.kuikly.core.base.Color
// Hex 构造
Color(0xFFFF0000L)
// RGB + 透明度
Color(0xFF0000, 1.0f)
// RGBA 分量
Color(255, 0, 0, 1.0f)
// 内置颜色
Color.RED
```

## API 属性错误

```kotlin
// Wrong approach - Text component using View attributes
Text {
    attr {
        alignItemsCenter()       // Text doesn't support this attribute
        paddingHorizontal(4f)    // Text doesn't support padding
        fontWeight(400)          // Text's fontWeight doesn't accept numeric params, use predefined methods like fontWeight400()
    }
}

// Correct approach - Text component using corresponding attributes
Text {
    attr {
        textAlignCenter()        // Text center alignment
        marginLeft(4f)           // Use margin
        marginRight(4f)
        fontWeight400()          // Use predefined font weight methods instead of numeric values
    }
}
```